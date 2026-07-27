import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:notisboard/services/translation/azure_speech_translation.dart';
import 'package:notisboard/services/translation/translation_api.dart';
import 'package:notisboard/services/translation/translation_models.dart';
import 'package:notisboard/socket/socket_service.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/socket_events.dart';
import 'package:notisboard/utils/socket_params.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:record/record.dart';

/// TranslationService manages the lifecycle of live translation during a call.
///
/// Architecture:
/// 1. AzureSpeechTranslation handles mic audio → Azure STT → Azure Translator
/// 2. Translated text is sent to the other participant via socket
/// 3. Subtitles from the other participant are received via socket
/// 4. UI state is managed via GetX update IDs
class TranslationService extends GetxController {
  TranslationConfigData? _config;
  TranslationConfigData? get config => _config;

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  bool _isActive = false;
  bool get isActive => _isActive;

  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  String _sourceLang = 'en';
  String get sourceLang => _sourceLang;

  String _targetLang = 'ar';
  String get targetLang => _targetLang;

  SubtitleData? _currentSubtitle;
  SubtitleData? get currentSubtitle => _currentSubtitle;

  // Group session: show up to 3 recent subtitles from different participants
  final List<SubtitleData> _activeSubtitles = [];
  List<SubtitleData> get activeSubtitles => _activeSubtitles;

  List<SubtitleData> _subtitleHistory = [];
  List<SubtitleData> get subtitleHistory => _subtitleHistory;

  Timer? _subtitleClearTimer;

  // Azure Speech Translation
  final AzureSpeechTranslation _azureTranslation = AzureSpeechTranslation();
  AudioRecorder? _audioRecorder;
  bool _isRecordingAudio = false;
  Timer? _audioChunkTimer;

  // Track my own subtitles for echo
  SubtitleData? _myLastSubtitle;
  SubtitleData? get myLastSubtitle => _myLastSubtitle;

  @override
  void onInit() {
    super.onInit();
    _loadConfig();
    _setupSocketListeners();
    _setupAzureCallbacks();
  }

  @override
  void onClose() {
    _subtitleClearTimer?.cancel();
    _audioChunkTimer?.cancel();
    _removeSocketListeners();
    _azureTranslation.dispose();
    _stopMicRecording();
    super.onClose();
  }

  Future<void> _loadConfig() async {
    try {
      final response = await TranslationApi.fetchConfig();
      Utils.showLog("[TranslationService] _loadConfig response: status=${response?.status}, enabled=${response?.data?.enabled}");
      if (response?.status == true && response?.data != null) {
        _config = response!.data;
        _isEnabled = _config!.enabled;
        _sourceLang = _config!.defaultSourceLang;
        _targetLang = _config!.defaultTargetLang;
        update([Constant.idTranslation]);
      } else {
        Utils.showLog("[TranslationService] _loadConfig: config response invalid, retrying in 3s");
        Future.delayed(const Duration(seconds: 3), () {
          if (!_isEnabled) _loadConfig();
        });
      }
    } catch (e) {
      Utils.showLog("[TranslationService] _loadConfig error: $e, retrying in 3s");
      Future.delayed(const Duration(seconds: 3), () {
        if (!_isEnabled) _loadConfig();
      });
    }
  }

  /// Public method to refresh config - called when entering a call screen.
  Future<void> refreshConfig() async {
    await _loadConfig();
  }

  void _setupSocketListeners() {
    socket?.on(SocketEvents.translationStarted, _handleTranslationStarted);
    socket?.on(SocketEvents.translationStopped, _handleTranslationStopped);
    socket?.on(SocketEvents.subtitleReceived, _handleSubtitleReceived);
    socket?.on(SocketEvents.translationParticipantJoined, _handleParticipantJoined);
    socket?.on(SocketEvents.translationParticipantLeft, _handleParticipantLeft);
  }

  void _removeSocketListeners() {
    socket?.off(SocketEvents.translationStarted, _handleTranslationStarted);
    socket?.off(SocketEvents.translationStopped, _handleTranslationStopped);
    socket?.off(SocketEvents.subtitleReceived, _handleSubtitleReceived);
    socket?.off(SocketEvents.translationParticipantJoined, _handleParticipantJoined);
    socket?.off(SocketEvents.translationParticipantLeft, _handleParticipantLeft);
  }

  void _setupAzureCallbacks() {
    _azureTranslation.onTranslated = (originalText, translatedText, confidence) {
      // Send translated subtitle to the other participant
      sendSubtitle(
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: _sourceLang,
        targetLanguage: _targetLang,
        confidence: confidence,
      );

      // Show my own subtitle as well (echo)
      _myLastSubtitle = SubtitleData(
        sessionId: _activeSessionId ?? '',
        senderId: Database.loginUserId,
        senderRole: _resolveUserRole(),
        originalText: originalText,
        translatedText: translatedText,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        confidence: confidence,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      update([Constant.idSubtitle]);

      // Clear my subtitle after 5 seconds
      _subtitleClearTimer?.cancel();
      _subtitleClearTimer = Timer(const Duration(seconds: 5), () {
        _myLastSubtitle = null;
        update([Constant.idSubtitle]);
      });
    };

    _azureTranslation.onError = (error) {
      Utils.showLog("[TranslationService] Azure error: $error");
    };
  }

  void _handleTranslationStarted(dynamic data) {
    Utils.showLog("[TranslationService] translationStarted: $data");
    if (data is Map && data['status'] == true) {
      _isActive = true;
      update([Constant.idTranslation, Constant.idSubtitle]);
    } else {
      Utils.showToast(Get.context, data['message'] ?? 'Translation could not be started.');
    }
  }

  void _handleTranslationStopped(dynamic data) {
    Utils.showLog("[TranslationService] translationStopped: $data");
    _isActive = false;
    _activeSessionId = null;
    _currentSubtitle = null;
    _activeSubtitles.clear();
    _myLastSubtitle = null;
    _subtitleClearTimer?.cancel();
    update([Constant.idTranslation, Constant.idSubtitle]);
  }

  void _handleSubtitleReceived(dynamic data) {
    try {
      if (data is! Map) return;

      final subtitle = SubtitleData.fromJson(Map<String, dynamic>.from(data));

      // Only show subtitles from OTHER participants
      if (subtitle.senderId == Database.loginUserId) return;

      _currentSubtitle = subtitle;
      _subtitleHistory.add(subtitle);

      // Group session: maintain up to 3 active subtitles from different senders
      _activeSubtitles.removeWhere((s) => s.senderId == subtitle.senderId);
      _activeSubtitles.add(subtitle);
      if (_activeSubtitles.length > 3) {
        _activeSubtitles.removeAt(0);
      }

      // Keep only last 50 subtitles in history
      if (_subtitleHistory.length > 50) {
        _subtitleHistory = _subtitleHistory.sublist(_subtitleHistory.length - 50);
      }

      update([Constant.idSubtitle]);

      // Auto-clear active subtitles after 5 seconds
      _subtitleClearTimer?.cancel();
      _subtitleClearTimer = Timer(const Duration(seconds: 5), () {
        _currentSubtitle = null;
        _activeSubtitles.clear();
        update([Constant.idSubtitle]);
      });
    } catch (e) {
      Utils.showLog("[TranslationService] _handleSubtitleReceived error: $e");
    }
  }

  void _handleParticipantJoined(dynamic data) {
    Utils.showLog("[TranslationService] participantJoined: $data");
  }

  void _handleParticipantLeft(dynamic data) {
    Utils.showLog("[TranslationService] participantLeft: $data");
  }

  /// Start translation for the current call.
  Future<void> startTranslation({
    required String callId,
    String? sourceLang,
    String? targetLang,
  }) async {
    if (!_isEnabled) {
      Utils.showToast(Get.context, "Live translation is not available.");
      return;
    }

    _sourceLang = sourceLang ?? _sourceLang;
    _targetLang = targetLang ?? _targetLang;
    _activeSessionId = callId;

    // Emit socket event to notify backend
    socket?.emit(SocketEvents.startTranslation, {
      SocketParams.sessionId: callId,
      SocketParams.senderId: Database.loginUserId,
      'userRole': _resolveUserRole(),
      'sourceLang': _sourceLang,
      'targetLang': _targetLang,
    });

    // Also call API for server-side tracking
    TranslationApi.startSession(
      sessionId: callId,
      sourceLang: _sourceLang,
      targetLang: _targetLang,
    );

    // Start Azure Speech Translation with mic audio
    await _startMicRecording();

    _isActive = true;
    update([Constant.idTranslation, Constant.idSubtitle]);
  }

  /// Stop translation for the current call.
  Future<void> stopTranslation() async {
    if (_activeSessionId == null) return;

    // Stop mic recording and Azure translation
    await _stopMicRecording();

    socket?.emit(SocketEvents.stopTranslation, {
      SocketParams.sessionId: _activeSessionId,
    });

    TranslationApi.stopSession(sessionId: _activeSessionId!);

    _isActive = false;
    _activeSessionId = null;
    _currentSubtitle = null;
    _activeSubtitles.clear();
    _myLastSubtitle = null;
    _subtitleClearTimer?.cancel();
    update([Constant.idTranslation, Constant.idSubtitle]);
  }

  /// Start recording mic audio and sending to Azure.
  Future<void> _startMicRecording() async {
    if (_isRecordingAudio) return;

    try {
      _audioRecorder = AudioRecorder();

      // Check and request mic permission
      if (!await _audioRecorder!.hasPermission()) {
        Utils.showToast(Get.context, "Microphone permission required for translation.");
        return;
      }

      // Start recording to a stream
      final stream = await _audioRecorder!.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      _isRecordingAudio = true;

      // Get Azure credentials from settings
      final azureKey = Database.settingApiModel?.data?.azureSpeechKey ?? '';
      final azureRegion = Database.settingApiModel?.data?.azureSpeechRegion ?? '';

      if (azureKey.isEmpty || azureRegion.isEmpty) {
        Utils.showToast(Get.context, "Azure Speech credentials not configured.");
        await _stopMicRecording();
        return;
      }

      // Start Azure translation
      await _azureTranslation.start(
        subscriptionKey: azureKey,
        region: azureRegion,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );

      // Process audio chunks as they arrive
      // Buffer audio data and send in 2-second chunks for optimal Azure performance
      final audioBuffer = <int>[];
      const chunkDurationMs = 2000;
      const bytesPerSecond = 16000 * 2; // 16kHz * 16-bit (2 bytes)
      const chunkSize = (bytesPerSecond * chunkDurationMs) ~/ 1000;

      stream.listen(
        (Uint8List data) {
          audioBuffer.addAll(data);

          // When buffer has enough data, send to Azure
          if (audioBuffer.length >= chunkSize) {
            final chunk = Uint8List.fromList(audioBuffer);
            audioBuffer.clear();
            _azureTranslation.processAudioChunk(chunk);
          }
        },
        onError: (error) {
          Utils.showLog("[TranslationService] Audio stream error: $error");
        },
        onDone: () {
          Utils.showLog("[TranslationService] Audio stream closed");
          _isRecordingAudio = false;
        },
      );

      Utils.showLog("[TranslationService] Mic recording started");
    } catch (e) {
      Utils.showLog("[TranslationService] _startMicRecording error: $e");
      Utils.showToast(Get.context, "Failed to start translation recording.");
      _isRecordingAudio = false;
    }
  }

  /// Stop recording mic audio.
  Future<void> _stopMicRecording() async {
    try {
      _azureTranslation.stop();

      if (_audioRecorder != null) {
        await _audioRecorder!.stop();
        _audioRecorder = null;
      }

      _isRecordingAudio = false;
      _audioChunkTimer?.cancel();
      _audioChunkTimer = null;

      Utils.showLog("[TranslationService] Mic recording stopped");
    } catch (e) {
      Utils.showLog("[TranslationService] _stopMicRecording error: $e");
    }
  }

  /// Send translated subtitle to the other participant.
  void sendSubtitle({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    double confidence = 0.0,
  }) {
    if (_activeSessionId == null) return;

    socket?.emit(SocketEvents.subtitleReceived, {
      SocketParams.sessionId: _activeSessionId,
      SocketParams.senderId: Database.loginUserId,
      'senderName': Database.loginUserName.isNotEmpty
          ? Database.loginUserName
          : (Database.fetchListenerProfileModel?.data?.name ?? 'User'),
      'senderRole': _resolveUserRole(),
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLang': sourceLanguage,
      'targetLang': targetLanguage,
      'confidence': confidence,
    });

    // Log usage for billing
    TranslationApi.logUsage(
      sessionId: _activeSessionId!,
      characterCount: translatedText.length,
      sourceLang: sourceLanguage,
      targetLang: targetLanguage,
    );
  }

  /// Update source language.
  void setSourceLang(String langCode) {
    _sourceLang = langCode;
    update([Constant.idTranslation]);
  }

  /// Update target language.
  void setTargetLang(String langCode) {
    _targetLang = langCode;
    update([Constant.idTranslation]);
  }

  /// Clear the current subtitle overlay.
  void clearSubtitle() {
    _currentSubtitle = null;
    _myLastSubtitle = null;
    _subtitleClearTimer?.cancel();
    update([Constant.idSubtitle]);
  }

  /// Check if the call type supports translation.
  bool isCallTypeSupported(String callType) {
    if (_config == null) return false;
    if (callType == 'audio') return _config!.audioEnabled;
    if (callType == 'video') return _config!.videoEnabled;
    return false;
  }

  /// Get display name for a language code.
  static String getLanguageName(String code) {
    final lang = SupportedLanguage.findByCode(code);
    return lang?.name ?? code.toUpperCase();
  }

  String _resolveUserRole() {
    final listenerProfile = Database.fetchListenerProfileModel?.data;
    if (listenerProfile != null && Database.loginUserId.isNotEmpty) {
      return 'listener';
    }
    return 'user';
  }
}

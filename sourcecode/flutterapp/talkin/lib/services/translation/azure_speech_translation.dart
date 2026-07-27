import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:notisboard/utils/utils.dart';

/// Azure Speech Translation service using REST APIs.
///
/// Flow:
/// 1. Record audio chunks from mic using `record` package
/// 2. Send each chunk to Azure Speech-to-Text REST API
/// 3. Send recognized text to Azure Translator REST API
/// 4. Return translated text
///
/// This avoids native SDK dependency and works cross-platform.
class AzureSpeechTranslation {
  String? _subscriptionKey;
  String? _region;
  String? _sourceLang;
  String? _targetLang;
  bool _isRunning = false;
  Timer? _chunkTimer;

  // Callbacks
  void Function(String originalText, String translatedText, double confidence)?
      onTranslated;
  void Function(String error)? onError;

  bool get isRunning => _isRunning;

  /// Initialize with Azure credentials.
  void configure({
    required String subscriptionKey,
    required String region,
    required String sourceLang,
    required String targetLang,
  }) {
    _subscriptionKey = subscriptionKey;
    _region = region;
    _sourceLang = sourceLang;
    _targetLang = targetLang;
  }

  /// Start continuous translation.
  /// Requires microphone permission to be granted.
  Future<void> start({
    required String subscriptionKey,
    required String region,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (_isRunning) return;

    configure(
      subscriptionKey: subscriptionKey,
      region: region,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    _isRunning = true;
    Utils.showLog("[AzureSpeechTranslation] Started: $sourceLang → $targetLang");
  }

  /// Stop continuous translation.
  void stop() {
    _isRunning = false;
    _chunkTimer?.cancel();
    _chunkTimer = null;
    Utils.showLog("[AzureSpeechTranslation] Stopped");
  }

  /// Process a chunk of PCM audio data (16-bit, 16kHz, mono).
  /// Sends to Azure STT then Translator, returns translated text via callback.
  Future<void> processAudioChunk(Uint8List audioChunk) async {
    if (!_isRunning || _subscriptionKey == null || _region == null) return;
    if (audioChunk.isEmpty) return;

    try {
      // Step 1: Speech-to-Text
      final sttResult = await _speechToText(audioChunk);
      if (sttResult == null || sttResult.text.isEmpty) return;

      final confidence = sttResult.confidence;

      // Step 2: Translate text
      final translated = await _translateText(sttResult.text);
      if (translated == null || translated.isEmpty) return;

      // Step 3: Notify via callback
      onTranslated?.call(sttResult.text, translated, confidence);
    } catch (e) {
      Utils.showLog("[AzureSpeechTranslation] Error processing chunk: $e");
      onError?.call(e.toString());
    }
  }

  /// Azure Speech-to-Text REST API call.
  Future<_SttResult?> _speechToText(Uint8List audioData) async {
    if (_subscriptionKey == null || _region == null || _sourceLang == null) {
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://$_region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1'
        '?language=$_sourceLang',
      );

      final response = await http.post(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': _subscriptionKey!,
          'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',
          'Accept': 'application/json',
        },
        body: audioData,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final displayText = body['DisplayText'] ?? '';
        final confidence = (body['NBest'] as List?)?.isNotEmpty == true
            ? (body['NBest'][0]['Confidence'] ?? 0.8).toDouble()
            : 0.8;

        return _SttResult(
          text: displayText.toString().trim(),
          confidence: confidence,
        );
      } else {
        Utils.showLog("[AzureSpeechTranslation] STT error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      Utils.showLog("[AzureSpeechTranslation] STT exception: $e");
    }
    return null;
  }

  /// Azure Translator REST API call.
  Future<String?> _translateText(String text) async {
    if (_subscriptionKey == null || _region == null || _targetLang == null) {
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://$_region.api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=$_targetLang',
      );

      final response = await http.post(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': _subscriptionKey!,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode([
          {'Text': text}
        ]),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as List;
        if (body.isNotEmpty) {
          final translations = body[0]['translations'] as List;
          if (translations.isNotEmpty) {
            return translations[0]['text']?.toString() ?? '';
          }
        }
      } else {
        Utils.showLog("[AzureSpeechTranslation] Translator error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      Utils.showLog("[AzureSpeechTranslation] Translator exception: $e");
    }
    return null;
  }

  /// Dispose resources.
  void dispose() {
    stop();
    onTranslated = null;
    onError = null;
  }
}

class _SttResult {
  final String text;
  final double confidence;

  _SttResult({required this.text, required this.confidence});
}

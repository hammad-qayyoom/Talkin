import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:notisboard/utils/app_asset.dart';

class RingtoneService {
  static AudioPlayer? _ringtonePlayer;
  static bool _isPlaying = false;

  // ✅ Initialize ringtone player
  static Future<void> init() async {
    _ringtonePlayer = AudioPlayer();

    // Configure for ringtone playback
    await _ringtonePlayer?.setReleaseMode(ReleaseMode.loop);
    await _ringtonePlayer?.setVolume(1.0);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _ringtonePlayer?.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notificationRingtone,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
    }
  }

  // ✅ Play ringtone
  static Future<void> playRingtone() async {
    if (_isPlaying) {
      debugPrint("Ringtone already playing");
      return;
    }

    try {
      if (_ringtonePlayer == null) {
        await init();
      }

      // Stop any existing playback
      await _ringtonePlayer?.stop();

      // Play ringtone
      await _ringtonePlayer?.play(
        AssetSource(AppAsset.ringTone),
        volume: 1.0,
      );

      _isPlaying = true;
      debugPrint("Ringtone started playing");
    } catch (e) {
      debugPrint("Error playing ringtone: $e");
      _isPlaying = false;
    }
  }

  // ✅ Stop ringtone
  static Future<void> stopRingtone() async {
    if (!_isPlaying) {
      return;
    }

    try {
      await _ringtonePlayer?.stop();
      _isPlaying = false;
      debugPrint("Ringtone stopped");
    } catch (e) {
      debugPrint("Error stopping ringtone: $e");
    }
  }

  // ✅ Dispose ringtone player
  static Future<void> dispose() async {
    try {
      await stopRingtone();
      await _ringtonePlayer?.dispose();
      _ringtonePlayer = null;
    } catch (e) {
      debugPrint("Error disposing ringtone player: $e");
    }
  }

  // ✅ Check if playing
  static bool get isPlaying => _isPlaying;
}

// ========================================
// ANDROID NATIVE RINGTONE (Optional)
// ========================================

class NativeRingtoneService {
  static const MethodChannel _channel = MethodChannel('ringtone_channel');

  // Play native system ringtone
  static Future<void> playNativeRingtone() async {
    try {
      await _channel.invokeMethod('playRingtone');
      debugPrint("Native ringtone started");
    } catch (e) {
      debugPrint("Error playing native ringtone: $e");
    }
  }

  // Stop native system ringtone
  static Future<void> stopNativeRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
      debugPrint("Native ringtone stopped");
    } catch (e) {
      debugPrint("Error stopping native ringtone: $e");
    }
  }
}

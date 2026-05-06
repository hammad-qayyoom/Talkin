import 'dart:developer';
import 'dart:math' show Random;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class AppStartupHelper {
  static const String _fallbackIdentityKey = 'fallbackDeviceIdentity';

  static Future<T?> runTask<T>(
    String label,
    Future<T> Function() task, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      return await task().timeout(timeout);
    } catch (error, stackTrace) {
      Utils.showLog("$label failed => $error");
      log(label, error: error, stackTrace: stackTrace);
      return null;
    }
  }

  static Future<String> getSafeDeviceId({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final nativeIdentity = await runTask<String?>(
      "Device identity init",
      () => MobileDeviceIdentifier().getDeviceId(),
      timeout: timeout,
    );

    final resolvedNativeIdentity = (nativeIdentity ?? '').trim();
    if (resolvedNativeIdentity.isNotEmpty) {
      return resolvedNativeIdentity;
    }

    final storedIdentity = Database.identity.trim();
    if (storedIdentity.isNotEmpty) {
      return storedIdentity;
    }

    final storedFallback =
        (Database.localStorage.read(_fallbackIdentityKey) ?? '')
            .toString()
            .trim();
    if (storedFallback.isNotEmpty) {
      return storedFallback;
    }

    final generatedFallback =
        'device_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}';
    await Database.localStorage.write(_fallbackIdentityKey, generatedFallback);
    Utils.showLog("Device identity unavailable; using stored fallback id.");
    return generatedFallback;
  }

  static Future<String?> getSafeFcmToken({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final storedToken = Database.fcmToken.trim();

    try {
      if (GetPlatform.isIOS) {
        // iOS often requires notification authorization before APNS/FCM token becomes available.
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: true,
        );

        for (int i = 0; i < 12; i++) {
          final apnsToken = await FirebaseMessaging.instance
              .getAPNSToken()
              .timeout(const Duration(milliseconds: 400));
          if ((apnsToken ?? '').isNotEmpty) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      }

      final token =
          await FirebaseMessaging.instance.getToken().timeout(timeout);
      return (token ?? '').trim().isEmpty ? storedToken : token;
    } catch (error, stackTrace) {
      Utils.showLog("FCM token unavailable => $error");
      log("FCM token unavailable", error: error, stackTrace: stackTrace);
      return storedToken.isEmpty ? null : storedToken;
    }
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static const _kEnabled = 'biometric_enabled';
  static const _kSessionUid = 'biometric_session_uid';
  static const _kSessionUserId = 'biometric_session_user_id';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricSupported() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
    } catch (e) {
      Utils.showLog('Biometric support check failed => $e');
      return false;
    }
  }

  static Future<bool> isEnabled() async {
    final value = await _secureStorage.read(key: _kEnabled);
    return value == 'true';
  }

  static Future<void> setEnabled(bool enabled) async {
    await _secureStorage.write(key: _kEnabled, value: enabled ? 'true' : 'false');
    if (!enabled) {
      await clearSessionBinding();
    }
  }

  static Future<void> bindSessionForCurrentUser() async {
    final uid = Database.loginUserFirebaseId.trim();
    final userId = Database.loginUserId.trim();
    if (uid.isEmpty || userId.isEmpty) return;

    await _secureStorage.write(key: _kSessionUid, value: uid);
    await _secureStorage.write(key: _kSessionUserId, value: userId);
  }

  static Future<bool> hasValidBoundSession() async {
    final uid = await _secureStorage.read(key: _kSessionUid);
    final userId = await _secureStorage.read(key: _kSessionUserId);

    if ((uid ?? '').trim().isEmpty || (userId ?? '').trim().isEmpty) {
      return false;
    }

    return uid!.trim() == Database.loginUserFirebaseId.trim() &&
        userId!.trim() == Database.loginUserId.trim();
  }

  static Future<bool> shouldRequireUnlockOnStartup() async {
    if (!Database.isLogin || Database.isGuestMode) return false;
    if (!await isEnabled()) return false;
    return hasValidBoundSession();
  }

  static Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );
    } catch (e) {
      Utils.showLog('Biometric authenticate failed => $e');
      return false;
    }
  }

  static Future<void> clearSessionBinding() async {
    await _secureStorage.delete(key: _kSessionUid);
    await _secureStorage.delete(key: _kSessionUserId);
  }

  static Future<void> clearAll() async {
    await _secureStorage.delete(key: _kEnabled);
    await clearSessionBinding();
  }
}

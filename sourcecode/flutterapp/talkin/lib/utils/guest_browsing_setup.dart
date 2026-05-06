import 'package:firebase_auth/firebase_auth.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_custom_token_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_uid_by_device_u_uid_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/login_api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/startup_helper.dart';
import 'package:notisboard/utils/utils.dart';

class GuestBrowsingSetup {
  static Future<bool> ensureAuthenticatedGuestSession() async {
    try {
      final identity = await AppStartupHelper.getSafeDeviceId();
      if (identity.isEmpty) {
        Utils.showLog("Guest setup: device identity missing.");
        return false;
      }

      await Database.onSetIdentity(identity);
      final fcmToken = await AppStartupHelper.getSafeFcmToken();
      await Database.onSetFcmToken(fcmToken ?? "");

      final uidResponse = await GetFirebaseUidByDeviceApi.callApi(
        loginType: 2,
        deviceUuid: identity,
      );

      final existingFirebaseUid = (uidResponse?.firebaseId ?? '').trim();
      final isExistingGuest =
          uidResponse?.status == true && existingFirebaseUid.isNotEmpty;
      final guestFirebaseUid = isExistingGuest
          ? existingFirebaseUid
          : _buildGuestFirebaseUid(identity);

      final customTokenResponse = await GetFirebaseCustomTokenApi.callApi(
        firebaseUid: guestFirebaseUid,
      );
      final customToken = (customTokenResponse?.customToken ?? '').trim();
      if (customTokenResponse?.status != true || customToken.isEmpty) {
        Utils.showLog(
            "Guest setup: custom token failed => ${customTokenResponse?.message}");
        return false;
      }

      final credential =
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
      final firebaseUid = (credential.user?.uid ?? guestFirebaseUid).trim();
      if (firebaseUid.isEmpty) {
        Utils.showLog("Guest setup: Firebase UID missing after sign-in.");
        return false;
      }

      final loginResponse = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 2,
        email: Database.identity,
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: isExistingGuest ? null : "Guest",
        profilePic: null,
        age: 25,
        birthDate: "2000-01-01",
        acceptTerms: true,
        acceptanceSource: "guest",
      );

      if (loginResponse?.status != true) {
        Utils.showLog(
            "Guest setup: login api failed => ${loginResponse?.message}");
        return false;
      }

      await Database.onSetIsLogin(true);
      await Database.onSetGuestMode(true);
      await Database.onSetLoginType(2);
      await Database.onSetSeenOnboarding(true);
      await Database.onSetFillProfile(true);

      await Database.onSetLoginUserFirebaseId(firebaseUid);
      await Database.onSetLoginUserId(loginResponse?.user?.id ?? "");
      await Database.onSetLoginUserName(
          loginResponse?.user?.fullName ?? "Guest");
      await Database.onSetLoginUserNickName(
          loginResponse?.user?.nickName ?? "Guest");
      await Database.onSetLoginUserProfilePic(
          loginResponse?.user?.profilePic ?? "");
      await Database.onSetLoginUserEmail(loginResponse?.user?.email ?? "");

      return true;
    } catch (error) {
      Utils.showLog("Guest setup error => $error");
      return false;
    }
  }

  static String _buildGuestFirebaseUid(String identity) {
    final normalized =
        identity.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = normalized.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : normalized;
    final trimmedSuffix = suffix.length > 56 ? suffix.substring(0, 56) : suffix;
    return 'guest_$trimmedSuffix';
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_custom_token_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_uid_by_device_u_uid_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/login_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
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
        email: '',
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: isExistingGuest ? null : _buildGuestDisplayName(identity),
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

      final resolvedLoginType = loginResponse?.user?.loginType ?? 2;
      final isGuestAccount =
          loginResponse?.user?.isGuestAccount ?? resolvedLoginType == 2;

      await Database.onSetIsLogin(true);
      await Database.onSetGuestMode(isGuestAccount);
      await Database.onSetLoginType(resolvedLoginType);
      await Database.onSetSeenOnboarding(true);
      await Database.onSetFillProfile(true);

      await Database.onSetLoginUserFirebaseId(
          loginResponse?.user?.firebaseId ?? firebaseUid);
      await Database.onSetLoginUserId(loginResponse?.user?.id ?? "");
      await Database.onSetLoginUserName(
          loginResponse?.user?.fullName ?? "Guest");
      await Database.onSetLoginUserNickName(
          loginResponse?.user?.nickName ?? "Guest");
      await Database.onSetLoginUserProfilePic(
          loginResponse?.user?.profilePic ?? "");
      await Database.onSetLoginUserEmail(loginResponse?.user?.email ?? "");

      await refreshCurrentGuestProfile(firebaseUid: firebaseUid);

      return true;
    } catch (error) {
      Utils.showLog("Guest setup error => $error");
      return false;
    }
  }

  static Future<bool> refreshCurrentGuestProfile({String? firebaseUid}) async {
    try {
      final uid = (firebaseUid ?? Database.loginUserFirebaseId).trim();
      if (uid.isEmpty) return false;

      final token = await FirebaseAccessToken.onGet() ?? "";
      if (token.trim().isEmpty) return false;

      final profile = await FetchLoginUserProfileApi.callApi(
        loginUserId: uid,
        token: token,
      );

      final user = profile?.user;
      if (profile?.status != true || user == null) return false;

      Database.fetchLoginUserProfileModel = profile;
      await Database.onSetIsLogin(true);
      await Database.onSetGuestMode(user.isGuestAccount == true);
      await Database.onSetLoginType(user.loginType ?? Database.loginType);
      await Database.onSetLoginUserFirebaseId(user.firebaseId ?? uid);
      await Database.onSetLoginUserId(user.id ?? Database.loginUserId);
      await Database.onSetLoginUserName(user.fullName ?? Database.loginUserName);
      await Database.onSetLoginUserNickName(
          user.nickName ?? Database.loginUserNickName);
      await Database.onSetLoginUserEmail(user.email ?? Database.loginUserEmail);
      await Database.onSetLoginUserProfilePic(
          user.profilePic ?? Database.loginUserProfilePic);
      await Database.onSetLoginUserPhoneNumber(
          user.phoneNumber ?? Database.loginUserPhoneNumber);
      await Database.onSetLoginUserBirthDate(
          user.birthDate ?? Database.loginUserBirthDate);
      await Database.onSetLoginUserGender(user.gender ?? Database.loginUserGender);
      await Database.onSetLoginUserCountry(user.country ?? Database.country);
      await Database.onSetLoginUserCountryFlag(
          user.countryFlag ?? Database.countryFlag);

      return true;
    } catch (error) {
      Utils.showLog("Guest profile refresh failed => $error");
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

  static String _buildGuestDisplayName(String identity) {
    final normalized =
        identity.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = normalized.length >= 4
        ? normalized.substring(normalized.length - 4).toUpperCase()
        : DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return 'Guest User $suffix';
  }
}

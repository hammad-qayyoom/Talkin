import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_custom_token_api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class FirebaseAccessToken {
  static Future<bool> _repairFirebaseSession({
    required String targetFirebaseUid,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.uid == targetFirebaseUid) {
        return true;
      }

      if (targetFirebaseUid.trim().isEmpty) {
        return false;
      }

      final customTokenResponse = await GetFirebaseCustomTokenApi.callApi(
        firebaseUid: targetFirebaseUid,
      );
      final customToken = (customTokenResponse?.customToken ?? '').trim();
      if (customToken.isEmpty) {
        Utils.showLog(
            "Firebase session repair skipped: custom token empty for uid=$targetFirebaseUid");
        return false;
      }

      final credential =
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
      final resolvedUid = (credential.user?.uid ?? '').trim();
      final repaired = resolvedUid == targetFirebaseUid;
      Utils.showLog(
          "Firebase session repair result => repaired=$repaired resolvedUid=$resolvedUid targetUid=$targetFirebaseUid");
      return repaired;
    } catch (e) {
      Utils.showLog("Firebase session repair failed => $e");
      return false;
    }
  }

  static Future<User?> _resolveFirebaseUser() async {
    var user = FirebaseAuth.instance.currentUser;
    final targetFirebaseUid = Database.loginUserFirebaseId.trim();

    if (Database.isLogin && targetFirebaseUid.isNotEmpty) {
      if (user == null || user.uid != targetFirebaseUid) {
        await _repairFirebaseSession(targetFirebaseUid: targetFirebaseUid);
        user = FirebaseAuth.instance.currentUser;
      }
    }

    return user;
  }

  static Future<String?> onGet() async {
    try {
      User? user = await _resolveFirebaseUser();
      final targetFirebaseUid = Database.loginUserFirebaseId.trim();

      if (Database.isLogin && (user?.uid ?? '').trim().isNotEmpty) {
        await Database.syncLoginUserFirebaseIdWithCurrentUser();
      }

      log("user?.email  ${user?.email}");
      log("user?.uid  ${user?.uid}");
      Utils.showLog("Token requested for stored uid => $targetFirebaseUid");

      if (Database.isLogin &&
          targetFirebaseUid.isNotEmpty &&
          user?.uid != targetFirebaseUid) {
        Utils.showLog(
            "Firebase token mismatch: userUid=${user?.uid} storedUid=$targetFirebaseUid");
        return null;
      }

      bool? isExpired = await user?.getIdTokenResult().then((tokenResult) {
        DateTime expiryTime = tokenResult.expirationTime!;

        Utils.showLog("Firebase Token Expire Time => $expiryTime");

        return expiryTime.isBefore(DateTime.now());
      });

      Utils.showLog("Firebase Token Is Expire => $isExpired");

      final token = isExpired == true
          ? await user?.getIdToken(true)
          : await user?.getIdToken();

      if (Database.isLogin && (token ?? '').trim().isEmpty) {
        Utils.showLog("Firebase token empty after refresh attempt.");
      }

      Utils.showLog("Firebase Token => $token");
      return token;
    } catch (e) {
      Utils.showLog("Firebase Access Token Failed => $e");
      return null;
    }
  }
}

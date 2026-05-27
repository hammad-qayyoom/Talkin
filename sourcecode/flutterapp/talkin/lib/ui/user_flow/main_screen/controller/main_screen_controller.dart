import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:notisboard/custom/custom_web_view/web_view_screen.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/custom/random_name/random_name.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/biometric/biometric_auth_service.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_custom_token_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_uid_by_device_u_uid_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/login_api.dart';
import 'package:notisboard/services/notification_service/push_token_sync_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/model/get_firebase_custom_token_model.dart';
import 'package:notisboard/ui/user_flow/main_screen/model/get_firebase_uid_by_device_u_uid_model.dart';
import 'package:notisboard/ui/user_flow/main_screen/model/login_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/startup_helper.dart';
import 'package:notisboard/utils/utils.dart';

class MainScreenController extends GetxController {
  final formKey = GlobalKey<FormState>();
  bool isObscure = true;
  bool isLoading = false;
  bool isGuestContinueLoading = false;
  bool isGoogleLoginLoading = false;
  bool isAppleLoginLoading = false;
  bool get isSocialLoginLoading => isGoogleLoginLoading || isAppleLoginLoading;
  String randomName = '';
  String randomImage = '';
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  FetchListenerProfileModel? fetchListenerProfileModel;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    passwordController.clear();
    emailController.clear();
    randomName = CustomFetchRandomName.onGet();
    randomImage = CustomFetchRandomImage.onGet();
    super.onInit();
  }

  onClickObscure() {
    log("isObscure :: $isObscure");
    isObscure = !isObscure;
    update();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool validateLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your email");
      return false;
    }

    if (!isEmailValid(email)) {
      Utils.showToast(Get.context!, "Please enter a valid email address");
      return false;
    }

    if (password.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your password");
      return false;
    }
    //
    // if (password.length < 6) {
    //   Utils.showToast(Get.context!, "Password must be at least 6 characters");
    //   return false;
    // }

    return true;
  }

  Future<void> _refreshDeviceContext() async {
    final identity = await AppStartupHelper.getSafeDeviceId();
    await Database.onSetIdentity(identity);

    final fcmToken = await AppStartupHelper.getSafeFcmToken();
    await Database.onSetFcmToken(fcmToken ?? "");

    Utils.showLog("Device context identity => ${Database.identity}");
    Utils.showLog("Device context fcmToken => ${Database.fcmToken}");
  }

  Future<void> syncPushTokenPostLogin() async {
    final fcmToken = await AppStartupHelper.getSafeFcmToken();
    final resolvedToken = (fcmToken ?? '').trim();
    if (resolvedToken.isEmpty) return;

    await Database.onSetFcmToken(resolvedToken);
    await PushTokenSyncApi.callApi(fcmToken: resolvedToken);
  }

  void _dismissLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  void _stopLoginLoading() {
    if (isLoading) {
      isLoading = false;
      update();
    }
  }

  void _showLoginLoadingNow() {
    isLoading = true;
    update();
  }

  void _setGuestContinueLoading(bool value) {
    if (isGuestContinueLoading == value) return;
    isGuestContinueLoading = value;
    update();
  }

  void _setGoogleLoginLoading(bool value) {
    if (isGoogleLoginLoading == value) return;
    isGoogleLoginLoading = value;
    update();
  }

  void _setAppleLoginLoading(bool value) {
    if (isAppleLoginLoading == value) return;
    isAppleLoginLoading = value;
    update();
  }

  Future<void> _enterLimitedGuestBrowsing() async {
    await firebase_auth.FirebaseAuth.instance.signOut();

    Database.fetchLoginUserProfileModel = null;
    await Database.onSetIsLogin(false);
    await Database.onSetGuestMode(true);
    await Database.onSetLoginType(0);
    await Database.onSetFillProfile(false);
    await Database.onSetSeenOnboarding(true);
    await Database.onSetLoginUserFirebaseId("");
    await Database.onSetLoginUserId("");
    await Database.onSetLoginUserName("");
    await Database.onSetLoginUserNickName("");
    await Database.onSetLoginUserEmail("");
    await Database.onSetLoginUserProfilePic("");
    await Database.onSetLoginUserPhoneNumber("");
    await Database.onSetLoginUserBirthDate("");
    await Database.onSetLoginUserGender("Male");
    await Database.onSetUserCoin("0.00");
  }

  Future<String?> _getFreshAuthToken(firebase_auth.User? user) async {
    try {
      final token = await user?.getIdToken(true);
      if ((token ?? '').trim().isNotEmpty) {
        return token;
      }
    } catch (error) {
      Utils.showLog("Fresh Firebase token failed => $error");
    }

    return FirebaseAccessToken.onGet();
  }

  String _invalidEmailPasswordMessage() {
    return "Incorrect email or password. Please try again.";
  }

  String _firebaseSignInErrorMessage(
      firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return _invalidEmailPasswordMessage();
      case 'network-request-failed':
        return "Please check your internet connection and try again.";
      case 'account-exists-with-different-credential':
        return "This email already exists with another login method. Please use that login method first.";
      case 'missing-google-token':
      case 'missing-apple-id-token':
        return "Unable to verify this account. Please try again.";
      case 'too-many-requests':
        return "Too many login attempts. Please try again later.";
      case 'user-disabled':
        return "This account has been disabled.";
      default:
        return error.message?.trim().isNotEmpty == true
            ? error.message!.trim()
            : "Login failed. Please try again.";
    }
  }

  bool _isInvalidLoginMessage(String? message) {
    final normalized = (message ?? '').toLowerCase();
    return normalized.contains('invalid details') ||
        normalized.contains('invalid credential') ||
        normalized.contains("password doesn't match") ||
        normalized.contains("password does not match");
  }

  String _normalizeBackendLoginError(String? message) {
    if (_isInvalidLoginMessage(message)) {
      return _invalidEmailPasswordMessage();
    }

    final trimmed = (message ?? '').trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return EnumLocale.txtSomeThingWentWrong.name.tr;
  }

  Future<void> onGoogleLogin() async {
    if (isLoading || isGuestContinueLoading || isSocialLoginLoading) return;

    _setGoogleLoginLoading(true);
    Database.onSetDemoListener(false);
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await _refreshDeviceContext();

      final result = await GoogleAuthentication.signInWithGoogle();
      if (result == null) {
        Utils.showLog("Google Sign-In cancelled by user.");
        return;
      }

      await _completeSocialLogin(
        result: result,
        loginType: 1,
        providerName: "Google",
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      Utils.showToast(Get.context!, _firebaseSignInErrorMessage(error));
      Utils.showLog("Google Firebase Sign-In Failed => $error");
    } catch (error) {
      Utils.showToast(Get.context!, "Google sign-in failed. Please try again.");
      Utils.showLog("Google Sign-In Failed => $error");
    } finally {
      _setGoogleLoginLoading(false);
    }
  }

  Future<void> onAppleLogin() async {
    if (isLoading || isGuestContinueLoading || isSocialLoginLoading) return;

    _setAppleLoginLoading(true);
    Database.onSetDemoListener(false);
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await _refreshDeviceContext();

      final result = await AppleAuthentication.signInWithApple();
      if (result == null) {
        Utils.showLog("Apple Sign-In cancelled by user.");
        return;
      }

      await _completeSocialLogin(
        result: result,
        loginType: 5,
        providerName: "Apple",
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      Utils.showToast(Get.context!, _appleSignInErrorMessage(error));
      Utils.showLog("Apple Firebase Sign-In Failed => $error");
    } catch (error) {
      Utils.showToast(Get.context!, "Apple sign-in failed. Please try again.");
      Utils.showLog("Apple Sign-In Failed => $error");
    } finally {
      _setAppleLoginLoading(false);
    }
  }

  String _resolveSocialEmail({
    required SocialAuthenticationResult result,
    required String providerName,
  }) {
    final email = (result.email ?? result.userCredential.user?.email ?? "")
        .trim()
        .toLowerCase();

    if (email.isNotEmpty) return email;

    Utils.showLog("$providerName Sign-In email missing after Firebase login.");
    return "";
  }

  String _appleSignInErrorMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'missing-apple-id-token':
        return "Apple sign-in could not be verified. Please try again.";
      case 'operation-not-allowed':
        return "Apple sign-in is not enabled yet. Please contact support.";
      case 'network-request-failed':
        return "Please check your internet connection and try again.";
      case 'account-exists-with-different-credential':
        return "This email already exists with another login method. Please use that login method first.";
      default:
        return error.message?.trim().isNotEmpty == true
            ? error.message!.trim()
            : "Apple sign-in failed. Please try again.";
    }
  }

  String _resolveSocialName(SocialAuthenticationResult result, String email) {
    final name =
        (result.displayName ?? result.userCredential.user?.displayName ?? "")
            .trim();
    if (name.isNotEmpty) return name;

    if (email.contains('@')) {
      final emailName = email.split('@').first.trim();
      if (emailName.isNotEmpty) return emailName;
    }

    return randomName;
  }

  Future<void> _completeSocialLogin({
    required SocialAuthenticationResult result,
    required int loginType,
    required String providerName,
  }) async {
    final firebaseUser = result.userCredential.user;
    final uid = firebaseUser?.uid ?? "";
    final token = await _getFreshAuthToken(firebaseUser);
    final email = _resolveSocialEmail(
      result: result,
      providerName: providerName,
    );

    if (uid.isEmpty || (token ?? '').trim().isEmpty) {
      Utils.showToast(Get.context!,
          "Unable to verify your $providerName account. Please try again.");
      return;
    }

    if (email.isEmpty && providerName != "Apple") {
      Utils.showToast(Get.context!,
          "$providerName did not share an email. Please try again or use email login.");
      return;
    }

    final isNewUser = result.userCredential.additionalUserInfo?.isNewUser ??
        result.isLikelyNewUser;
    final displayName = _resolveSocialName(result, email);
    final profilePic = (result.photoUrl ?? firebaseUser?.photoURL ?? "").trim();

    Utils.showLog(
      "$providerName Sign-In success detected. loginType=$loginType uid=$uid email=$email isNewUser=$isNewUser",
    );

    loginModel = await LoginApi.callApi(
      countryCode: Database.selectedCountryCode,
      loginType: loginType,
      email: email,
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: isNewUser ? displayName : null,
      profilePic: isNewUser
          ? profilePic.isNotEmpty
              ? profilePic
              : randomImage
          : null,
      acceptTerms: true,
      acceptanceSource: "${providerName.toLowerCase()}_social_login",
      authToken: token,
      authUid: uid,
    ).timeout(const Duration(seconds: 15));

    if (loginModel?.status != true) {
      Utils.showToast(
          Get.context!, _normalizeBackendLoginError(loginModel?.message));
      Utils.showLog("$providerName Login Api Calling Failed !!");
      return;
    }

    Database.onSetIsLogin(true);
    Database.onSetGuestMode(false);
    Database.onSetLoginType(loginModel?.user?.loginType ?? loginType);
    Database.onSetSeenOnboarding(true);
    Database.onSetFillProfile(true);
    await syncPushTokenPostLogin();

    await onGetProfile(
        loginUserId: uid, loginType: loginType, authToken: token);

    if (loginModel?.signUp == true) {
      Database.onSetFillProfile(false);
      Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
        Database.loginUserName.isNotEmpty
            ? Database.loginUserName
            : displayName,
        Database.loginUserProfilePic.isNotEmpty
            ? Database.loginUserProfilePic
            : (profilePic.isNotEmpty ? profilePic : randomImage),
        Database.loginUserEmail.isNotEmpty ? Database.loginUserEmail : email,
      ]);
      return;
    }

    Database.onSetFillProfile(true);
    if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
      Get.offAllNamed(AppRoutes.hostBottomBar);
    } else {
      Get.offAllNamed(AppRoutes.bottomBar);
    }
  }

  /// user get profile

  Future<void> onGetProfile({
    required String loginUserId,
    required int loginType,
    String? authToken,
  }) async {
    final token = (authToken ?? '').trim().isNotEmpty
        ? authToken!.trim()
        : await FirebaseAccessToken.onGet();

    if (loginUserId.trim().isEmpty || (token ?? '').trim().isEmpty) {
      Database.onLogOut();
      return;
    }

    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
        loginUserId: loginUserId, token: token ?? '');

    if (fetchLoginUserProfileModel?.status != true) {
      final retryToken = await _getFreshAuthToken(
          firebase_auth.FirebaseAuth.instance.currentUser);
      if ((retryToken ?? '').trim().isNotEmpty && retryToken != token) {
        fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
            loginUserId: loginUserId, token: retryToken ?? '');
      }
    }

    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    log("fetchLoginUserProfileModel?.user?.id${fetchLoginUserProfileModel?.user?.id}");
    if (fetchLoginUserProfileModel?.user?.loginType != null) {
      Database.onSetIsNewUser(false);
      log("fetchLoginUserProfileModel?.user?.Email${fetchLoginUserProfileModel?.user?.email}");

      Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
      Database.onSetLoginUserFirebaseId(
          fetchLoginUserProfileModel!.user!.firebaseId!);
      Database.onSetLoginUserProfilePic(
          fetchLoginUserProfileModel?.user?.profilePic ?? "");
      Database.onSetLoginUserName(fetchLoginUserProfileModel!.user!.fullName!);
      Database.onSetLoginUserNickName(
          fetchLoginUserProfileModel?.user?.nickName ?? "");
      Database.onSetLoginUserEmail(fetchLoginUserProfileModel!.user!.email!);
      Database.onSetLoginUserCountry(
          fetchLoginUserProfileModel!.user!.country!);
      Database.onSetLoginUserCountryFlag(
          fetchLoginUserProfileModel!.user!.countryFlag!);
      Database.onSetLoginUserBirthDate(
          fetchLoginUserProfileModel?.user?.birthDate ?? "");
      Database.onSetLoginUserGender(
          fetchLoginUserProfileModel?.user?.gender ?? "Male");
      Database.onSetLoginUserPhoneNumber(
          fetchLoginUserProfileModel?.user?.phoneNumber ?? "");
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
      log("Database.loginUserId  ${Database.loginUserId}");
      log("Database.loginUserEmail  ${Database.loginUserEmail}");
      log("Database.loginUserFirebaseId  ${Database.loginUserFirebaseId}");
      log("Database.image  ${Database.loginUserProfilePic}");

      if (fetchLoginUserProfileModel?.user?.isListener == true) {
        fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
          loginListenerId:
              Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
        );
        Database.onSetLoginUserId(fetchListenerProfileModel!.data!.id!);
        if (fetchListenerProfileModel?.status == false) {
          Utils.showLog(fetchListenerProfileModel?.message ?? "");
        }
        Database.fetchListenerProfileModel = fetchListenerProfileModel;
      }

      if (Database.isLogin) {
        final biometricEnabled = await BiometricAuthService.isEnabled();
        if (biometricEnabled) {
          await BiometricAuthService.bindSessionForCurrentUser();
        }
      }
    } else {
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Get Profile Api Calling Failed !!");
    }
  }

  /// QuickLogin

  // void onQuickLogin() async {
  //   Database.onSetDemoListener(false);
  //
  //   if (selectedValue != 1) {
  //     Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
  //     return;
  //   }
  //   final identity = (await MobileDeviceIdentifier().getDeviceId())!;
  //   final fcmToken = await FirebaseMessaging.instance.getToken();
  //   Database.onSetFcmToken(fcmToken ?? "");
  //   Database.onSetIdentity(identity);
  //
  //   log("Database.identity :: ${Database.identity}");
  //   log("Database.fcmToken :: ${Database.fcmToken}");
  //
  //   Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...
  //
  //   await AnonymousAuthentication.signInWithAnonymous(); // Anonymous Login...
  //   final user = FirebaseAuth.instance.currentUser;
  //   final uid = user?.uid ?? "";
  //
  //   Utils.showLog("Anonymous Login uid :: $uid");
  //
  //   loginModel = await LoginApi.callApi(
  //     countryCode: Database.selectedCountryCode,
  //     loginType: 2,
  //     email: Database.identity,
  //     identity: Database.identity,
  //     fcmToken: Database.fcmToken,
  //     userName: randomName,
  //     profilePic: randomImage,
  //   );
  //
  //   // Get.back(); // Stop Loading...
  //
  //   if (loginModel?.status == true) {
  //     Database.onSetIsLogin(true);
  //     Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
  //     Database.onSetSeenOnboarding(true);
  //     Database.onSetFillProfile(true);
  //
  //     await onGetProfile(loginUserId: uid, loginType: 2);
  //
  //     if (loginModel?.signUp == true) {
  //       Database.onSetFillProfile(false);
  //
  //       log("Database.loginUserName  ${Database.loginUserName}");
  //       log("Database.loginUserProfilePic  ${Database.loginUserProfilePic}");
  //       log("Database.loginUserEmail  ${Database.loginUserEmail}");
  //
  //       Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [Database.loginUserName, Database.loginUserProfilePic, Database.loginUserEmail]);
  //     } else {
  //       // get profile api
  //
  //       Database.onSetFillProfile(true);
  //       await onGetProfile(loginUserId: Database.loginUserFirebaseId, loginType: 2);
  //       // route bottom bar
  //       // Get.toNamed(AppRoutes.bottomBar);
  //       if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
  //         Get.toNamed(AppRoutes.hostBottomBar);
  //       } else {
  //         Get.toNamed(AppRoutes.bottomBar);
  //       }
  //     }
  //   } else {
  //     Utils.showLog(loginModel?.message ?? "");
  //     Utils.showLog(" login Api Calling Failed !!");
  //   }
  // }

  GetFirebaseUidByDeviceUUidModel? getFirebaseUidByDeviceUUidModel;
  GetFirebaseCustomTokenModel? getFirebaseCustomTokenModel;

  void onQuickLogin1() async {
    Database.onSetDemoListener(false);

    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    Utils.showLog("Database.identity>>>>>>>>>>>>>>>>>>${Database.identity}");
    try {
      await _refreshDeviceContext();

      /// Step 1: Get Firebase UID by Device UUID
      getFirebaseUidByDeviceUUidModel = await GetFirebaseUidByDeviceApi.callApi(
        loginType: 2,
        deviceUuid: Database.identity, // your device id
      );

      if (getFirebaseUidByDeviceUUidModel?.status == true) {
        // EXISTING USER - Use custom token to sign in with same Firebase UID
        Utils.showLog("Existing device found!");
        Utils.showLog(
            "Firebase UID => ${getFirebaseUidByDeviceUUidModel?.firebaseId}");

        /// Step 2: Get Firebase custom token
        final getFirebaseCustomTokenModel =
            await GetFirebaseCustomTokenApi.callApi(
          firebaseUid: getFirebaseUidByDeviceUUidModel?.firebaseId ?? "",
        );

        if (getFirebaseCustomTokenModel?.status == true) {
          final String customToken =
              getFirebaseCustomTokenModel?.customToken ?? "";
          Utils.showLog("Firebase Custom Token => $customToken");

          /// Step 3: Sign in with custom token (CRITICAL - this maintains same user!)
          final firebase_auth.UserCredential userCredential =
              await firebase_auth.FirebaseAuth.instance
                  .signInWithCustomToken(customToken);

          Utils.showLog(
              "Signed in with existing Firebase user: ${userCredential.user?.uid}");

          // Initialize database and proceed with login flow
          // Database.init();
          String? fcmToken = await AppStartupHelper.getSafeFcmToken();
          await Database.onSetFcmToken(fcmToken ?? "");

          final uid = userCredential.user?.uid ?? "";
          final token = await FirebaseAccessToken.onGet();

          // For existing users, pass isNewUser = false
          await _completeLoginFlow(uid, token, fcmToken, isNewUser: false);
        } else {
          _dismissLoadingDialog();
          Utils.showToast(Get.context!, "Failed to get custom token");
        }
      } else {
        // NEW USER - Create anonymous user and let LoginApi register the device
        Utils.showLog("New device detected - creating new anonymous user");

        /// Step 1: Create anonymous Firebase user
        final firebase_auth.UserCredential userCredential =
            await firebase_auth.FirebaseAuth.instance.signInAnonymously();

        final String firebaseUid = userCredential.user?.uid ?? "";
        Utils.showLog("New Firebase UID created => $firebaseUid");

        /// Step 2: LoginApi will handle device registration automatically
        // Database.init();
        String? fcmToken = await AppStartupHelper.getSafeFcmToken();
        await Database.onSetFcmToken(fcmToken ?? "");
        final token = await FirebaseAccessToken.onGet();

        // For new users, pass isNewUser = true
        await _completeLoginFlow(firebaseUid, token, fcmToken, isNewUser: true);
      }
    } catch (e) {
      _dismissLoadingDialog();
      Utils.showLog("Login error: $e");
      Utils.showToast(Get.context!, "Login failed. Please try again.");
    }
  }

  Future<void> onContinueAsGuest() async {
    if (isGuestContinueLoading) return;

    _setGuestContinueLoading(true);
    Database.onSetDemoListener(false);
    var usedLimitedFallback = false;

    try {
      final identity = await AppStartupHelper.getSafeDeviceId();
      if (identity.isEmpty) {
        throw Exception('Device identity is unavailable.');
      }

      Database.onSetIdentity(identity);
      final fcmToken = await AppStartupHelper.getSafeFcmToken();
      Database.onSetFcmToken(fcmToken ?? "");

      await _enterLimitedGuestBrowsing();
    } catch (error) {
      Utils.showLog("Guest browsing setup failed => $error");
      usedLimitedFallback = true;

      await _enterLimitedGuestBrowsing();
    } finally {
      _setGuestContinueLoading(false);
    }

    Get.offAllNamed(AppRoutes.bottomBar);
    if (usedLimitedFallback) {
      Utils.showToast(Get.context!, "Guest browsing limited mode enabled.");
    }
  }

  Future<void> _completeLoginFlow(String uid, String? token, String? fcmToken,
      {required bool isNewUser}) async {
    loginModel = await LoginApi.callApi(
      countryCode: Database.selectedCountryCode,
      loginType: 2,
      email: Database.identity,
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: isNewUser ? randomName : "",
      profilePic: isNewUser ? randomImage : "",
    );

    // Get.back(); // Stop Loading...

    if (loginModel?.status == true) {
      Database.onSetIsLogin(true);
      Database.onSetGuestMode(false);
      Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
      Database.onSetSeenOnboarding(true);
      Database.onSetFillProfile(true);
      await syncPushTokenPostLogin();

      await onGetProfile(loginUserId: uid, loginType: 2);

      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);

        log("Database.loginUserName  ${Database.loginUserName}");
        log("Database.loginUserProfilePic  ${Database.loginUserProfilePic}");
        log("Database.loginUserEmail  ${Database.loginUserEmail}");

        _dismissLoadingDialog();
        Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
          Database.loginUserName,
          Database.loginUserProfilePic,
          Database.loginUserEmail
        ]);
      } else {
        // get profile api

        Database.onSetFillProfile(true);
        await onGetProfile(
            loginUserId: Database.loginUserFirebaseId, loginType: 2);
        // route bottom bar
        // Get.toNamed(AppRoutes.bottomBar);
        _dismissLoadingDialog();
        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          Get.offAllNamed(AppRoutes.hostBottomBar);
        } else {
          Get.offAllNamed(AppRoutes.bottomBar);
        }
      }
    } else {
      _dismissLoadingDialog();
      Utils.showLog(loginModel?.message ?? "");
      Utils.showLog(" login Api Calling Failed !!");
    }
  }

  /// email password login user

  Future<void> onClickSignIn() async {
    if (isLoading) {
      return;
    }

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.desEnterEmail.name.tr);
      return;
    } else if (password.isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.desEnterPassword.name.tr);
      return;
    }

    try {
      _showLoginLoadingNow();

      Database.onSetDemoListener(false);
      FocusManager.instance.primaryFocus?.unfocus();
      Utils.showLog("Email => $email");
      Utils.showLog("Password => $password");

      await _refreshDeviceContext();

      Database.onSetUserExist(true);
      Utils.showLog("Database.userExist :: ${Database.userExist}");

      final firebase_auth.UserCredential userCredential =
          await firebase_auth.FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: email,
                password: password,
              )
              .timeout(const Duration(seconds: 12));

      final firebaseUID = userCredential.user?.uid;
      final token = await _getFreshAuthToken(userCredential.user)
          .timeout(const Duration(seconds: 8));

      Utils.showLog("Firebase UID => $firebaseUID");
      Utils.showLog("Firebase Token => $token");

      if (firebaseUID == null || firebaseUID.isEmpty) {
        _stopLoginLoading();
        Utils.showToast(
            Get.context!, "Unable to verify your account. Please try again.");
        return;
      }

      if ((token ?? '').isEmpty) {
        _stopLoginLoading();
        Utils.showToast(Get.context!,
            "Unable to authenticate right now. Please try again.");
        return;
      }

      loginModel = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 4,
        email: email,
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        password: password,
        authToken: token,
        authUid: firebaseUID,
      ).timeout(const Duration(seconds: 12));

      if (loginModel?.status != true &&
          _isInvalidLoginMessage(loginModel?.message) &&
          Database.identity != firebaseUID) {
        Utils.showLog(
            "Retry login with firebase uid as identity due to invalid-details response.");

        loginModel = await LoginApi.callApi(
          countryCode: Database.selectedCountryCode,
          loginType: 4,
          email: email,
          identity: firebaseUID,
          fcmToken: Database.fcmToken,
          password: password,
          authToken: token,
          authUid: firebaseUID,
        ).timeout(const Duration(seconds: 12));

        if (loginModel?.status == true) {
          await Database.onSetIdentity(firebaseUID);
        }
      }

      if (loginModel?.status != true) {
        _stopLoginLoading();
        Utils.showToast(
            Get.context!, _normalizeBackendLoginError(loginModel?.message));
        Utils.showLog("Login API call failed");
        return;
      }

      Database.onSetIsLogin(true);
      Database.onSetGuestMode(false);
      Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
      Database.onSetSeenOnboarding(true);
      Database.onSetFillProfile(true);
      await syncPushTokenPostLogin();

      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);
        _stopLoginLoading();
        Get.offAllNamed(
          AppRoutes.fillProfileScreen,
          arguments: [
            Database.loginUserName,
            Database.loginUserProfilePic,
            Database.loginUserEmail
          ],
        );
      } else {
        Database.onSetFillProfile(true);
        await onGetProfile(
          loginUserId: userCredential.user!.uid,
          loginType: 4,
          authToken: token,
        );
        // Get.toNamed(AppRoutes.bottomBar);
        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          _stopLoginLoading();
          Get.offAllNamed(AppRoutes.hostBottomBar);
        } else {
          _stopLoginLoading();
          Get.offAllNamed(AppRoutes.bottomBar);
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _stopLoginLoading();
      Utils.showToast(Get.context!, _firebaseSignInErrorMessage(e));
      Utils.showLog("Firebase Sign-In Failed => $e");
    } catch (e) {
      _stopLoginLoading();
      Utils.showToast(Get.context!,
          "Login failed. Please check your details and try again.");
      Utils.showLog("Sign In Failed => $e");
    }
  }

  Future<void> onClickPrivacyPolicy() async {
    final String privacyPolicyUrl =
        Database.appConfigurationModel?.data?.userPrivacyPolicyUrl ?? '';

    if (privacyPolicyUrl.isNotEmpty) {
      Get.to(
          () => WebViewScreen(url: privacyPolicyUrl, screen: "Privacy Policy"));
    } else {
      log('Invalid privacy policy URL');
    }
  }
}

class SocialAuthenticationResult {
  const SocialAuthenticationResult({
    required this.userCredential,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isLikelyNewUser = false,
  });

  final firebase_auth.UserCredential userCredential;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isLikelyNewUser;
}

class GoogleAuthentication {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  static Future<SocialAuthenticationResult?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    final googleAuth = await googleUser.authentication;
    if ((googleAuth.idToken ?? '').isEmpty &&
        (googleAuth.accessToken ?? '').isEmpty) {
      throw firebase_auth.FirebaseAuthException(
        code: 'missing-google-token',
        message: 'Google did not return a valid authentication token.',
      );
    }

    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final response = await firebase_auth.FirebaseAuth.instance
        .signInWithCredential(credential);

    Utils.showLog(
      "Google Login isNewUser => ${response.additionalUserInfo?.isNewUser} Email => ${googleUser.email}",
    );

    return SocialAuthenticationResult(
      userCredential: response,
      email: googleUser.email,
      displayName: googleUser.displayName,
      photoUrl: googleUser.photoUrl,
      isLikelyNewUser: response.additionalUserInfo?.isNewUser ?? false,
    );
  }
}

class AppleAuthentication {
  static Future<SocialAuthenticationResult?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final identityToken = appleCredential.identityToken;
      if ((identityToken ?? '').isEmpty) {
        throw firebase_auth.FirebaseAuthException(
          code: 'missing-apple-id-token',
          message: 'Apple did not return a valid identity token.',
        );
      }

      final oauthCredential = firebase_auth.OAuthProvider("apple.com")
          .credential(
        idToken: identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final response = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ]
          .where((value) => (value ?? '').trim().isNotEmpty)
          .map((value) => value!.trim())
          .join(' ')
          .trim();
      final tokenPayload = _decodeJwtPayload(identityToken ?? "");
      final tokenEmail = (tokenPayload["email"] ?? "").toString().trim();

      Utils.showLog(
        "Apple Login isNewUser => ${response.additionalUserInfo?.isNewUser} Email => ${appleCredential.email ?? response.user?.email ?? tokenEmail}",
      );

      return SocialAuthenticationResult(
        userCredential: response,
        email: appleCredential.email ?? response.user?.email ?? tokenEmail,
        displayName:
            fullName.isNotEmpty ? fullName : response.user?.displayName,
        photoUrl: response.user?.photoURL,
        isLikelyNewUser: response.additionalUserInfo?.isNewUser ?? false,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      Utils.showLog("Apple Login Authorization Error => $error");
      rethrow;
    } catch (error) {
      Utils.showLog("Apple Login Error => $error");
      rethrow;
    }
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final jsonPayload = json.decode(decoded);
      return jsonPayload is Map<String, dynamic> ? jsonPayload : {};
    } catch (_) {
      return {};
    }
  }
}

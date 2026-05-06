import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:notisboard/custom/custom_web_view/web_view_screen.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/custom/random_name/random_name.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_custom_token_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_uid_by_device_u_uid_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/login_api.dart';
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

  void _dismissLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  String _invalidEmailPasswordMessage() {
    return "Incorrect email or password. Please try again.";
  }

  String _firebaseSignInErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return _invalidEmailPasswordMessage();
      case 'network-request-failed':
        return "Please check your internet connection and try again.";
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

  //apple login
  Future<void> onAppleLogin() async {
    Get.dialog(const LoadingWidget(),
        barrierDismissible: false); // Start Loading...

    await _refreshDeviceContext();

    UserCredential? userCredential =
        await AppleAuthentication.signInWithApple(); // Apple Login...

    if (userCredential == null) {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(Get.context!, "Apple Login Failed.");
      Utils.showLog("Apple Login Failed !! Credential missing");
      return;
    }

    bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? true;
    final appleEmail = (userCredential.additionalUserInfo?.profile?["email"] ??
            userCredential.user?.email ??
            "")
        .toString();

    if (appleEmail.isNotEmpty) {
      // Calling Sign Up Api...

      // Apple often doesn't provide name, use email or random name
      String displayName = appleEmail.split('@').first;

      loginModel = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 5,
        email: appleEmail,
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: isNewUser ? displayName : null,
        profilePic: isNewUser
            ? Database.loginUserProfilePic.isEmpty
                ? randomImage
                : Database.loginUserProfilePic
            : null,
      );

      if (loginModel?.status == true) {
        if (Get.isDialogOpen ?? false) Get.back();
        Database.onSetIsLogin(true);
        Database.onSetGuestMode(false);
        Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
        Database.onSetSeenOnboarding(true);
        Database.onSetFillProfile(true);

        await onGetProfile(loginUserId: userCredential.user!.uid, loginType: 5);

        if (loginModel?.signUp == true) {
          Database.onSetFillProfile(false);

          Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
            Database.loginUserName,
            Database.loginUserProfilePic,
            Database.loginUserEmail,
          ]);
        } else {
          Database.onSetFillProfile(true);
          await onGetProfile(
              loginUserId: userCredential.user!.uid, loginType: 5);

          if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
            Get.toNamed(AppRoutes.hostBottomBar);
          } else {
            Get.toNamed(AppRoutes.bottomBar);
          }
        }
      } else {
        if (Get.isDialogOpen ?? false) Get.back();
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Login Api Calling Failed !!");
      }

      // Get.back();
    } else {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(Get.context!, "Apple Login Failed: No email found.");
      Utils.showLog("Apple Login Failed !! Email missing in response");
    }
  }

  /// user get profile

  Future<void> onGetProfile(
      {required String loginUserId, required int loginType}) async {
    final token = await FirebaseAccessToken.onGet();

    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
        loginUserId: loginUserId, token: token ?? '');
    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    log("fetchLoginUserProfileModel?.user?.id${fetchLoginUserProfileModel?.user?.id}");
    if (loginUserId.trim().isNotEmpty && token!.trim().isNotEmpty) {
      if (fetchLoginUserProfileModel?.user?.loginType != null) {
        Database.onSetIsNewUser(false);
        log("fetchLoginUserProfileModel?.user?.Email${fetchLoginUserProfileModel?.user?.email}");

        Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
        Database.onSetLoginUserFirebaseId(
            fetchLoginUserProfileModel!.user!.firebaseId!);
        Database.onSetLoginUserProfilePic(
            fetchLoginUserProfileModel?.user?.profilePic ?? "");
        Database.onSetLoginUserName(
            fetchLoginUserProfileModel!.user!.fullName!);
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
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Get Profile Api Calling Failed !!");
      }
    } else {
      Database.onLogOut();
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
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCustomToken(customToken);

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
          Get.back();
          Utils.showToast(Get.context!, "Failed to get custom token");
        }
      } else {
        // NEW USER - Create anonymous user and let LoginApi register the device
        Utils.showLog("New device detected - creating new anonymous user");

        /// Step 1: Create anonymous Firebase user
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInAnonymously();

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
      Get.back();
      Utils.showLog("Login error: $e");
      Utils.showToast(Get.context!, "Login failed. Please try again.");
    }
  }

  Future<void> onContinueAsGuest() async {
    Database.onSetDemoListener(false);
    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    try {
      final identity = await AppStartupHelper.getSafeDeviceId();
      if (identity.isEmpty) {
        throw Exception('Device identity is unavailable.');
      }

      Database.onSetIdentity(identity);
      final fcmToken = await AppStartupHelper.getSafeFcmToken();
      Database.onSetFcmToken(fcmToken ?? "");

      final guestUidState = await _resolveGuestFirebaseUid(identity);

      getFirebaseCustomTokenModel = await GetFirebaseCustomTokenApi.callApi(
        firebaseUid: guestUidState.firebaseUid,
      );

      final customToken =
          (getFirebaseCustomTokenModel?.customToken ?? '').trim();
      if (getFirebaseCustomTokenModel?.status != true || customToken.isEmpty) {
        throw Exception(
            getFirebaseCustomTokenModel?.message ?? 'Failed to create token');
      }

      final UserCredential credential =
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
      final loginUid =
          (credential.user?.uid ?? guestUidState.firebaseUid).trim();
      if (loginUid.isEmpty) {
        throw Exception('Guest Firebase UID missing after auth.');
      }

      final loggedIn = await _completeGuestLoginFlow(
        uid: loginUid,
        isNewUser: !guestUidState.isExistingUser,
      );

      if (!loggedIn) {
        throw Exception('Guest login failed.');
      }

      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.bottomBar);
    } catch (error) {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showLog("Guest browsing setup failed => $error");

      await Database.onSetIsLogin(false);
      await Database.onSetGuestMode(true);
      await Database.onSetFillProfile(false);
      await Database.onSetSeenOnboarding(true);

      Get.offAllNamed(AppRoutes.bottomBar);
      Utils.showToast(Get.context!, "Guest browsing limited mode enabled.");
    }
  }

  Future<_GuestFirebaseUidState> _resolveGuestFirebaseUid(
      String identity) async {
    getFirebaseUidByDeviceUUidModel = await GetFirebaseUidByDeviceApi.callApi(
      loginType: 2,
      deviceUuid: identity,
    );

    final existingFirebaseUid =
        (getFirebaseUidByDeviceUUidModel?.firebaseId ?? '').trim();
    final isExistingUser = getFirebaseUidByDeviceUUidModel?.status == true &&
        existingFirebaseUid.isNotEmpty;

    if (isExistingUser) {
      return _GuestFirebaseUidState(
        firebaseUid: existingFirebaseUid,
        isExistingUser: true,
      );
    }

    return _GuestFirebaseUidState(
      firebaseUid: _buildGuestFirebaseUid(identity),
      isExistingUser: false,
    );
  }

  String _buildGuestFirebaseUid(String identity) {
    final normalized =
        identity.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = normalized.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : normalized;
    final trimmedSuffix = suffix.length > 56 ? suffix.substring(0, 56) : suffix;
    return 'guest_$trimmedSuffix';
  }

  Future<bool> _completeGuestLoginFlow({
    required String uid,
    required bool isNewUser,
  }) async {
    loginModel = await LoginApi.callApi(
      countryCode: Database.selectedCountryCode,
      loginType: 2,
      email: Database.identity,
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: isNewUser ? randomName : null,
      profilePic: isNewUser ? randomImage : null,
      age: 25,
      birthDate: "2000-01-01",
      acceptTerms: true,
      acceptanceSource: "guest",
    );

    if (loginModel?.status != true) {
      Utils.showLog(loginModel?.message ?? "Guest login api failed");
      return false;
    }

    await Database.onSetIsLogin(true);
    await Database.onSetGuestMode(true);
    await Database.onSetLoginType(2);
    await Database.onSetSeenOnboarding(true);
    await Database.onSetFillProfile(true);

    await onGetProfile(loginUserId: uid, loginType: 2);

    final hasProfile = Database.fetchLoginUserProfileModel?.status == true &&
        Database.fetchLoginUserProfileModel?.user?.firebaseId != null;
    if (!hasProfile) {
      Utils.showLog("Guest profile fetch failed after login.");
      return false;
    }

    await Database.onSetIsLogin(true);
    await Database.onSetGuestMode(true);
    await Database.onSetLoginType(2);
    await Database.onSetSeenOnboarding(true);
    await Database.onSetFillProfile(true);
    return true;
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

      await onGetProfile(loginUserId: uid, loginType: 2);

      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);

        log("Database.loginUserName  ${Database.loginUserName}");
        log("Database.loginUserProfilePic  ${Database.loginUserProfilePic}");
        log("Database.loginUserEmail  ${Database.loginUserEmail}");

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
        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          Get.toNamed(AppRoutes.hostBottomBar);
        } else {
          Get.toNamed(AppRoutes.bottomBar);
        }
      }
    } else {
      Utils.showLog(loginModel?.message ?? "");
      Utils.showLog(" login Api Calling Failed !!");
    }
  }

  /// email password login user

  Future<void> onClickSignIn() async {
    Database.onSetDemoListener(false);
    FocusManager.instance.primaryFocus?.unfocus();
    Utils.showLog("Email => ${emailController.text}");
    Utils.showLog("Password => ${passwordController.text}");
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.desEnterEmail.name.tr);
      return;
    } else if (password.isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.desEnterPassword.name.tr);
      return;
    }

    await _refreshDeviceContext();

    try {
      Get.dialog(const LoadingWidget(), barrierDismissible: false);

      Database.onSetUserExist(true);
      Utils.showLog("Database.userExist :: ${Database.userExist}");

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .timeout(const Duration(seconds: 12));

      final token =
          await FirebaseAccessToken.onGet().timeout(const Duration(seconds: 8));
      final firebaseUID = userCredential.user?.uid;

      Utils.showLog("Firebase UID => $firebaseUID");
      Utils.showLog("Firebase Token => $token");

      if (firebaseUID == null || firebaseUID.isEmpty) {
        _dismissLoadingDialog();
        Utils.showToast(
            Get.context!, "Unable to verify your account. Please try again.");
        return;
      }

      if ((token ?? '').isEmpty) {
        _dismissLoadingDialog();
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
        _dismissLoadingDialog();
        isLoading = false;
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

      Get.back(); // Stop loading

      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);
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
        await onGetProfile(loginUserId: userCredential.user!.uid, loginType: 4);
        // Get.toNamed(AppRoutes.bottomBar);
        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
            loginListenerId:
                Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
          );
          Database.onSetLoginUserId(fetchListenerProfileModel!.data!.id!);
          if (fetchListenerProfileModel?.status == false) {
            Utils.showLog(fetchListenerProfileModel?.message ?? "");
          }
          Database.fetchListenerProfileModel = fetchListenerProfileModel;

          Get.toNamed(AppRoutes.hostBottomBar);
        } else {
          Get.toNamed(AppRoutes.bottomBar);
        }
      }
    } on FirebaseAuthException catch (e) {
      _dismissLoadingDialog();
      isLoading = false;
      Utils.showToast(Get.context!, _firebaseSignInErrorMessage(e));
      Utils.showLog("Firebase Sign-In Failed => $e");
    } catch (e) {
      _dismissLoadingDialog();
      isLoading = false;
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

class _GuestFirebaseUidState {
  final String firebaseUid;
  final bool isExistingUser;

  const _GuestFirebaseUidState({
    required this.firebaseUid,
    required this.isExistingUser,
  });
}

class AppleAuthentication {
  static Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ]);
      final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode);
      final response =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      Utils.showLog(
          "✅ Apple Login isNewUser => ${response.additionalUserInfo?.isNewUser} Email => ${response.additionalUserInfo?.profile?["email"] ?? ""}");

      return response;
    } catch (error) {
      Utils.showLog("❌ Apple Login Error => $error");
    }
    return null;
  }
}

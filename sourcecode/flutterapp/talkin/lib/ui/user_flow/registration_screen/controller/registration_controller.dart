import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/custom/custom_web_view/web_view_screen.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/notification_service/push_token_sync_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/login_api.dart';
import 'package:notisboard/ui/user_flow/main_screen/model/login_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/startup_helper.dart';
import 'package:notisboard/utils/utils.dart';

class RegistrationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  bool isObscure = true;
  bool isObscure1 = true;
  bool isCheck = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  DateTime? selectedBirthDate;
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  // MainScreenController mainScreenController = Get.put(MainScreenController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void onClickObscure() {
    log("isObscure :: $isObscure");
    isObscure = !isObscure;
    update();
  }

  void onClickObscure1() {
    log("isObscure1 :: $isObscure1");
    isObscure1 = !isObscure1;
    update();
  }

  void onClickCheck() {
    log("isCheck:: $isCheck");
    isCheck = !isCheck;
    update([Constant.idAcceptTerms]);
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

  Future<void> onTapBirthDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        selectedBirthDate ?? DateTime(now.year - 18, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate == null) return;

    selectedBirthDate = pickedDate;
    birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    update();
  }

  int _calculateAge(DateTime birthDate) {
    final DateTime now = DateTime.now();
    int age = now.year - birthDate.year;

    final bool hasNotHadBirthdayThisYear = now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day);

    if (hasNotHadBirthdayThisYear) {
      age -= 1;
    }

    return age;
  }

  bool validateRegistration() {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return false;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final rePassword = confirmPassController.text.trim();

    if (name.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your full name");
      return false;
    }

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

    if (password.length < 6) {
      Utils.showToast(Get.context!, "Password must be at least 6 characters");
      return false;
    }

    if (rePassword.isEmpty) {
      Utils.showToast(Get.context!, "Please re-enter your password");
      return false;
    }

    if (rePassword != password) {
      Utils.showToast(Get.context!, "Passwords do not match");
      return false;
    }

    if (!isCheck) {
      Utils.showToast(
          Get.context!, "Please agree to the Privacy Policy to proceed.");
      return false;
    }

    return true;
  }

  // Future<void> signUpWithEmailPassword() async {
  //   try {
  //     // Firebase signup
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );
  //
  //     log("Signup successful! UID: ${userCredential.user?.uid}");
  //     log("Signup successful! email: ${userCredential.user?.email}");
  //
  //     // Get identity and FCM token
  //     final identity = (await MobileDeviceIdentifier().getDeviceId())!;
  //     final fcmToken = await FirebaseMessaging.instance.getToken();
  //
  //     Database.onSetIdentity(identity);
  //     Database.onSetFcmToken(fcmToken ?? "");
  //
  //     log("Database.identity :: ${Database.identity}");
  //     log("Database.fcmToken :: ${Database.fcmToken}");
  //
  //     // Call your login API
  //     Get.dialog(LoadingWidget(), barrierDismissible: false);
  //     Database.onSetUserExist(false);
  //
  //     loginModel = await LoginApi.callApi(
  //       countryCode: Database.selectedCountryCode,
  //       loginType: 4, // Use 2 for email/password login
  //       email: userCredential.user?.email ?? "",
  //       identity: Database.identity,
  //       fcmToken: Database.fcmToken,
  //       userName: nameController.text,
  //       // password: passwordController.text,
  //       confirmPassword: confirmPassController.text,
  //     );
  //
  //     if (loginModel?.status == true) {
  //       Database.onSetIsLogin(true);
  //       Database.onSetSeenOnboarding(true);
  //       Database.onSetFillProfile(true);
  //
  //       Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
  //
  //       await onGetProfile(
  //         loginUserId: userCredential.user!.uid,
  //         loginType: 4,
  //       );
  //
  //       if (loginModel?.signUp == true) {
  //         Database.onSetFillProfile(false);
  //         Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
  //           Database.loginUserName,
  //           Database.loginUserProfilePic,
  //           Database.loginUserEmail,
  //         ]);
  //       } else {
  //         Database.onSetFillProfile(true);
  //         await onGetProfile(
  //           loginUserId: userCredential.user!.uid,
  //           loginType: 4,
  //         );
  //         // Get.toNamed(AppRoutes.bottomBar);
  //         if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
  //           Get.toNamed(AppRoutes.hostBottomBar);
  //         } else {
  //           Get.toNamed(AppRoutes.bottomBar);
  //         }
  //       }
  //     } else {
  //       Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
  //       Utils.showLog("Login Api Calling Failed !!");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use') {
  //       Utils.showToast(Get.context!, "This email is already in use.");
  //     } else if (e.code == 'weak-password') {
  //       Utils.showToast(Get.context!, "Password is too weak.");
  //     } else {
  //       Utils.showToast(Get.context!, "Registration failed: ${e.message}");
  //     }
  //   } catch (e) {
  //     log("Signup failed: $e");
  //     // log("Error: ${e.message}");
  //   }
  // }

  var isBusy = false;

  Future<void> _prepareDeviceContext() async {
    final identity = await AppStartupHelper.getSafeDeviceId();
    await Database.onSetIdentity(identity);

    final fcmToken = await AppStartupHelper.getSafeFcmToken();
    await Database.onSetFcmToken(fcmToken ?? "");
  }

  Future<void> _syncPushTokenPostLogin() async {
    final fcmToken = await AppStartupHelper.getSafeFcmToken();
    final resolvedToken = (fcmToken ?? '').trim();
    if (resolvedToken.isEmpty) return;

    await Database.onSetFcmToken(resolvedToken);
    await PushTokenSyncApi.callApi(fcmToken: resolvedToken);
  }

  Future<void> _cleanupCreatedFirebaseUser(
      UserCredential? userCredential) async {
    try {
      await userCredential?.user?.delete();
    } catch (error) {
      Utils.showLog("Firebase cleanup skipped => $error");
    }

    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Future<void> _handleEmailAuthSuccess(UserCredential userCredential) async {
    Database.onSetIsLogin(true);
    Database.onSetGuestMode(false);
    Database.onSetSeenOnboarding(true);
    Database.onSetFillProfile(true);

    Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
    await _syncPushTokenPostLogin();

    await onGetProfile(
      loginUserId: userCredential.user!.uid,
      loginType: 4,
    );

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
        loginUserId: userCredential.user!.uid,
        loginType: 4,
      );

      if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
        Get.toNamed(AppRoutes.hostBottomBar);
      } else {
        Get.toNamed(AppRoutes.bottomBar);
      }
    }
  }

  Future<bool> _syncEmailUserWithBackend(UserCredential userCredential) async {
    Database.onSetUserExist(false);
    final birthDate = selectedBirthDate ?? DateTime(2000);

    loginModel = await LoginApi.callApi(
      countryCode: Database.selectedCountryCode,
      loginType: 4,
      email: userCredential.user?.email ?? "",
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: nameController.text.trim(),
      confirmPassword: confirmPassController.text.trim(),
      birthDate: DateFormat('yyyy-MM-dd').format(birthDate),
      age: _calculateAge(birthDate),
      acceptTerms: true,
      acceptanceSource: "signup_email",
      referralCode: referralCodeController.text.trim(),
    );

    if (loginModel?.status != true) {
      return false;
    }

    await _handleEmailAuthSuccess(userCredential);
    return true;
  }

  Future<void> signUpWithEmailPassword() async {
    if (isBusy) return;
    isBusy = true;

    FocusManager.instance.primaryFocus?.unfocus();

    Get.dialog(LoadingWidget(), barrierDismissible: false);

    UserCredential? createdUserCredential;

    try {
      await _prepareDeviceContext();

      createdUserCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final bool synced =
          await _syncEmailUserWithBackend(createdUserCredential);

      if (!synced) {
        await _cleanupCreatedFirebaseUser(createdUserCredential);
        Utils.showToast(Get.context!,
            loginModel?.message ?? "Registration failed. Please try again.");
      }
    } on FirebaseAuthException catch (e) {
      Utils.showLog('>>>>>>>>>>>>>>>>>>>>>$e');

      if (e.code == 'email-already-in-use') {
        try {
          await _prepareDeviceContext();

          final UserCredential existingUserCredential =
              await _auth.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

          final bool synced =
              await _syncEmailUserWithBackend(existingUserCredential);
          if (!synced) {
            Utils.showToast(
                Get.context!,
                loginModel?.message ??
                    "Registration sync failed. Please try again.");
          }
        } on FirebaseAuthException catch (signInError) {
          if (signInError.code == 'wrong-password' ||
              signInError.code == 'invalid-credential') {
            Utils.showToast(Get.context!,
                "This email is already registered. Please login with the correct password.");
          } else {
            Utils.showToast(
                Get.context!, "Registration failed: ${signInError.message}");
          }
        } catch (error) {
          Utils.showLog("Email in use recovery failed => $error");
          Utils.showToast(Get.context!,
              "Registration failed. Please login or reset password.");
        }
      } else if (e.code == 'weak-password') {
        Utils.showToast(Get.context!, "Password is too weak.");
      } else {
        Utils.showToast(Get.context!, "Registration failed: ${e.message}");
      }
    } catch (e, s) {
      Utils.showLog('Registration Exception: $e\n$s');
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(Get.context!, "Registration failed: $e");
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
      isBusy = false;
    }
  }

  Future<void> onGetProfile(
      {required String loginUserId, required int loginType}) async {
    final token = await FirebaseAccessToken.onGet();

    // Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
        loginUserId: loginUserId, token: token ?? '');

    log("fetchLoginUserProfileModel?.user?.id  :: ${fetchLoginUserProfileModel?.user?.id}");

    if (loginUserId.trim().isNotEmpty && token!.trim().isNotEmpty) {
      if (fetchLoginUserProfileModel?.user?.loginType != null) {
        Database.onSetIsNewUser(false);
        log("fetchLoginUserProfileModel?.user?.Email  :: ${fetchLoginUserProfileModel?.user?.email}");

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
        log("Database.loginUserEmail  ${Database.loginUserEmail}");
        log("Database.loginUserFirebaseId  ${Database.loginUserFirebaseId}");
        log("Database.image  ${Database.loginUserProfilePic}");
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Get Profile Api Calling Failed !!");
      }
    } else {
      Database.onLogOut();
    }
  }
}

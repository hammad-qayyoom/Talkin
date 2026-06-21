import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/setting_screen/api/request_delete_otp_api.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/services/biometric/biometric_auth_service.dart';
import 'package:notisboard/ui/user_flow/setting_screen/api/user_notification_update_api.dart';
import 'package:notisboard/ui/user_flow/setting_screen/model/delete_user_account_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class SettingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isShowNotification =
      Database.fetchLoginUserProfileModel?.user?.isNotificationEnabled ?? false;
  bool isBiometricEnabled = false;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  DeleteUserResponseModel? deleteUserModel;

  @override
  void onInit() {
    super.onInit();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    isBiometricEnabled = await BiometricAuthService.isEnabled();
    update();
  }

  Future<void> onSwitchBiometric(bool value) async {
    if (value) {
      final supported = await BiometricAuthService.isBiometricSupported();
      if (!supported) {
        Utils.showToast(
          Get.context,
          'Biometric login is not available on this device',
        );
        return;
      }

      final authenticated = await BiometricAuthService.authenticate(
        reason: 'Enable biometric login',
      );
      if (!authenticated) {
        Utils.showToast(Get.context, 'Biometric authentication failed');
        return;
      }

      await BiometricAuthService.setEnabled(true);
      await BiometricAuthService.bindSessionForCurrentUser();
      isBiometricEnabled = true;
      Utils.showToast(Get.context, 'Biometric login enabled');
      update();
      return;
    }

    await BiometricAuthService.setEnabled(false);
    isBiometricEnabled = false;
    Utils.showToast(Get.context, 'Biometric login disabled');
    update();
  }

  /// log out
  Future<void> signOut() async {
    await _auth.signOut();
    await BiometricAuthService.clearAll();
    Database.localStorage.erase();
    Database.onSetSelectedLanguage(Constant.languageEn);
    Database.onSetSelectedLanguageCountryCode(Constant.countryCodeEn);
  }

  /// notification switch
  void onSwitchNotification(bool currentValue) async {
    final token = await FirebaseAccessToken.onGet();

    // Instant UI update
    isShowNotification = currentValue;
    update();

    // API call to update permission
    final notificationUpdateModel = await UserNotificationUpdateApi.callApi();

    if (notificationUpdateModel != null &&
        notificationUpdateModel.status == true) {
      // Success, keep toggled value
      isShowNotification = currentValue;
    } else {
      // Failure, revert to previous value
      isShowNotification = !currentValue;
    }
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
        loginUserId: Database.loginUserFirebaseId, token: token ?? '');
    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    Database.fetchLoginUserProfileModel?.user?.isNotificationEnabled =
        isShowNotification;

    update(); // Trigger UI update after API call
  }

  /// user account delete
  Future<void> onDeleteAccount() async {
    if (Get.isDialogOpen ?? false) {
      Get.back(); // Close Dialog...
    }

    Get.dialog(const LoadingWidget(),
        barrierDismissible: false); // Start Loading...

    final response = await RequestDeleteOtpApi.callApi();

    Get.back(); // Stop Loading...

    if (response != null && response.status == true) {
      Utils.showToast(Get.context!, response.message ?? "OTP sent to your email");
      Get.toNamed(AppRoutes.deleteAccountOtpScreen);
    } else {
      Utils.showToast(Get.context!, response?.message ?? "Failed to request OTP");
    }
  }

  @override
  void onClose() {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    super.onClose();
  }
}

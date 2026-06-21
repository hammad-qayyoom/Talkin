import 'package:notisboard/ui/user_flow/setting_screen/api/request_delete_otp_api.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/services/biometric/biometric_auth_service.dart';
import 'package:notisboard/ui/host_flow/host_setting_screen/api/delete_listener_api.dart';
import 'package:notisboard/ui/host_flow/host_setting_screen/api/notification_update_api.dart';
import 'package:notisboard/ui/host_flow/host_setting_screen/model/delete_listener_response_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class HostSettingController extends GetxController {
  bool isShowNotification =
      Database.fetchListenerProfileModel?.data?.isNotificationEnabled ?? false;
  bool isBiometricEnabled = false;
  FetchListenerProfileModel? fetchListenerProfileModel;
  DeleteListenerResponseModel? deleteListenerResponseModel;

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

  /// notification switch
  void onSwitchNotification(bool currentValue) async {
    isShowNotification = currentValue;
    update();

    final notificationUpdateModel = await HostNotificationUpdateApi.callApi(
      listenerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
    );

    if (notificationUpdateModel != null &&
        notificationUpdateModel.status == true) {
      isShowNotification = currentValue;
    } else {
      isShowNotification = !currentValue;
    }
    fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId:
            Database.fetchLoginUserProfileModel?.user?.listenerId ?? '');
    Database.fetchListenerProfileModel = fetchListenerProfileModel;

    if (fetchListenerProfileModel?.status == false) {
      Utils.showLog(fetchListenerProfileModel?.message ?? "");
    }
    Database.fetchListenerProfileModel?.data?.isNotificationEnabled =
        isShowNotification;

    update();
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
  void dispose() {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    super.dispose();
  }

  @override
  void onClose() {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    super.onClose();
  }
}

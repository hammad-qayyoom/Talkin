import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/ui/user_flow/setting_screen/api/delete_user_api.dart';
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
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  DeleteUserResponseModel? deleteUserModel;

  /// log out
  Future<void> signOut() async {
    await _auth.signOut();
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

    deleteUserModel = await DeleteUserApi.callApi();

    Get.back(); // Stop Loading...

    if (deleteUserModel?.status ?? false) {
      Database.onLogOut();
      Utils.showLog(
          deleteUserModel?.message ?? "User account deleted successfully.");
    }
  }

  @override
  void onClose() {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    super.onClose();
  }
}

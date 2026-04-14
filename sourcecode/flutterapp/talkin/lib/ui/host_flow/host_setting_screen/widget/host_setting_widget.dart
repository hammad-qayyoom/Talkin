import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/setting_menu_ui/setting_menu.dart';
import 'package:talk_in/custom/switch/switch.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/controller/host_setting_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class HostSettingScreenAppBar extends StatelessWidget {
  const HostSettingScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtSettings.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class HostSettingView extends StatelessWidget {
  const HostSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingMainMenu(
          rightSpace: Get.width * -0.07,
          text: EnumLocale.txtManageYourAccountSettings.name.tr,
          subText: EnumLocale.txtManageYourAccountSettingsSubText.name.tr,
          topImage: AppAsset.settingBlur,
        ).paddingOnly(bottom: 20),
        // Notification Switch
        GetBuilder<HostSettingController>(
          builder: (controller) {
            return SettingMenu(
              widget: CommonCupertinoSwitch(
                value: controller.isShowNotification,
                onChanged: (bool val) {
                  controller.onSwitchNotification(val);
                },
                activeColor: CupertinoColors.activeGreen,
                trackColor: CupertinoColors.destructiveRed,
                scale: 0.8,
              ),
              icon: AppAsset.notification,
              title: EnumLocale.txtNotification.name.tr,
              onTap: () {},
            ).paddingOnly(bottom: 22);
          },
        ),

        SettingMenu(
          icon: AppAsset.settingAppLanguage,
          title: EnumLocale.txtAPPLanguage.name.tr,
          onTap: () {
            Get.toNamed(AppRoutes.hostAppLanguageScreen);
          },
        ).paddingOnly(bottom: 22),
        SettingMenu(
          icon: AppAsset.calendar,
          title: 'Manage Availability',
          onTap: () {
            Get.toNamed(AppRoutes.hostAvailabilityScreen);
          },
        ).paddingOnly(bottom: 22),
        SettingMenu(
          icon: AppAsset.callIcon,
          title: 'My Sessions',
          onTap: () {
            Get.toNamed(AppRoutes.hostSessionsScreen);
          },
        ).paddingOnly(bottom: 22),
        SettingMenu(
          icon: AppAsset.logOut,
          title: EnumLocale.txtLogoutApp.name.tr,
          onTap: () {
            Utils.showConfirmationSnackBar(
              context,
              title: EnumLocale.txtLogout.name.tr,
              message: EnumLocale.txtDesLogout.name.tr,
              confirmText: EnumLocale.txtLogout.name.tr,
              cancelText: EnumLocale.txtCancel.name.tr,
              icon: Icons.logout_rounded,
              onConfirm: () {
                Database.onLogOut();
                Get.offAllNamed(AppRoutes.main);
              },
            );
          },
        ).paddingOnly(bottom: 22),

        Database.demoListener == true
            ? Offstage()
            : GetBuilder<HostSettingController>(builder: (controller) {
                return SettingMenu(
                  icon: AppAsset.delete,
                  title: EnumLocale.txtDeleteAccount.name.tr,
                  onTap: () {
                    Utils.showConfirmationSnackBar(
                      context,
                      title: EnumLocale.txtDeleteAccount.name.tr,
                      message: EnumLocale.desWantDeleteAccount.name.tr,
                      confirmText: EnumLocale.txtDeleteAccount.name.tr,
                      cancelText: EnumLocale.txtCancel.name.tr,
                      icon: Icons.delete_forever_outlined,
                      confirmBackgroundColor: AppColors.red,
                      onConfirm: () {
                        if (Database.demoListener == true) {
                          Utils.showToast(
                            Get.context!,
                            EnumLocale.txtDEmoListenerText.name.tr,
                          );
                        } else {
                          controller.onDeleteAccount();
                        }
                      },
                    );
                  },
                );
              }),
      ],
    );
  }
}

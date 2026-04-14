import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/setting_screen/controller/setting_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class SettingScreenAppBar extends StatelessWidget {
  const SettingScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 760;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () async {
              Get.back();
              await 0.2.delay();
              Utils.onChangeStatusBar(brightness: Brightness.dark);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtSettings.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 28 : 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Privacy, language and account controls',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: isTablet ? 12 : 11,
                    fontColor: AppColors.redesignMutedText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 18,
              color: AppColors.redesignBrandRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 760;
            final maxContentWidth = constraints.maxWidth >= 1100
                ? 980.0
                : constraints.maxWidth >= 760
                    ? 760.0
                    : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsControlCard(
                        title: EnumLocale.txtManageYourAccountSettings.name.tr,
                        subtitle: EnumLocale
                            .txtManageYourAccountSettingsSubText.name.tr,
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 14),
                      _SectionLabel(
                        title: 'Preferences',
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 8),
                      _SettingsLane(
                        iconAsset: AppAsset.notification,
                        title: EnumLocale.txtNotification.name.tr,
                        subtitle: 'Get alerts for calls and updates',
                        isTablet: isTablet,
                        onTap: () {
                          controller.onSwitchNotification(
                            !controller.isShowNotification,
                          );
                        },
                        trailing: Transform.scale(
                          scale: isTablet ? 0.9 : 0.84,
                          child: CupertinoSwitch(
                            value: controller.isShowNotification,
                            onChanged: (bool val) {
                              controller.onSwitchNotification(val);
                            },
                            activeTrackColor: AppColors.redesignBrandRed,
                            inactiveTrackColor: AppColors.redesignSoftBorder,
                            thumbColor: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SettingsLane(
                        iconAsset: AppAsset.settingAppLanguage,
                        title: EnumLocale.txtAPPLanguage.name.tr,
                        subtitle: 'Change your preferred app language',
                        isTablet: isTablet,
                        onTap: () {
                          Get.toNamed(AppRoutes.appLanguageScreen);
                        },
                      ),
                      const SizedBox(height: 14),
                      _SectionLabel(
                        title: 'Account',
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 8),
                      _SettingsLane(
                        iconAsset: AppAsset.logOut,
                        title: EnumLocale.txtLogoutApp.name.tr,
                        subtitle: 'Sign out from this device',
                        isTablet: isTablet,
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
                      ),
                      const SizedBox(height: 10),
                      _SettingsLane(
                        iconAsset: AppAsset.delete,
                        title: EnumLocale.txtDeleteAccount.name.tr,
                        subtitle: 'Permanently remove your account data',
                        isTablet: isTablet,
                        isDestructive: true,
                        onTap: () {
                          Utils.showConfirmationSnackBar(
                            context,
                            title: EnumLocale.txtDeleteAccount.name.tr,
                            message: EnumLocale.desWantDeleteAccount.name.tr,
                            confirmText: EnumLocale.txtDeleteAccount.name.tr,
                            cancelText: EnumLocale.txtCancel.name.tr,
                            icon: Icons.delete_forever_outlined,
                            confirmBackgroundColor: AppColors.red,
                            onConfirm: controller.onDeleteAccount,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.isTablet,
  });

  final String title;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppFontStyle.fontStyleW700(
        fontSize: isTablet ? 16 : 14,
        fontColor: AppColors.redesignBrandDark,
      ),
    );
  }
}

class _SettingsControlCard extends StatelessWidget {
  const _SettingsControlCard({
    required this.title,
    required this.subtitle,
    required this.isTablet,
  });

  final String title;
  final String subtitle;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 18 : 16,
        isTablet ? 18 : 16,
        isTablet ? 18 : 16,
        isTablet ? 18 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.redesignBrandRed.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Control Hub',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 12 : 11,
                    fontColor: AppColors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(AppAsset.settingBlur),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppFontStyle.fontStyleW700(
              fontSize: isTablet ? 28 : 24,
              fontColor: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: isTablet ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW500(
              fontSize: isTablet ? 14 : 12,
              fontColor: AppColors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroChip(label: 'Language'),
              _HeroChip(label: 'Alerts'),
              _HeroChip(label: 'Privacy'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: AppFontStyle.fontStyleW600(
          fontSize: 11,
          fontColor: AppColors.white,
        ),
      ),
    );
  }
}

class _SettingsLane extends StatelessWidget {
  const _SettingsLane({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.isTablet,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final bool isTablet;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.redesignStatusDangerBg.withValues(alpha: 0.42)
                : AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDestructive
                  ? AppColors.redesignBrandRed.withValues(alpha: 0.22)
                  : AppColors.redesignSoftBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: isTablet ? 54 : 48,
                width: isTablet ? 54 : 48,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.redesignAccentSoftBg
                      : AppColors.redesignSurfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Image.asset(
                    iconAsset,
                    height: isTablet ? 32 : 30,
                    width: isTablet ? 32 : 30,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: isTablet ? 16 : 15,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: isTablet ? 12 : 11,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                  color: AppColors.redesignMutedText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

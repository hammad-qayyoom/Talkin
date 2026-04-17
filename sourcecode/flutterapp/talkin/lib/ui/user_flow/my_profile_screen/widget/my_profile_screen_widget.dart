import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:notisboard/ui/user_flow/my_profile_screen/controller/my_profile_screen_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class MyProfileTopView extends StatelessWidget {
  const MyProfileTopView({super.key});

  String _secondaryText() {
    if (Database.loginType == 2) {
      return Database.loginUserNickName;
    }

    return Database.loginUserEmail;
  }

  void _onCopyId({
    required BuildContext context,
    required String uniqueId,
  }) {
    if (uniqueId.trim().isEmpty) {
      return;
    }

    Utils.copyText(uniqueId);
    Utils.showToast(context, 'Copied');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final topInset = mediaQuery.padding.top;
    final isTablet = width >= 760;

    return GetBuilder<EditProfileController>(
      id: Constant.idProfile,
      builder: (_) {
        final userName = Database.loginUserName.trim().isEmpty
            ? 'User'
            : Database.loginUserName.trim();
        final uniqueId =
            (Database.fetchLoginUserProfileModel?.user?.uniqueId ?? '')
                .toString();

        return Container(
          padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 12),
          color: AppColors.redesignScreenBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: Get.back,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      EnumLocale.txtMyProfile.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: isTablet ? 28 : 20,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: AppColors.redesignSurfaceNeutralAlt,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.redesignSoftBorder),
                    ),
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 19,
                      color: AppColors.redesignBrandDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: isTablet ? 82 : 70,
                          width: isTablet ? 82 : 70,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.redesignBrandRed
                                  .withValues(alpha: 0.28),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: CustomProfileImage(
                              image: Database.loginUserProfilePic,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: isTablet ? 24 : 18,
                                        fontColor: AppColors.redesignBrandDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.redesignSurfaceNeutralAlt,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.redesignSoftBorder,
                                      ),
                                    ),
                                    child: Text(
                                      'Profile',
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 10,
                                        fontColor: AppColors.redesignMutedText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _secondaryText(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: isTablet ? 15 : 13,
                                  fontColor: AppColors.redesignMutedText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (uniqueId.trim().isNotEmpty)
                                    _IdChip(
                                      id: uniqueId,
                                      onTap: () => _onCopyId(
                                        context: context,
                                        uniqueId: uniqueId,
                                      ),
                                    ),
                                  const _MetaChip(
                                    icon: Icons.verified_user_outlined,
                                    label: 'Secure account',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileActionButton(
                            icon: Icons.dynamic_feed_rounded,
                            title: 'My Posts',
                            isPrimary: false,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.feedScreen,
                                arguments: {
                                  'standalone': true,
                                  'title': 'My Posts',
                                  'userId': Database.loginUserId,
                                  'showComposer': true,
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ProfileActionButton(
                            icon: Icons.edit_outlined,
                            title: EnumLocale.txtEditProfile.name.tr,
                            isPrimary: true,
                            onTap: () {
                              Get.toNamed(AppRoutes.editProfileScreen);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

class _IdChip extends StatelessWidget {
  const _IdChip({
    required this.id,
    required this.onTap,
  });

  final String id;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.redesignSurfaceSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID $id',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 12,
                  fontColor: AppColors.redesignBrandRed,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(
                AppAsset.copyIcon,
                height: 14,
                width: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.redesignMutedText,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppFontStyle.fontStyleW600(
              fontSize: 10,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isPrimary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.redesignBrandRed : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? AppColors.redesignBrandRed
                  : AppColors.redesignSoftBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color:
                    isPrimary ? AppColors.white : AppColors.redesignBrandDark,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: isPrimary
                        ? AppColors.white
                        : AppColors.redesignBrandDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileOptionsView extends StatelessWidget {
  const ProfileOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyProfileScreenController>(
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 760;
            final maxContentWidth =
                constraints.maxWidth >= 1100 ? 980.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        title: 'Quick Access',
                        subtitle: 'Shortcuts for your daily actions',
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 10 : 8,
                          vertical: isTablet ? 10 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: AppColors.redesignSoftBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TopItem(
                                icon: AppAsset.wallet,
                                title: EnumLocale.txtMyWallet.name.tr,
                                onTap: () {
                                  Get.toNamed(AppRoutes.myWalletScreen);
                                },
                              ),
                            ),
                            _QuickDivider(),
                            Expanded(
                              child: TopItem(
                                icon: AppAsset.helpCenter,
                                title: EnumLocale.txtHelpCenter.name.tr,
                                onTap: () {
                                  Get.toNamed(AppRoutes.helpCenterScreen);
                                },
                              ),
                            ),
                            _QuickDivider(),
                            Expanded(
                              child: TopItem(
                                icon: AppAsset.setting,
                                title: EnumLocale.txtSettings.name.tr,
                                onTap: () {
                                  Get.toNamed(AppRoutes.settingScreen);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle(
                        title: 'Account & More',
                        subtitle: 'Account tools and privacy controls',
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 10),
                      if (Database
                              .settingApiModel?.data?.allowBecomeHostOption ==
                          true)
                        CenterOption(
                          onTap: () {
                            Get.toNamed(AppRoutes.becomeHostScreen)?.then(
                              (value) {
                                Utils.onChangeStatusBar(
                                  brightness: Brightness.dark,
                                );
                              },
                            );
                          },
                          icon: AppAsset.hostCenter,
                          title: EnumLocale.txtListenersCenter.name.tr,
                          badgeText: EnumLocale.txtBecomeListener.name.tr,
                          isHighlighted: true,
                        ),
                      CenterOption(
                        onTap: () async {
                          await controller.onClickPrivacyPolicy();
                        },
                        icon: AppAsset.privacyCenter,
                        title: EnumLocale.txtPrivacyCenter.name.tr,
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

class _QuickDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 86,
      color: AppColors.redesignSoftBorder,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.isTablet,
  });

  final String title;
  final String subtitle;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFontStyle.fontStyleW700(
            fontSize: isTablet ? 20 : 17,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppFontStyle.fontStyleW500(
            fontSize: isTablet ? 13 : 11,
            fontColor: AppColors.redesignMutedText,
          ),
        ),
      ],
    );
  }
}

class CenterOption extends StatelessWidget {
  const CenterOption({
    super.key,
    required this.icon,
    required this.title,
    this.badgeText,
    this.onTap,
    this.isHighlighted = false,
  });

  final String icon;
  final String title;
  final String? badgeText;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.redesignAccentSoftBg.withValues(alpha: 0.75)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isHighlighted
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
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.redesignSoftBorder),
                  ),
                  child: Center(
                    child: Image.asset(
                      icon,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 16,
                                fontColor: AppColors.redesignBrandDark,
                              ),
                            ),
                          ),
                          if (badgeText != null &&
                              badgeText!.trim().isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 116),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.redesignBrandDark,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badgeText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 10,
                                  fontColor: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: AppColors.redesignSurfaceInput,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.redesignSoftBorder),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopItem extends StatelessWidget {
  const TopItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    height: 34,
                    width: 34,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

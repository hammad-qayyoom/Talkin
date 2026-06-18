import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/host_flow/host_profile_screen/controller/host_profile_screen_controller.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class HostProfileTopView extends StatelessWidget {
  const HostProfileTopView({super.key});

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
    final maxContentWidth = width >= 1100 ? 980.0 : width;

    final listenerName =
        (Database.fetchListenerProfileModel?.data?.name ?? '').trim();
    final displayName = listenerName.isEmpty ? 'Expert' : listenerName;
    final uniqueId =
        (Database.fetchLoginUserProfileModel?.user?.uniqueId ?? '').toString();

    return Container(
      color: AppColors.redesignScreenBackground,
      padding: EdgeInsets.only(top: topInset + 8),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () async {
                        Get.back();
                        await 0.2.delay();
                        Utils.onChangeStatusBar(brightness: Brightness.dark);
                      },
                    ),
                    Expanded(
                      child: Text(
                        EnumLocale.txtMyProfile.name.tr,
                        textAlign: TextAlign.center,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: isTablet ? 24 : 18,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.redesignSoftBorder),
                      ),
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: 18,
                        color: AppColors.redesignBrandDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(isTablet ? 14 : 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.redesignSoftBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: isTablet ? 74 : 60,
                            width: isTablet ? 74 : 60,
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
                                image: Database.fetchListenerProfileModel?.data
                                        ?.image ??
                                    '',
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
                                        displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: isTablet ? 21 : 17,
                                          fontColor:
                                              AppColors.redesignBrandDark,
                                        ),
                                      ),
                                    ),
                                    VerifiedBadge(
                                      isVerified: Database
                                              .fetchListenerProfileModel
                                              ?.data
                                              ?.isVerifiedBadge ==
                                          true,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.redesignSurfaceNeutralAlt,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: AppColors.redesignSoftBorder,
                                        ),
                                      ),
                                      child: Text(
                                        'Expert',
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 10,
                                          fontColor:
                                              AppColors.redesignMutedText,
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
                                    fontSize: isTablet ? 14 : 12,
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileActionButton(
                              icon: Icons.dynamic_feed_rounded,
                              title: 'My Posts',
                              isPrimary: false,
                              onTap: () {
                                final isListener = Database
                                            .fetchLoginUserProfileModel
                                            ?.user
                                            ?.isListener ==
                                        true ||
                                    Database.isListener;
                                final me = (Database.fetchLoginUserProfileModel
                                            ?.user?.id ??
                                        Database.loginUserId)
                                    .toString();
                                final expertId = (Database
                                            .fetchLoginUserProfileModel
                                            ?.user
                                            ?.listenerId ??
                                        Database.loginListenerId)
                                    .toString();

                                Get.toNamed(
                                  AppRoutes.feedScreen,
                                  arguments: {
                                    'standalone': true,
                                    'title': 'My Posts',
                                    'showComposer': true,
                                    if (isListener &&
                                        expertId.trim().isNotEmpty)
                                      'expertId': expertId,
                                    if (!isListener || expertId.trim().isEmpty)
                                      'userId': me,
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ProfileActionButton(
                              icon: Icons.edit_outlined,
                              title: 'Edit Expert',
                              isPrimary: true,
                              onTap: () {
                                Get.toNamed(AppRoutes.hostListenersDetailScreen)
                                    ?.then((value) async {
                                  final latest =
                                      await FetchListenerProfileAPi.callApi(
                                    loginListenerId: Database
                                        .fetchLoginUserProfileModel
                                        ?.user
                                        ?.listenerId,
                                  );
                                  if (latest != null) {
                                    Database.fetchListenerProfileModel = latest;
                                  }
                                });
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
          ),
        ),
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

class HostProfileOptionsView extends StatelessWidget {
  const HostProfileOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<HostProfileScreenController>(
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
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
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
                            horizontal: isTablet ? 8 : 6,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: AppColors.redesignSoftBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _QuickActionTile(
                                  icon: AppAsset.calendar,
                                  title: 'Availability',
                                  onTap: () {
                                    Get.toNamed(
                                      AppRoutes.hostAvailabilityScreen,
                                    );
                                  },
                                ),
                              ),
                              _QuickDivider(),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: AppAsset.helpCenter,
                                  title: EnumLocale.txtHelpCenter.name.tr,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.hostHelpCenterScreen);
                                  },
                                ),
                              ),
                              _QuickDivider(),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: AppAsset.setting,
                                  title: EnumLocale.txtSettings.name.tr,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.hostSettingScreen);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionTitle(
                          title: 'Verification',
                          subtitle: 'Blue tick badge status and application',
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 10),
                        _VerificationCard(),
                        const SizedBox(height: 16),
                        _SectionTitle(
                          title: 'Account & More',
                          subtitle: 'Account tools and privacy controls',
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 10),
                        _AccountOptionCard(
                          onTap: () async {
                            await controller.onClickPrivacyPolicy();
                          },
                          icon: AppAsset.privacyCenter,
                          title: EnumLocale.txtPrivacyCenter.name.tr,
                          subtitle: EnumLocale.txtDataPrivacy.name.tr,
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard();

  @override
  Widget build(BuildContext context) {
    final isVerifiedBadge =
        Database.fetchListenerProfileModel?.data?.isVerifiedBadge == true;
    final badgeType =
        Database.fetchListenerProfileModel?.data?.verifiedBadgeType ?? 'none';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isVerifiedBadge
                      ? AppColors.blue.withValues(alpha: 0.12)
                      : AppColors.redesignBrandRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Icon(
                  isVerifiedBadge
                      ? Icons.verified_rounded
                      : Icons.verified_user_outlined,
                  size: 22,
                  color: isVerifiedBadge
                      ? AppColors.blue
                      : AppColors.redesignBrandRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVerifiedBadge ? 'Blue Tick Verified' : 'Blue Tick',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    Text(
                      isVerifiedBadge
                          ? badgeType == 'auto_sessions'
                              ? 'Earned through sessions'
                              : 'Manually verified'
                          : 'Apply for manual verification',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 11,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.redesignMutedText,
              ),
            ],
          ),
          if (!isVerifiedBadge) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryAppButton(
                onTap: () {
                  Get.toNamed(AppRoutes.manualVerificationScreen);
                },
                height: 40,
                color: AppColors.redesignBrandRed,
                borderColor: AppColors.redesignBrandRed,
                text: 'Apply for Blue Tick',
                textStyle: AppFontStyle.fontStyleW600(
                  fontSize: 13,
                  fontColor: AppColors.white,
                ),
              ),
            ),
          ],
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                  fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.redesignBrandRed : AppColors.white,
            borderRadius: BorderRadius.circular(12),
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
                size: 16,
                color:
                    isPrimary ? AppColors.white : AppColors.redesignBrandDark,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 13,
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

class _QuickDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 72,
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
            fontSize: isTablet ? 18 : 16,
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
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    height: 28,
                    width: 28,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 12,
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

class _AccountOptionCard extends StatelessWidget {
  const _AccountOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isHighlighted = false,
  });

  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.redesignAccentSoftBg.withValues(alpha: 0.75)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(15),
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
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.redesignSoftBorder),
                  ),
                  child: Center(
                    child: Image.asset(
                      icon,
                      height: 32,
                      width: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 14,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: AppColors.redesignSurfaceInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.redesignSoftBorder),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
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

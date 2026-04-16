import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/switch/switch.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostTopHomeView extends StatelessWidget {
  const HostTopHomeView({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    final width = mediaQuery.size.width;

    final isLargeTablet = width >= 1100;
    final isTablet = width >= 760;
    final isCompact = width < 390;
    final isVeryCompact = width < 350;

    final profileImageSize = isLargeTablet
        ? 68.0
        : isTablet
            ? 60.0
            : isCompact
                ? 52.0
                : 56.0;
    final actionSize = isLargeTablet
        ? 60.0
        : isTablet
            ? 54.0
            : isCompact
                ? 48.0
                : 52.0;
    final nameFontSize = isLargeTablet
        ? 24.0
        : isTablet
            ? 20.0
            : isCompact
                ? 16.0
                : 18.0;
    final coinMinWidth = isLargeTablet
        ? 140.0
        : isTablet
            ? 124.0
            : isCompact
                ? 100.0
                : 116.0;
    final coinValueFontSize = isTablet
        ? 16.0
        : isCompact
            ? 14.0
            : 15.0;
    final idFontSize = isTablet ? 11.0 : 10.0;

    Widget profileSection() {
      return GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.hostProfileScreen);
        },
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              height: profileImageSize,
              width: profileImageSize,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _brandRed.withValues(alpha: 0.28),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CustomProfileImage(
                image: Database.fetchListenerProfileModel?.data?.image ?? '',
              ),
            ),
            SizedBox(width: isCompact ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Database.fetchListenerProfileModel?.data?.name ?? 'Expert',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: nameFontSize,
                      fontColor: _brandDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GetBuilder<HostHomeScreenController>(
                    builder: (controller) {
                      return GestureDetector(
                        onTap: () {
                          if (!controller.isToastVisible) {
                            Utils.copyText(
                              Database.fetchLoginUserProfileModel?.user
                                      ?.uniqueId ??
                                  '',
                            );
                            Utils.showToast(context, 'Copied');

                            controller.isToastVisible = true;

                            Future.delayed(
                              const Duration(seconds: 3),
                              () {
                                controller.isToastVisible = false;
                              },
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet
                                ? 12
                                : isCompact
                                    ? 8
                                    : 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: _softBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'ID ${Database.fetchListenerProfileModel?.data?.uniqueId ?? ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: idFontSize,
                                    fontColor: _brandRed,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(
                                AppAsset.copyIcon,
                                height: 12,
                                width: 12,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget coinCard() {
      return GetBuilder<HostHomeScreenController>(
        id: Constant.idCoinUpdate,
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.hostViewCoinHistory);
            },
            child: Container(
              height: actionSize,
              constraints: BoxConstraints(minWidth: coinMinWidth),
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(isCompact ? 16 : 18),
                border: Border.all(color: _softBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAsset.starCoin,
                    height: isTablet
                        ? 24
                        : isCompact
                            ? 20
                            : 22,
                    width: isTablet
                        ? 24
                        : isCompact
                            ? 20
                            : 22,
                  ),
                  const SizedBox(width: 6),
                  controller.isCoinLoading
                      ? Shimmer.fromColors(
                          baseColor: AppColors.lightGrey1,
                          highlightColor: AppColors.grey.withValues(alpha: 0.2),
                          child: Text(
                            Database.listenerCoin.toString(),
                            style: AppFontStyle.fontStyleW700(
                              fontSize: coinValueFontSize,
                              fontColor: AppColors.redesignCoinText,
                            ),
                          ),
                        )
                      : Text(
                          Database.listenerCoin.toString(),
                          style: AppFontStyle.fontStyleW700(
                            fontSize: coinValueFontSize,
                            fontColor: AppColors.redesignCoinText,
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget notificationButton() {
      return GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.hostNotificationView);
        },
        child: Container(
          height: actionSize,
          width: actionSize,
          decoration: BoxDecoration(
            color: _brandRed,
            borderRadius: BorderRadius.circular(isCompact ? 16 : 18),
            boxShadow: [
              BoxShadow(
                color: _brandRed.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_rounded,
            color: AppColors.white,
            size: isTablet
                ? 26
                : isCompact
                    ? 22
                    : 24,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: topInset + 8, bottom: 12),
      child: isVeryCompact
          ? Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: profileSection()),
                    const SizedBox(width: 8),
                    notificationButton(),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: coinCard(),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: profileSection()),
                SizedBox(width: isCompact ? 8 : 10),
                coinCard(),
                const SizedBox(width: 8),
                notificationButton(),
              ],
            ),
    );
  }
}

class HostImageView extends StatelessWidget {
  const HostImageView({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  Widget _ratePill({
    required String label,
    required String rate,
    required bool isCompact,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Image.asset(
            AppAsset.starCoin,
            height: isCompact ? 14 : 16,
            width: isCompact ? 14 : 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    '$rate/session',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: isCompact ? 11 : 12,
                      fontColor: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: isCompact ? 10 : 11,
                      fontColor: AppColors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostHomeScreenController>(
      builder: (controller) {
        final audioRate = Database
                .fetchListenerProfileModel?.data?.ratePrivateAudioCall
                .toString() ??
            '0';
        final videoRate = Database
                .fetchListenerProfileModel?.data?.ratePrivateVideoCall
                .toString() ??
            '0';

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isLargeTablet = width >= 1100;
            final isTablet = width >= 760;
            final isCompact = width < 380;

            final titleSize = isLargeTablet
                ? 40.0
                : isTablet
                    ? 32.0
                    : isCompact
                        ? 20.0
                        : 24.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _brandRed,
                        AppColors.redesignBrandRedDark,
                        AppColors.redesignBrandDarkAlt,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _brandRed.withValues(alpha: 0.24),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.34),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 7,
                              width: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expert Dashboard',
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 11,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        EnumLocale.txtHomeFastLalk.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: titleSize,
                          fontColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        EnumLocale.txtHomeDescription.name.tr,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: isTablet ? 15 : 13,
                          height: 1.4,
                          fontColor: AppColors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isCompact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ratePill(
                              label: 'Audio',
                              rate: audioRate,
                              isCompact: isCompact,
                            ),
                            const SizedBox(height: 10),
                            _ratePill(
                              label: 'Video',
                              rate: videoRate,
                              isCompact: isCompact,
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                AppAsset.hostHomeImage,
                                fit: BoxFit.cover,
                                height: 90,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _ratePill(
                                label: 'Audio',
                                rate: audioRate,
                                isCompact: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ratePill(
                                label: 'Video',
                                rate: videoRate,
                                isCompact: false,
                              ),
                            ),
                            if (!isTablet) const SizedBox(width: 10),
                            if (!isTablet)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  AppAsset.hostHomeImage,
                                  fit: BoxFit.cover,
                                  height: 58,
                                  width: 70,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _softBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Growth Spotlight',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: isTablet ? 18 : 16,
                            fontColor: _brandDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: isTablet ? 170 : 138,
                              autoPlay: true,
                              viewportFraction: 1,
                              enlargeCenterPage: false,
                              onPageChanged: controller.onPageChanged,
                            ),
                            items: controller.imageList.map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        item,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: AppColors
                                                .redesignSurfaceNeutralAlt,
                                          );
                                        },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.black
                                                  .withValues(alpha: 0.08),
                                              AppColors.black
                                                  .withValues(alpha: 0.48),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 12,
                                        right: 12,
                                        bottom: 10,
                                        child: Text(
                                          'Go online, stay visible, and earn more sessions.',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFontStyle.fontStyleW600(
                                            fontSize: isTablet ? 14 : 12,
                                            fontColor: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(controller.imageList.length,
                              (index) {
                            final isSelected = controller.currentIndex == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isSelected ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: isSelected
                                    ? _brandRed
                                    : AppColors.redesignSoftBorder,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtImAvailableFor.name.tr,
          style: AppFontStyle.fontStyleW700(
            fontSize: 28,
            fontColor: _brandDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Control your live availability and session modes.',
          style: AppFontStyle.fontStyleW500(
            fontSize: 13,
            fontColor: _mutedText,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isTablet = constraints.maxWidth >= 760;

            final audioCard = GetBuilder<HostHomeScreenController>(
              builder: (controller) {
                return CustomSwitchView(
                  iconData: Icons.call_rounded,
                  text: EnumLocale.txtAvailableForAudioCall.name.tr,
                  subtitle: 'Allow private audio sessions',
                  callCoin: Database
                          .fetchListenerProfileModel?.data?.ratePrivateAudioCall
                          .toString() ??
                      '0',
                  coinShow: true,
                  value: controller.isAvailableForPrivateAudioCall,
                  onChanged: (val) {
                    controller.permissionSwitch(
                      val,
                      'isAvailableForPrivateAudioCall',
                    );
                  },
                );
              },
            );

            final videoCard = GetBuilder<HostHomeScreenController>(
              builder: (controller) {
                return CustomSwitchView(
                  iconData: Icons.videocam_rounded,
                  text: EnumLocale.txtAvailableForVideoCall.name.tr,
                  subtitle: 'Allow private video sessions',
                  callCoin: Database
                          .fetchListenerProfileModel?.data?.ratePrivateVideoCall
                          .toString() ??
                      '0',
                  coinShow: true,
                  value: controller.isAvailableForPrivateVideoCall,
                  onChanged: (val) {
                    controller.permissionSwitch(
                      val,
                      'isAvailableForPrivateVideoCall',
                    );
                  },
                );
              },
            );

            if (isTablet) {
              return Row(
                children: [
                  Expanded(child: audioCard),
                  const SizedBox(width: 12),
                  Expanded(child: videoCard),
                ],
              );
            }

            return Column(
              children: [
                audioCard,
                const SizedBox(height: 12),
                videoCard,
              ],
            );
          },
        ),
      ],
    );
  }
}

class NoteView extends StatelessWidget {
  const NoteView({super.key});

  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.redesignBrandRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtNote.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 15,
                    fontColor: _brandDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  EnumLocale.txtHostHomeNote.name.tr,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    height: 1.62,
                    fontColor: _mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSwitchView extends StatelessWidget {
  final String text;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool coinShow;
  final String? callCoin;
  final IconData iconData;

  const CustomSwitchView({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
    required this.coinShow,
    required this.iconData,
    this.callCoin,
    this.subtitle,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;

  @override
  Widget build(BuildContext context) {
    final String safeCoin = (callCoin ?? '').trim().isEmpty ? '0' : callCoin!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceNeutralAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              iconData,
              color: _brandDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 14,
                    fontColor: _brandDark,
                  ),
                ),
                if ((subtitle ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 11,
                      fontColor: _mutedText,
                    ),
                  ),
                ],
                if (coinShow) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.redesignSurfaceNeutralAlt,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.redesignSoftBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppAsset.starCoin,
                          height: 15,
                          width: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$safeCoin/session',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 12,
                            fontColor: AppColors.redesignCoinText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          CommonCupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: _brandRed,
            trackColor: CupertinoColors.systemGrey3,
            scale: 0.86,
          ),
        ],
      ),
    );
  }
}

class HostStatisticsCard extends StatelessWidget {
  const HostStatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostHomeScreenController>(
      id: Constant.idCoinUpdate,
      builder: (controller) {
        final profileData = Database.fetchListenerProfileModel?.data;
        final rating = profileData?.rating?.toStringAsFixed(1) ?? '0.0';
        final callCount = controller.totalCompletedSessions.toString();
        final coins = Database.listenerCoin.toString();
        final experience = profileData?.experience != null
            ? '${profileData!.experience}+'
            : '0+';

        return Container(
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.redesignBrandRed,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Statistics',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 16,
                      fontColor: AppColors.redesignBrandDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.wallet_rounded,
                      iconColor: AppColors.redesignCoinText,
                      title: 'Earnings',
                      value: coins,
                      showCoinIcon: true,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: AppColors.redesignSoftBorder),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.star_rounded,
                      iconColor: Colors.amber,
                      title: 'Rating',
                      value: rating,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: AppColors.redesignSoftBorder, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.call_rounded,
                      iconColor: AppColors.redesignBrandRed,
                      title: 'Sessions',
                      value: callCount,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: AppColors.redesignSoftBorder),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.access_time_rounded,
                      iconColor: Colors.blue,
                      title: 'Experience (Yrs)',
                      value: experience,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    bool showCoinIcon = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppFontStyle.fontStyleW500(
                fontSize: 12,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showCoinIcon) ...[
              Image.asset(AppAsset.starCoin, height: 16, width: 16),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: AppFontStyle.fontStyleW700(
                fontSize: 18,
                fontColor: AppColors.redesignBrandDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

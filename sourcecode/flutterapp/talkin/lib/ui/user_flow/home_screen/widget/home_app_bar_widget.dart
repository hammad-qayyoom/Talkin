import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HomeAppBarWidget extends StatelessWidget {
  HomeAppBarWidget({super.key});

  final controller = Get.put(EditProfileController());

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _borderColor = AppColors.redesignSoftBorder;

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

    Widget coinCard() {
      return GetBuilder<HomeScreenController>(
        id: Constant.idCoinUpdate,
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.myWalletScreen);
            },
            child: Container(
              height: actionSize,
              constraints: BoxConstraints(minWidth: coinMinWidth),
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(isCompact ? 16 : 18),
                border: Border.all(color: _borderColor),
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
                            Database.userCoin.toString(),
                            style: AppFontStyle.fontStyleW700(
                              fontSize: coinValueFontSize,
                              fontColor: AppColors.redesignCoinText,
                            ),
                          ),
                        )
                      : Text(
                          Database.userCoin.toString(),
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
          Get.toNamed(AppRoutes.userNotificationView);
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

    Widget profileSection() {
      return GetBuilder<EditProfileController>(
        id: Constant.idProfile,
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.myProfileScreen)?.then(
                (value) {
                  Utils.onChangeStatusBar(brightness: Brightness.dark);
                },
              );
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
                    image: Database.loginUserProfilePic,
                  ),
                ),
                SizedBox(width: isCompact ? 8 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Database.loginUserName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: nameFontSize,
                          fontColor: _brandDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GetBuilder<HomeScreenController>(
                        builder: (controller) {
                          return GestureDetector(
                            onTap: () {
                              if (!controller.isToastVisible) {
                                Utils.copyText(Database
                                        .fetchLoginUserProfileModel
                                        ?.user
                                        ?.uniqueId ??
                                    '1556578425');
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
                                border: Border.all(color: _borderColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'ID ${Database.fetchLoginUserProfileModel?.user?.uniqueId ?? ''}',
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
        },
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

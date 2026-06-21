import 'package:notisboard/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:notisboard/custom/notisboard_wordmark.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/controller/splash_screen_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  static final Color _screenBg = AppColors.redesignScreenBackground;
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: _screenBg,
      body: GetBuilder<SplashScreenController>(
        builder: (controller) {
          final mediaQuery = MediaQuery.of(context);
          final insets = mediaQuery.padding;

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final shortestSide = mediaQuery.size.shortestSide;
              final isTablet = shortestSide >= 600 || width >= 760;
              final horizontalPadding = isTablet ? 40.0 : 24.0;
              final contentMaxWidth = isTablet ? 560.0 : double.infinity;
              final logoOuterSize = isTablet ? 248.0 : 238.0;
              final logoInnerSize = isTablet ? 180.0 : 174.0;
              final wordmarkSize = isTablet ? 58.0 : 52.0;
              final topCircleSize = isTablet ? 360.0 : 300.0;
              final sideCircleSize = isTablet ? 340.0 : 280.0;
              final bottomCircleSize = isTablet ? 320.0 : 260.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -topCircleSize * 0.35,
                    right: isTablet ? width * 0.12 : -90,
                    child: Container(
                      height: topCircleSize,
                      width: topCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _brandRed.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.11,
                    left: -sideCircleSize * 0.48,
                    child: Container(
                      height: sideCircleSize,
                      width: sideCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _brandDark.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -bottomCircleSize * 0.52,
                    right: isTablet ? width * 0.16 : -80,
                    child: Container(
                      height: bottomCircleSize,
                      width: bottomCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _brandRed.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      insets.top + 24,
                      horizontalPadding,
                      insets.bottom + 24,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: contentMaxWidth),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: logoOuterSize,
                                    width: logoOuterSize,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _softBorder),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 30,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        height: logoInnerSize,
                                        width: logoInnerSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.white,
                                          border: Border.all(
                                            color: _softBorder.withValues(
                                              alpha: 0.9,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(22),
                                          child: Image.asset(
                                            AppAsset.splashLogo,
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  NotisboardWordmark(
                                    textAlign: TextAlign.center,
                                    style: AppFontStyle.fontStyleKaushanW400(
                                      fontSize: wordmarkSize,
                                      fontColor: _brandDark,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    EnumLocale.txtFastPrivateConversationsWithExpertsYouTrust.name.tr,
                                    textAlign: TextAlign.center,
                                    style: AppFontStyle.fontStyleW500(
                                      fontSize: isTablet ? 16 : 15,
                                      fontColor: _mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _softBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: _brandRed,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                EnumLocale.txtSettingThingsUp.name.tr,
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 14,
                                  fontColor: _brandDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      // body: Image.asset(
      //   AppAsset.imgSplashScreen,
      //   height: Get.height,
      //   width: Get.width,
      //   fit: BoxFit.cover,
      // ),
    );
  }
}

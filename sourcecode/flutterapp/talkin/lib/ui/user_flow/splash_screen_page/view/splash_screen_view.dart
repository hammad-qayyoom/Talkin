import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/controller/splash_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

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
          final insets = MediaQuery.of(context).padding;

          return Stack(
            children: [
              Positioned(
                top: -120,
                right: -90,
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _brandRed.withValues(alpha: 0.09),
                  ),
                ),
              ),
              Positioned(
                top: 170,
                left: -130,
                child: Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _brandDark.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -140,
                right: -80,
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _brandRed.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, insets.top + 20, 24, insets.bottom + 10),
                child: Column(
                  children: [
                    const Spacer(flex: 5),
                    Container(
                      height: 238,
                      width: 238,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _softBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          height: 174,
                          width: 174,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _brandDark,
                                _brandDark.withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(26),
                            child: Image.asset(AppAsset.splashLogo),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Talkin",
                      style: AppFontStyle.fontStyleKaushanW400(
                        fontSize: 52,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Fast, private conversations with experts you trust.",
                      textAlign: TextAlign.center,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 15,
                        fontColor: _mutedText,
                      ),
                    ),
                    const Spacer(flex: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            "Setting things up...",
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

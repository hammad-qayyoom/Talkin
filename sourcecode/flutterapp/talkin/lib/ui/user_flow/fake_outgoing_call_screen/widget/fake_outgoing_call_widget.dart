import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/notisboard_wordmark.dart';
import 'package:notisboard/ui/user_flow/fake_outgoing_call_screen/controller/fake_outgoing_call_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

/// =================== outgoing2 Call View =================== ///
class FakeOutgoingCallView extends StatelessWidget {
  const FakeOutgoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Stack(
        children: [
          GetBuilder<FakeOutgoingCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: CustomProfileImage(
                    image: logic.receiverImage ?? '',
                    fit: BoxFit.cover,
                  ));
            },
          ),
          BlurryContainer(
            blur: 10,
            elevation: 0,
            color: AppColors.white.withValues(alpha: 0.2),
            height: Get.height,
            width: Get.width,
            child: const SizedBox(), // Empty child just to apply blur
          ),
          GetBuilder<FakeOutgoingCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Center(
                child: Column(
                  children: [
                    // const Spacer(),
                    RippleAnimation(
                      color: AppColors.white,
                      delay: const Duration(milliseconds: 100),
                      repeat: true,
                      minRadius: 50,
                      maxRadius: 75,
                      ripplesCount: 8,
                      duration: const Duration(seconds: 3),
                      child: Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.white.withValues(alpha: 0.2),
                              AppColors.white.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(4), // White border thickness
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white, // White border color
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3), // Inner padding
                              child: ClipOval(
                                child: CustomProfileImage(
                                  image: logic.receiverImage ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).paddingOnly(bottom: 10),
                    ).paddingOnly(top: Get.height * 0.1),
                    Text(
                      logic.receiverName ?? '',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 22,
                        fontColor: AppColors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            logic.callType == "audio"
                                ? EnumLocale.txtAudioCalling.name.tr
                                : EnumLocale.txtVideoCalling.name.tr,
                            style: AppFontStyle.fontStyleW600(
                                fontSize: 20, fontColor: AppColors.white)),
                        Lottie.asset(
                          AppAsset.callDotLoadingWhite,
                          height: 30,
                        ).paddingOnly(top: 10)
                      ],
                    ).paddingOnly(bottom: Get.height * 0.5),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GetBuilder<FakeOutgoingCallController>(
              id: Constant.idSpeakerOpen,
              builder: (logic) {
                return GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.red),
                      child: Image.asset(AppAsset.callCut).paddingAll(15)),
                );
              },
            ).paddingOnly(left: 40, right: 40, bottom: 100),
          ),
        ],
      ),
    );
  }
}

class FakeAudioOutgoingCallView extends StatelessWidget {
  const FakeAudioOutgoingCallView({super.key});
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _screenBg = AppColors.redesignScreenBackground;
  static final Color _bottomPanel = AppColors.redesignBrandDarkAlt;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeOutgoingCallController>(
        id: Constant.idVideoCall,
        builder: (logic) {
          final title = (logic.receiverName ?? '').trim().isEmpty
              ? 'Expert'
              : logic.receiverName!.trim();
          final speakerLabel = logic.isSpeakerOn
              ? EnumLocale.txtSpeaker.name.tr
              : EnumLocale.txtEarpiece.name.tr;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final horizontalPadding = isCompact ? 14.0 : 18.0;
                final contentWidth = constraints.maxWidth > 560 ? 460.0 : 430.0;
                final avatarSize = isCompact ? 88.0 : 102.0;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _screenBg,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.white,
                              _screenBg,
                              _screenBg,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      left: -20,
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _brandRed.withValues(alpha: 0.16),
                              _brandRed.withValues(alpha: 0.02),
                              AppColors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            10,
                            horizontalPadding,
                            8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: NotisboardWordmark(
                                  style: AppFontStyle.fontStyleKaushanW400(
                                    font: FontWeight.w600,
                                    fontSize: isCompact ? 24 : 28,
                                    fontColor: _brandRed,
                                  ),
                                  baseColor: _brandRed,
                                  highlightColor: _brandDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: _softBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 12,
                                      color: _brandDark,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      EnumLocale.txtSecure.name.tr,
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 9,
                                        fontColor: _brandDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: contentWidth),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                    horizontalPadding,
                                    6,
                                    horizontalPadding,
                                    10,
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                    isCompact ? 14 : 18,
                                    16,
                                    isCompact ? 14 : 18,
                                    18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: _softBorder),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black
                                            .withValues(alpha: 0.07),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 3,
                                        width: 56,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          gradient: LinearGradient(
                                            colors: [_brandRed, _brandRedDark],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        height: avatarSize,
                                        width: avatarSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [_brandRed, _brandRedDark],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: ClipOval(
                                            child: CustomProfileImage(
                                              image: logic.receiverImage ?? '',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: isCompact ? 24 : 28,
                                          fontColor: _brandDark,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors
                                              .redesignSurfaceNeutralAlt,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border:
                                              Border.all(color: _softBorder),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              size: 13,
                                              color: _mutedText,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              EnumLocale
                                                  .txtEndToEndEncrypted.name.tr,
                                              style: AppFontStyle.fontStyleW500(
                                                fontSize: 11,
                                                fontColor: _mutedText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [_brandRed, _brandRedDark],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _brandRed.withValues(
                                                  alpha: 0.28),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              EnumLocale.txtCalling.name.tr,
                                              style: AppFontStyle.fontStyleW600(
                                                fontSize: isCompact ? 18 : 20,
                                                fontColor: AppColors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 1),
                                            SizedBox(
                                              width: 22,
                                              height: 16,
                                              child: Lottie.asset(
                                                AppAsset.callDotLoadingWhite,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            14,
                            horizontalPadding,
                            12,
                          ),
                          decoration: BoxDecoration(
                            color: _bottomPanel,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.18),
                                blurRadius: 20,
                                offset: const Offset(0, -8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _FakeCallControlButton(
                                  icon: logic.micMute
                                      ? AppAsset.micMute
                                      : AppAsset.microPhoneIcon,
                                  label: EnumLocale.txtMute.name.tr,
                                  value: logic.micMute
                                      ? EnumLocale.txtOn.name.tr
                                      : EnumLocale.txtOff.name.tr,
                                  isActive: logic.micMute,
                                  onTap: logic.toggleMicMute,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FakeCallControlButton(
                                  icon: logic.isSpeakerOn
                                      ? AppAsset.speakerOn
                                      : AppAsset.speakerOff,
                                  label: speakerLabel,
                                  value: EnumLocale.txtOn.name.tr,
                                  isActive: logic.isSpeakerOn,
                                  onTap: logic.toggleSpeaker,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FakeCallControlButton(
                                  icon: AppAsset.callCut,
                                  label: EnumLocale.txtEndCall.name.tr,
                                  isDanger: true,
                                  onTap: () {
                                    Get.back();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        });
  }
}

class _FakeCallControlButton extends StatelessWidget {
  const _FakeCallControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.isDanger = false,
    this.isActive = false,
  });

  final String icon;
  final String label;
  final String? value;
  final bool isDanger;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconBackground = isDanger
        ? AppColors.redesignBrandRed
        : (isActive ? AppColors.redesignAccentSoftBg : AppColors.white);
    final Color borderColor = isDanger
        ? AppColors.redesignBrandRed
        : (isActive
            ? AppColors.redesignBrandRed.withValues(alpha: 0.55)
            : AppColors.transparent);
    final Color iconColor =
        isDanger ? AppColors.white : AppColors.redesignBrandDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.4),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  color: iconColor,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.fontStyleW600(
                fontSize: 13,
                fontColor: AppColors.white,
              ),
            ),
            if ((value ?? '').trim().isNotEmpty)
              Text(
                value!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: AppColors.white.withValues(alpha: 0.75),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

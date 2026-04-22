import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/notisboard_wordmark.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/incoming_call_screen/controller/incoming_call_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

/// =================== Incoming Call View =================== ///
class IncomingCallView extends StatelessWidget {
  const IncomingCallView({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _panelDark = AppColors.redesignBrandDarkAlt;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IncomingCallController>(
      id: Constant.idVideoCall,
      builder: (logic) {
        final isAudioCall = (logic.callType ?? '').toLowerCase() == 'audio';
        final callerName = (logic.callerName ?? '').trim().isEmpty
            ? 'Unknown Caller'
            : logic.callerName!.trim();
        final callTitle = isAudioCall
            ? EnumLocale.txtIncomingAudioCalling.name.tr
            : EnumLocale.txtIncomingVoiceCalling.name.tr;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            final horizontalPadding = isCompact ? 14.0 : 18.0;
            final cardWidth = constraints.maxWidth > 560 ? 430.0 : 410.0;
            final avatarSize = isCompact ? 106.0 : 120.0;

            return Stack(
              children: [
                Positioned.fill(
                  child: CustomProfileImage(
                    image: logic.callerImage ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      color: AppColors.white.withValues(alpha: 0.24),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white.withValues(alpha: 0.18),
                          AppColors.black.withValues(alpha: 0.16),
                          AppColors.black.withValues(alpha: 0.30),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
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
                                color: AppColors.white.withValues(alpha: 0.94),
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
                                    'Secure',
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
                              constraints: BoxConstraints(maxWidth: cardWidth),
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  8,
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
                                  color:
                                      AppColors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: _softBorder),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black
                                          .withValues(alpha: 0.10),
                                      blurRadius: 22,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [_brandRed, _brandRedDark],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        EnumLocale.txtIncomingCall.name.tr,
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 11,
                                          fontColor: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    RippleAnimation(
                                      color: _brandRed.withValues(alpha: 0.35),
                                      delay: const Duration(milliseconds: 220),
                                      repeat: true,
                                      minRadius: isCompact ? 48 : 54,
                                      maxRadius: isCompact ? 82 : 94,
                                      ripplesCount: 3,
                                      duration: const Duration(seconds: 2),
                                      child: Container(
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
                                              image: logic.callerImage ?? '',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      callerName,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: isCompact ? 24 : 28,
                                        fontColor: _brandDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            callTitle,
                                            textAlign: TextAlign.center,
                                            style: AppFontStyle.fontStyleW600(
                                              fontSize: isCompact ? 16 : 17,
                                              fontColor: _mutedText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        SizedBox(
                                          width: 24,
                                          height: 16,
                                          child: Lottie.asset(
                                            AppAsset.callDotLoading,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.redesignSurfaceNeutralAlt,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(color: _softBorder),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          12,
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                        decoration: BoxDecoration(
                          color: _panelDark.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.24),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _IncomingActionButton(
                                icon: Icons.call_end_rounded,
                                label: 'Decline',
                                backgroundColor: _brandRed,
                                foregroundColor: AppColors.white,
                                onTap: () async {
                                  await logic.onCallDecline();
                                  if (Get.currentRoute ==
                                      AppRoutes.incomingCallScreen) {
                                    Get.back();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _IncomingActionButton(
                                icon: Icons.call_rounded,
                                label: 'Accept',
                                backgroundColor: AppColors.white,
                                foregroundColor: _brandDark,
                                onTap: () async {
                                  await logic.onCallAccept();
                                },
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
    );
  }
}

class _IncomingActionButton extends StatelessWidget {
  const _IncomingActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: foregroundColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFontStyle.fontStyleW600(
                fontSize: 14,
                fontColor: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

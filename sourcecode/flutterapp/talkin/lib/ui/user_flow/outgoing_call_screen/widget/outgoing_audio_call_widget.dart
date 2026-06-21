import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/notisboard_wordmark.dart';
import 'package:notisboard/socket/socket_emit.dart';
import 'package:notisboard/ui/user_flow/outgoing_call_screen/controller/outgoing_call_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class OutgoingAudioCallView extends StatelessWidget {
  const OutgoingAudioCallView({super.key});
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _screenBg = AppColors.redesignScreenBackground;
  static final Color _bottomPanel = AppColors.redesignBrandDarkAlt;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OutgoingCallController>(
        id: Constant.idVideoCall,
        builder: (logic) {
          final title = (logic.receiverName ?? '').trim().isEmpty
              ? 'Expert'
              : logic.receiverName!.trim();

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final horizontalPadding = isCompact ? 14.0 : 18.0;
                final contentWidth = constraints.maxWidth > 560 ? 460.0 : 430.0;
                final avatarSize = isCompact ? 88.0 : 102.0;
                final controlSize = isCompact ? 38.0 : 42.0;
                final dangerControlSize = isCompact ? 44.0 : 46.0;
                final controlGap = isCompact ? 9.0 : 11.0;
                final controlTrayMaxWidth = isCompact ? 250.0 : 282.0;

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
                          margin: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            6,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: controlTrayMaxWidth),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 6 : 7,
                                  vertical: isCompact ? 6 : 7,
                                ),
                                decoration: BoxDecoration(
                                  color: _bottomPanel.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color:
                                        AppColors.white.withValues(alpha: 0.14),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black
                                          .withValues(alpha: 0.24),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _CallControlButton(
                                      iconData: logic.micMute
                                          ? Icons.mic_off_rounded
                                          : Icons.mic_none_rounded,
                                      isActive: logic.micMute,
                                      size: controlSize,
                                      onTap: logic.toggleMicMute,
                                    ),
                                    SizedBox(width: controlGap),
                                    _CallControlButton(
                                      iconData: logic.isSpeakerOn
                                          ? Icons.volume_up_rounded
                                          : Icons.hearing_rounded,
                                      isActive: logic.isSpeakerOn,
                                      size: controlSize,
                                      onTap: logic.toggleSpeaker,
                                    ),
                                    SizedBox(width: controlGap),
                                    _CallControlButton(
                                      iconData: Icons.call_end_rounded,
                                      isDanger: true,
                                      size: dangerControlSize,
                                      onTap: () {
                                        SocketEmit.emitCallerCallCut(
                                          callerId: logic.callerId ?? '',
                                          receiverId: logic.receiverId ?? '',
                                          callId: logic.callId ?? '',
                                          callType: logic.callType ?? '',
                                          callMode: logic.callMode ?? '',
                                          callerRole: logic.callerRole ?? '',
                                          receiverRole:
                                              logic.receiverRole ?? '',
                                        );
                                        Get.back();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.iconData,
    required this.onTap,
    this.isDanger = false,
    this.isActive = false,
    this.size = 42,
  });

  final IconData iconData;
  final bool isDanger;
  final bool isActive;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.46).clamp(15.0, 20.0);
    final Color iconBackground = isDanger
        ? AppColors.redesignBrandRed
        : (isActive
            ? AppColors.redesignAccentSoftBg.withValues(alpha: 0.95)
            : AppColors.black.withValues(alpha: 0.34));
    final Color borderColor = isDanger
        ? AppColors.redesignBrandRedDark
        : (isActive
            ? AppColors.redesignBrandRed.withValues(alpha: 0.45)
            : AppColors.white.withValues(alpha: 0.16));
    final Color iconColor = isDanger
        ? AppColors.white
        : (isActive ? AppColors.redesignBrandRed : AppColors.white);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconBackground,
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDanger ? 0.22 : 0.17),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/notisboard_wordmark.dart';
import 'package:notisboard/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

/// =================== Video Call View =================== ///
class VoiceCallView extends StatelessWidget {
  const VoiceCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Stack(
        children: [
          GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return SizedBox(
                height: Get.height,
                width: Get.width,
                child: CustomProfileImage(
                  image: logic.callerId != Database.loginUserId
                      ? logic.callerImage ?? ''
                      : logic.receiverImage ?? '',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          BlurryContainer(
            blur: 20,
            elevation: 0,
            color: AppColors.white.withValues(alpha: 0.2),
            height: Get.height,
            width: Get.width,
            child: const SizedBox(), // Empty child just to apply blur
          ),
          // Recording badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: GetBuilder<VoiceCallController>(
              id: Constant.idVideoCall,
              builder: (logic) {
                if (!logic.isRecordingActive) return const SizedBox.shrink();
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "This call is being recorded",
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Center(
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
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
                                image: logic.callerId != Database.loginUserId
                                    ? logic.callerImage ?? ''
                                    : logic.receiverImage ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      logic.callerId != Database.loginUserId
                          ? logic.callerName ?? ""
                          : logic.receiverName ?? "",
                      style: AppFontStyle.fontStyleW900(
                        fontSize: 22,
                        fontColor: AppColors.white,
                      ),
                    ),
                    Text(
                      logic.formattedTime ?? "",
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: AppColors.white,
                      ),
                    ).paddingOnly(bottom: Get.height * 0.56),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: GetBuilder<VoiceCallController>(
              id: Constant.idVideoCall,
              builder: (controller) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: AppColors.black.withValues(alpha: 0.40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GetBuilder<VoiceCallController>(
                          id: Constant.idMicMute,
                          builder: (context) {
                            return buildControlButton(
                              controller.isMicMute == true
                                  ? AppAsset.micMute
                                  : AppAsset.microPhoneIcon,
                              onTap: () {
                                controller.onMicMute();
                              },
                            );
                          }),
                      GetBuilder<VoiceCallController>(
                          id: Constant.idSpeakerOpen,
                          builder: (context) {
                            return buildControlButton(
                              // AppAsset.speakerOn,
                              controller.isSpeakerOn == false
                                  ? AppAsset.speakerOff
                                  : AppAsset.speakerOn,

                              onTap: () {
                                controller.onSpeakerOn();
                              },
                            );
                          }),
                      buildControlButton(
                        AppAsset.callCut,
                        bgColor: Colors.red,
                        onTap: () {
                          controller.endCurrentCall();
                          // Get.toNamed(AppRoutes.callCutScreen);
                        },
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 13),
                ).paddingSymmetric(horizontal: 32);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControlButton(String icon,
      {Color bgColor = Colors.white, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: bgColor,
        child: Image.asset(
          icon,
          color:
              bgColor == AppColors.white ? AppColors.darkPurple : Colors.white,
          height: 26,
          width: 26,
        ),
      ),
    );
  }
}

class VoiceCallView1 extends StatelessWidget {
  const VoiceCallView1({super.key});
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _panelDark = AppColors.redesignBrandDarkAlt;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VoiceCallController>(
      id: Constant.idVideoCall,
      builder: (controller) {
        final displayImage = controller.callerId != Database.loginUserId
            ? controller.callerImage ?? ''
            : controller.receiverImage ?? '';
        final displayName = controller.callerId != Database.loginUserId
            ? controller.callerName ?? ""
            : controller.receiverName ?? "";
        final callerName =
            displayName.trim().isEmpty ? 'Expert' : displayName.trim();
        final elapsedTime = (controller.formattedTime ?? '').trim().isEmpty
            ? '00:00'
            : controller.formattedTime!.trim();
        final isGroupSession = controller.isGroupSessionCall;
        final canManageUsers = isGroupSession && controller.isExpertController;
        final callTypeLabel =
            (controller.callType ?? '').toLowerCase() == 'audio'
                ? EnumLocale.txtAudioCalling.name.tr
                : EnumLocale.txtVideoCalling.name.tr;

        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              final horizontalPadding = isCompact ? 14.0 : 18.0;
              final cardWidth = constraints.maxWidth > 560 ? 440.0 : 420.0;
              final avatarSize = isCompact ? 92.0 : 104.0;
              final controlSize = isCompact ? 38.0 : 42.0;
              final dangerControlSize = isCompact ? 44.0 : 46.0;
              final controlGap = isCompact ? 8.0 : 10.0;
              final controlTrayMaxWidth = isCompact ? 292.0 : 336.0;

              final actionItems = <Widget>[
                GetBuilder<VoiceCallController>(
                  id: Constant.idMicMute,
                  builder: (logic) => buildControlButton(
                    iconData: logic.isMicMute
                        ? Icons.mic_off_rounded
                        : Icons.mic_none_rounded,
                    isActive: logic.isMicMute,
                    size: controlSize,
                    onTap: controller.onMicMute,
                  ),
                ),
                GetBuilder<VoiceCallController>(
                  id: Constant.idSpeakerOpen,
                  builder: (logic) => buildControlButton(
                    iconData: logic.isSpeakerOn
                        ? Icons.volume_up_rounded
                        : Icons.hearing_rounded,
                    isActive: logic.isSpeakerOn,
                    size: controlSize,
                    onTap: controller.onSpeakerOn,
                  ),
                ),
                if (isGroupSession)
                  _buildGroupToolsControlButton(
                    context,
                    controller,
                    canManageUsers: canManageUsers,
                    size: controlSize,
                  ),
                GetBuilder<VoiceCallController>(
                  id: Constant.idVideoCall,
                  builder: (logic) {
                    // if (!logic.isRecordingEligible) return const SizedBox.shrink(); // Assuming eligibility is checked and handled
                    return buildControlButton(
                      iconData: logic.isRecordingActive ? Icons.stop_circle_outlined : Icons.radio_button_checked,
                      isActive: logic.isRecordingActive,
                      onTap: () {
                        if (logic.isRecordingActive) {
                          logic.stopRecording();
                        } else if (!logic.isRecordingConsentPending) {
                          logic.requestRecording();
                        } else {
                          Utils.showToast(context, "Waiting for other person's consent...");
                        }
                      },
                      size: controlSize,
                    );
                  },
                ),
                buildControlButton(
                  iconData: Icons.call_end_rounded,
                  isDanger: true,
                  size: dangerControlSize,
                  onTap: controller.endCurrentCall,
                ),
              ];

              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.redesignScreenBackground,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.white,
                            AppColors.redesignScreenBackground,
                            AppColors.redesignScreenBackground,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -55,
                    left: -22,
                    child: Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _brandRed.withValues(alpha: 0.17),
                            _brandRed.withValues(alpha: 0.02),
                            AppColors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GetBuilder<VoiceCallController>(
                        id: Constant.idVideoCall,
                        builder: (logic) {
                          if (!logic.isRecordingActive) return const SizedBox.shrink();
                          return Container(
                            width: double.infinity,
                            color: Colors.red.withValues(alpha: 0.9),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.circle, color: Colors.white, size: 8),
                                const SizedBox(width: 6),
                                Text(
                                  "REC • This call is being recorded",
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 11,
                                    fontColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
                                    Icons.graphic_eq_rounded,
                                    size: 12,
                                    color: _brandDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    callTypeLabel,
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
                                            image: displayImage,
                                            fit: BoxFit.cover,
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
                                                alpha: 0.26),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 15,
                                            color: AppColors.white,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            elapsedTime,
                                            style: AppFontStyle.fontStyleW600(
                                              fontSize: isCompact ? 18 : 20,
                                              fontColor: AppColors.white,
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
                                color: _panelDark.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color:
                                      AppColors.white.withValues(alpha: 0.14),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.black.withValues(alpha: 0.24),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0;
                                      i < actionItems.length;
                                      i++) ...[
                                    actionItems[i],
                                    if (i != actionItems.length - 1)
                                      SizedBox(width: controlGap),
                                  ],
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
      },
    );
  }

  void _showGroupSessionActionsSheet(
    BuildContext context,
    VoiceCallController controller, {
    required bool expertMode,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(EnumLocale.txtLiveChat.name.tr),
                  trailing: GetBuilder<VoiceCallController>(
                    id: Constant.idVideoCall,
                    builder: (logic) {
                      if (logic.unreadGroupChatCount <= 0) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          logic.unreadGroupChatCount > 99
                              ? '99+'
                              : logic.unreadGroupChatCount.toString(),
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 10,
                            fontColor: AppColors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showGroupLiveChatBottomSheet(context, controller);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: Text(
                    expertMode ? 'Manage Participants' : 'Participant Audio',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showParticipantManagementSheet(
                      context,
                      controller,
                      expertMode: expertMode,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGroupLiveChatBottomSheet(
    BuildContext context,
    VoiceCallController controller,
  ) {
    controller.markGroupChatSheetOpened();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            height: Get.height * 0.72,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: SafeArea(
              top: false,
              child: GetBuilder<VoiceCallController>(
                id: Constant.idVideoCall,
                builder: (logic) {
                  final chatMessages =
                      logic.groupLiveChatMessages.reversed.toList();

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                EnumLocale.txtLiveSessionChat.name.tr,
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 16,
                                  fontColor: AppColors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: chatMessages.isEmpty
                            ? Center(
                                child: Text(
                                  EnumLocale.txtNoMessagesYet.name.tr,
                                  style: AppFontStyle.fontStyleW500(
                                    fontSize: 13,
                                    fontColor:
                                        AppColors.black.withValues(alpha: 0.55),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                itemCount: chatMessages.length,
                                itemBuilder: (context, index) {
                                  final message = chatMessages[index];
                                  return _buildGroupLiveChatBubble(message);
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: logic.groupLiveChatInputController,
                                textInputAction: TextInputAction.send,
                                minLines: 1,
                                maxLines: 4,
                                onSubmitted: (value) {
                                  logic.sendGroupChatMessage(value);
                                },
                                decoration: InputDecoration(
                                  hintText: EnumLocale.txtTypeAMessage.name.tr,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                logic.sendGroupChatMessage(
                                  logic.groupLiveChatInputController.text,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.appColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    ).whenComplete(controller.markGroupChatSheetClosed);
  }

  Widget _buildGroupLiveChatBubble(GroupLiveChatMessage message) {
    final sentAt = DateTime.fromMillisecondsSinceEpoch(message.sentAtMs);
    final timeText =
        '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        constraints: BoxConstraints(maxWidth: Get.width * 0.72),
        decoration: BoxDecoration(
          color: message.isMine
              ? AppColors.appColor.withValues(alpha: 0.14)
              : AppColors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Text(
                message.senderName,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 11,
                  fontColor: AppColors.black.withValues(alpha: 0.8),
                ),
              ).paddingOnly(bottom: 3),
            Text(
              message.message,
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.black,
              ),
            ),
            Text(
              timeText,
              style: AppFontStyle.fontStyleW500(
                fontSize: 10,
                fontColor: AppColors.black.withValues(alpha: 0.45),
              ),
            ).paddingOnly(top: 4),
          ],
        ),
      ),
    );
  }

  void _showParticipantManagementSheet(
    BuildContext context,
    VoiceCallController controller, {
    required bool expertMode,
  }) {
    final participants = controller.manageableUsers;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expertMode ? 'Manage Participants' : 'Participant Audio',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.black,
                  ),
                ),
                const SizedBox(height: 10),
                if (participants.isEmpty)
                  Text(
                    EnumLocale.txtNoActiveUsersToManage.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 13,
                      fontColor: AppColors.black.withValues(alpha: 0.7),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: Get.height * 0.55),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: participants.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppColors.black.withValues(alpha: 0.08),
                        height: 14,
                      ),
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        return _buildParticipantControlRow(
                          participant,
                          controller,
                          expertMode: expertMode,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipantControlRow(
    ZegoUser participant,
    VoiceCallController controller, {
    required bool expertMode,
  }) {
    final name = participant.userName.trim().isEmpty
        ? participant.userID
        : participant.userName;
    final locallyMuted = controller.isLocalUserAudioMuted(participant.userID);
    final expertMuted = controller.isExpertUserAudioMuted(participant.userID);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppFontStyle.fontStyleW600(
            fontSize: 13,
            fontColor: AppColors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          participant.userID,
          style: AppFontStyle.fontStyleW500(
            fontSize: 11,
            fontColor: AppColors.black.withValues(alpha: 0.55),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildParticipantActionChip(
              label: locallyMuted ? 'Unmute For Me' : 'Mute For Me',
              onTap: () => controller.setLocalUserAudioMuted(
                participant.userID,
                muted: !locallyMuted,
              ),
            ),
            if (expertMode)
              _buildParticipantActionChip(
                label:
                    expertMuted ? 'Unmute For Everyone' : 'Mute For Everyone',
                onTap: () => controller.hostMuteUserAudio(
                  participant.userID,
                  mute: !expertMuted,
                ),
              ),
            if (expertMode)
              _buildParticipantActionChip(
                label: 'Remove',
                isDanger: true,
                onTap: () => controller.hostRemoveUser(participant.userID),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantActionChip({
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDanger
              ? Colors.red.withValues(alpha: 0.12)
              : AppColors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 11,
            fontColor: isDanger ? Colors.red : AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupToolsControlButton(
    BuildContext context,
    VoiceCallController controller, {
    required bool canManageUsers,
    required double size,
  }) {
    return GetBuilder<VoiceCallController>(
      id: Constant.idVideoCall,
      builder: (logic) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            buildControlButton(
              iconData: Icons.forum_outlined,
              size: size,
              onTap: () {
                _showGroupSessionActionsSheet(
                  context,
                  controller,
                  expertMode: canManageUsers,
                );
              },
            ),
            if (logic.unreadGroupChatCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _brandRed,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.white, width: 1),
                  ),
                  child: Text(
                    logic.unreadGroupChatCount > 99
                        ? '99+'
                        : logic.unreadGroupChatCount.toString(),
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 8,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildControlButton({
    String? iconAsset,
    IconData? iconData,
    bool isDanger = false,
    bool isActive = false,
    VoidCallback? onTap,
    double size = 42,
  }) {
    assert(iconAsset != null || iconData != null);

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
    final Color iconColor =
        isDanger ? AppColors.white : (isActive ? _brandRed : AppColors.white);

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
          child: iconData != null
              ? Icon(
                  iconData,
                  color: iconColor,
                  size: iconSize,
                )
              : Image.asset(
                  iconAsset!,
                  color: iconColor,
                  height: iconSize,
                  width: iconSize,
                ),
        ),
      ),
    );
  }
}

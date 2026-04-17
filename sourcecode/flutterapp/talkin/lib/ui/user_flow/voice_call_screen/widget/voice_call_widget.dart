import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(
          "Notisboard",
          style: AppFontStyle.fontStyleKaushanW400(
            font: FontWeight.w600,
            fontSize: 32,
            fontColor: AppColors.black,
          ),
        )).paddingOnly(bottom: Get.height * 0.02, top: Get.height * 0.06),
        GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child: CustomProfileImage(
                      image: logic.callerId != Database.loginUserId
                          ? logic.callerImage ?? ''
                          : logic.receiverImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  )).paddingOnly(bottom: 20);
            }),
        GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Text(
                logic.callerId != Database.loginUserId
                    ? logic.callerName ?? ""
                    : logic.receiverName ?? "",
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 22,
                  fontColor: AppColors.black,
                ),
              ).paddingOnly(bottom: 15);
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: AppColors.appColor, size: 15),
            Text(
              EnumLocale.txtEndToEndEncrypted.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.black.withValues(alpha: 0.80),
              ),
            ),
          ],
        ).paddingOnly(bottom: 15),
        GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Text(
                logic.formattedTime ?? "",
                style: AppFontStyle.fontStyleW500(
                  fontSize: 21,
                  fontColor: AppColors.black,
                ),
              );
            }),
        Spacer(),
        GetBuilder<VoiceCallController>(
          id: Constant.idVideoCall,
          builder: (controller) {
            final isGroupSession = controller.isGroupSessionCall;
            final canManageUsers =
                isGroupSession && controller.isExpertController;

            return Container(
              padding:
                  EdgeInsets.only(top: 20, bottom: 20, left: 22, right: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: AppColors.black.withValues(alpha: 0.80),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetBuilder<VoiceCallController>(
                      id: Constant.idMicMute,
                      builder: (logic) {
                        return buildControlButton(
                          text:
                              "${EnumLocale.txtMute.name.tr} \n${logic.isMicMute ? EnumLocale.txtOn.name.tr : EnumLocale.txtOff.name.tr}",
                          iconColor: AppColors.appColor,
                          icon: controller.isMicMute == true
                              ? AppAsset.micMute
                              : AppAsset.microPhoneIcon,
                          onTap: () {
                            controller.onMicMute();
                          },
                        );
                      }),
                  GetBuilder<VoiceCallController>(
                      id: Constant.idSpeakerOpen,
                      builder: (logic) {
                        return buildControlButton(
                          text:
                              '${logic.isSpeakerOn ? EnumLocale.txtSpeaker.name.tr : EnumLocale.txtEarpiece.name.tr}\n${EnumLocale.txtOn.name.tr}',
                          iconColor: AppColors.appColor,
                          icon: controller.isSpeakerOn == false
                              ? AppAsset.speakerOff
                              : AppAsset.speakerOn,
                          onTap: () {
                            controller.onSpeakerOn();
                          },
                        );
                      }),
                  if (isGroupSession)
                    buildControlButton(
                      text: 'Group\nTools',
                      icon: AppAsset.circleMoreIcon,
                      iconColor: AppColors.appColor,
                      onTap: () {
                        _showGroupSessionActionsSheet(
                          context,
                          controller,
                          expertMode: canManageUsers,
                        );
                      },
                    ),
                  buildControlButton(
                    text: EnumLocale.txtEndCall.name.tr,
                    icon: AppAsset.callCut,
                    iconColor: AppColors.white,
                    bgColor: Colors.red,
                    onTap: () {
                      controller.endCurrentCall();
                      // Get.toNamed(AppRoutes.callCutScreen);
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 13),
            );
          },
        ),
      ],
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
                  title: const Text('Live Chat'),
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
                                'Live Session Chat',
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
                                  'No messages yet',
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
                                  hintText: 'Type a message...',
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
                    'No active users to manage',
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

  Widget buildControlButton(
      {String? icon,
      Color bgColor = Colors.white,
      Color iconColor = Colors.white,
      VoidCallback? onTap,
      String text = ''}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: bgColor),
            child: Image.asset(
              icon ?? '',
              color: iconColor,
              height: 26,
              width: 26,
            ),
          ).paddingOnly(bottom: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW500(
                fontSize: 13, fontColor: AppColors.white),
          )
        ],
      ),
    );
  }
}

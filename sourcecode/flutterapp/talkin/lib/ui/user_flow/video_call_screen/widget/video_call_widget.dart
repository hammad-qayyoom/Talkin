import 'package:notisboard/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:notisboard/custom/bottom_sheet/report_block_ui_bottom_sheet.dart';
import 'package:notisboard/custom/bottom_sheet/report_bottom_sheet.dart';
import 'package:notisboard/custom/dialog/block_dialog.dart';
import 'package:notisboard/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
import 'package:notisboard/services/translation/translation_service.dart';
import 'package:notisboard/services/translation/translation_widgets.dart';
import 'package:notisboard/services/anonymous_mode/anonymous_mode_widgets.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

/// =================== Video Call View =================== ///
class VideoCallView1 extends StatelessWidget {
  const VideoCallView1({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.0),
      ),
      child: SizedBox(
        height: Get.height,
        width: Get.width,
        child: GetBuilder<VideoCallController>(
          id: Constant.idVideoCall,
          builder: (logic) {
            final viewport = Size(Get.width, Get.height);
            final isCompactControls = viewport.width < 390;
            final controlSize = isCompactControls ? 32.0 : 36.0;
            final dangerControlSize = isCompactControls ? 36.0 : 40.0;
            final controlBarPadding = isCompactControls ? 4.0 : 5.0;
            final controlGap = isCompactControls ? 6.0 : 8.0;
            final controlTrayMaxWidth = isCompactControls ? 328.0 : 368.0;
            logic.prepareSelfPreviewLayout(
              viewport,
              topPadding: 72,
              bottomPadding: 136,
              horizontalPadding: 12,
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: _buildRemoteVideoArea(logic),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.black.withValues(alpha: 0.45),
                            AppColors.transparent,
                            AppColors.black.withValues(alpha: 0.58),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildSelfPreviewOverlay(logic, viewport),
                if (logic.isRecordingActive)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      color: Colors.red.withValues(alpha: 0.9),
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 4, bottom: 4),
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
                    ),
                  ),
                Positioned(
                  top: logic.isRecordingActive ? MediaQuery.of(context).padding.top + 34 : 44,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppAsset.starCoin,
                                  height: 17,
                                  width: 17,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  Database.fetchLoginUserProfileModel?.user
                                              ?.isListener ==
                                          true
                                      ? Database.listenerCoin.toString()
                                      : Database.userCoin.toString(),
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 12,
                                    fontColor: AppColors.yellow,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  logic.formattedTime.toString(),
                                  style: AppFontStyle.fontStyleW500(
                                    fontColor: AppColors.white,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  AppAsset.flagIcon,
                                  height: 10,
                                  width: 10,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 18,
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: controlTrayMaxWidth),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: controlBarPadding,
                          vertical: controlBarPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.54),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ControlButton(
                              iconData: logic.micMute == true
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_none_rounded,
                              isActive: logic.micMute,
                              size: controlSize,
                              onTap: logic.onMicMute,
                            ),
                            SizedBox(width: controlGap),
                            ControlButton(
                              iconData: logic.isCameraOff == true
                                  ? Icons.videocam_off_rounded
                                  : Icons.videocam_outlined,
                              isActive: logic.isCameraOff,
                              size: controlSize,
                              onTap: logic.onCameraOff,
                            ),
                            SizedBox(width: controlGap),
                            ControlButton(
                              iconData: Icons.flip_camera_android_rounded,
                              size: controlSize,
                              onTap: logic.onCameraTurn,
                            ),
                            SizedBox(width: controlGap),
                            ControlButton(
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
                            ),
                            SizedBox(width: controlGap),
                            GetBuilder<TranslationService>(
                              id: Constant.idTranslation,
                              builder: (service) {
                                return ControlButton(
                                  iconData: Icons.translate,
                                  isActive: service.isActive,
                                  onTap: () {
                                    if (!service.isEnabled) {
                                      Utils.showToast(context, "Translation is not enabled. Please check settings.");
                                      return;
                                    }
                                    logic.toggleTranslation();
                                  },
                                  size: controlSize,
                                );
                              },
                            ),
                            SizedBox(width: controlGap),
                            AnonymousModeToggle(
                              onTap: () => showAnonymousModePanel(context),
                              size: controlSize,
                            ),
                            SizedBox(width: controlGap),
                            logic.isGroupSessionCall
                                ? _buildGroupChatControlButton(
                                    context,
                                    logic,
                                    size: controlSize,
                                  )
                                : ControlButton(
                                    iconData: Icons.more_horiz_rounded,
                                    size: controlSize,
                                    onTap: () => _openMoreOptionsBottomSheet(
                                      context,
                                      logic,
                                    ),
                                  ),
                            SizedBox(width: controlGap),
                            ControlButton(
                              iconData: Icons.call_end_rounded,
                              isDanger: true,
                              size: dangerControlSize,
                              onTap: logic.endCurrentCall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SubtitleOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openMoreOptionsBottomSheet(
    BuildContext context,
    VideoCallController logic,
  ) {
    showMoreOptionsBottomSheet(
      context: context,
      isHost: Database.isListener,
      userId: Database.loginUserId,
      onBlock: () {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: BlockDialog(
              hostId: Database.fetchListenerProfileModel?.data?.id ?? '',
              isHost: ((Database.fetchListenerProfileModel?.data?.id ?? '')
                      .isNotEmpty)
                  ? false
                  : true,
              userId: Database.loginUserId,
              onTapCall: logic.endCurrentCall,
            ),
          ),
        );
      },
      onReport: () {
        ReportBottomSheetUi.show(
          context: context,
          reportType: 'user',
          targetId: logic.receiverId ?? '',
        );
      },
    );
  }

  Widget _buildGroupChatControlButton(
    BuildContext context,
    VideoCallController logic, {
    required double size,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ControlButton(
          iconData: Icons.forum_outlined,
          size: size,
          onTap: () => _showGroupSessionActionsSheet(context, logic),
        ),
        if (logic.unreadGroupChatCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                logic.unreadGroupChatCount > 99
                    ? '99+'
                    : logic.unreadGroupChatCount.toString(),
                style: AppFontStyle.fontStyleW600(
                  fontSize: 9,
                  fontColor: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showGroupSessionActionsSheet(
    BuildContext context,
    VideoCallController controller,
  ) {
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
            child: GetBuilder<VideoCallController>(
              id: Constant.idVideoCall,
              builder: (logic) {
                final participantCount = logic.joinedParticipantCount;
                final expertMode = logic.isExpertController;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(EnumLocale.txtLiveChat.name.tr),
                      trailing: logic.unreadGroupChatCount <= 0
                          ? const SizedBox.shrink()
                          : Container(
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
                            ),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _showGroupLiveChatBottomSheet(context, controller);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: Text(
                        expertMode
                            ? 'Manage Participants'
                            : 'Participant Controls',
                      ),
                      subtitle: Text(
                        participantCount == 1
                            ? '1 participant joined'
                            : '$participantCount participants joined',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: AppColors.black.withValues(alpha: 0.55),
                        ),
                      ),
                      trailing: Container(
                        constraints: const BoxConstraints(minWidth: 28),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          participantCount.toString(),
                          textAlign: TextAlign.center,
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor: AppColors.black.withValues(alpha: 0.72),
                          ),
                        ),
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showGroupLiveChatBottomSheet(
    BuildContext context,
    VideoCallController logic,
  ) {
    logic.markGroupChatSheetOpened();

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
              child: GetBuilder<VideoCallController>(
                id: Constant.idVideoCall,
                builder: (controller) {
                  final chatMessages =
                      controller.groupLiveChatMessages.reversed.toList();

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
                                  return _buildGroupLiveChatMessageBubble(
                                    message,
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    controller.groupLiveChatInputController,
                                textInputAction: TextInputAction.send,
                                minLines: 1,
                                maxLines: 4,
                                onSubmitted: (value) {
                                  controller.sendGroupChatMessage(value);
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
                                controller.sendGroupChatMessage(
                                  controller.groupLiveChatInputController.text,
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
    ).whenComplete(logic.markGroupChatSheetClosed);
  }

  void _showParticipantManagementSheet(
    BuildContext context,
    VideoCallController controller, {
    required bool expertMode,
  }) {
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
            child: GetBuilder<VideoCallController>(
              id: Constant.idVideoCall,
              builder: (logic) {
                final participants = logic.manageableParticipants;
                final participantCount = participants.length;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expertMode
                          ? 'Manage Participants'
                          : 'Participant Controls',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 16,
                        fontColor: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      participantCount == 1
                          ? '1 participant joined'
                          : '$participantCount participants joined',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.black.withValues(alpha: 0.62),
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
                        constraints:
                            BoxConstraints(maxHeight: Get.height * 0.55),
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
                              logic,
                              expertMode: expertMode,
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipantControlRow(
    VideoParticipantEntry participant,
    VideoCallController controller, {
    required bool expertMode,
  }) {
    final streamID = (participant.streamID ?? '').trim();
    final hasStream = streamID.isNotEmpty;
    final localAudioMuted =
        hasStream ? controller.isLocalRemoteAudioMuted(streamID) : false;
    final localVideoPaused =
        hasStream ? controller.isLocalRemoteVideoMuted(streamID) : false;
    final expertAudioMuted =
        hasStream ? controller.isExpertRemoteAudioMuted(streamID) : false;
    final expertVideoMuted =
        hasStream ? controller.isExpertRemoteVideoMuted(streamID) : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          participant.userName,
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
              label: localAudioMuted ? 'Unmute For Me' : 'Mute For Me',
              enabled: hasStream,
              onTap: () => controller.setLocalRemoteAudioMuted(
                streamID,
                muted: !localAudioMuted,
              ),
            ),
            _buildParticipantActionChip(
              label: localVideoPaused
                  ? 'Resume Video For Me'
                  : 'Pause Video For Me',
              enabled: hasStream,
              onTap: () => controller.setLocalRemoteVideoMuted(
                streamID,
                muted: !localVideoPaused,
              ),
            ),
            if (expertMode)
              _buildParticipantActionChip(
                label: expertAudioMuted
                    ? 'Unmute Audio For Everyone'
                    : 'Mute Audio For Everyone',
                enabled: hasStream,
                onTap: () => controller.hostMuteUserAudio(
                  streamID,
                  mute: !expertAudioMuted,
                ),
              ),
            if (expertMode)
              _buildParticipantActionChip(
                label: expertVideoMuted
                    ? 'Unmute Video For Everyone'
                    : 'Mute Video For Everyone',
                enabled: hasStream,
                onTap: () => controller.hostMuteUserVideo(
                  streamID,
                  mute: !expertVideoMuted,
                ),
              ),
            if (expertMode)
              _buildParticipantActionChip(
                label: 'Remove',
                enabled: hasStream,
                isDanger: true,
                onTap: () => controller.hostRemoveUser(streamID),
              ),
            if (!hasStream)
              _buildParticipantActionChip(
                label: 'No media stream yet',
                enabled: false,
                onTap: () {},
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
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: enabled
              ? (isDanger
                  ? Colors.red.withValues(alpha: 0.12)
                  : AppColors.black.withValues(alpha: 0.08))
              : AppColors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 11,
            fontColor: enabled
                ? (isDanger ? Colors.red : AppColors.black)
                : AppColors.black.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupLiveChatMessageBubble(GroupLiveChatMessage message) {
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

  Widget _buildRemoteVideoArea(VideoCallController logic) {
    if (logic.isGroupSessionCall) {
      final focusedWidget = logic.focusedRemoteVideoWidget;
      final focusedId = logic.focusedRemoteStreamId;

      if (focusedWidget != null && focusedId != null) {
        return _buildFocusedParticipantView(
          logic,
          streamID: focusedId,
          focusedWidget: focusedWidget,
        );
      }

      final remoteEntries = logic.visibleRemoteVideoEntries;
      if (remoteEntries.isEmpty) {
        return Stack(
          children: [
            Container(
              color: AppColors.black,
              width: Get.width,
              height: Get.height,
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.white,
                  size: 50,
                ),
              ),
            ),
            _buildMinimizedStrip(logic),
          ],
        );
      }

      return Stack(
        children: [
          Container(
            color: AppColors.black,
            width: Get.width,
            height: Get.height,
            padding: const EdgeInsets.fromLTRB(10, 96, 10, 108),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: remoteEntries.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridAxisCount(remoteEntries.length),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (context, index) {
                final entry = remoteEntries[index];
                return _buildGroupTile(
                  logic,
                  streamID: entry.key,
                  videoWidget: entry.value,
                );
              },
            ),
          ),
          _buildMinimizedStrip(logic),
        ],
      );
    }

    return Stack(
      children: [
        Container(
          color: AppColors.black,
          width: Get.width,
          height: Get.height,
          child: Center(
            child: logic.remoteView ??
                LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.white,
                  size: 50,
                ),
          ),
        ),
        if (logic.remoteVideoOff)
          Container(
            color: AppColors.black.withValues(alpha: 0.55),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAsset.videoMute,
                    color: Colors.white,
                    height: 30,
                  ).paddingOnly(right: 12),
                  if (logic.remoteMicMute)
                    Image.asset(
                      AppAsset.micMute,
                      color: Colors.white,
                      height: 30,
                    ),
                ],
              ),
            ),
          )
        else if (logic.remoteMicMute)
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              AppAsset.micMute,
              color: Colors.white,
              height: 30,
            ),
          ),
      ],
    );
  }

  Widget _buildSelfPreviewOverlay(VideoCallController logic, Size viewport) {
    return Positioned(
      left: logic.selfPreviewLeft,
      top: logic.selfPreviewTop,
      child: GestureDetector(
        onPanUpdate: (details) {
          logic.dragSelfPreview(
            details.delta,
            viewport,
            topPadding: 72,
            bottomPadding: 136,
            horizontalPadding: 12,
          );
        },
        child: Container(
          height: logic.selfPreviewHeight,
          width: logic.selfPreviewWidth,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: logic.localView ??
                    Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: AppColors.white,
                        size: 36,
                      ),
                    ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    EnumLocale.txtYou.name.tr,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 9,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              ),
              if (logic.isCameraOff)
                Positioned.fill(
                  child: Container(
                    color: AppColors.black.withValues(alpha: 0.55),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppAsset.videoMute,
                          color: Colors.white,
                          height: 18,
                        ).paddingOnly(right: 8),
                        if (logic.micMute)
                          Image.asset(
                            AppAsset.micMute,
                            color: Colors.white,
                            height: 18,
                          ),
                      ],
                    ),
                  ),
                )
              else if (logic.micMute)
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppAsset.micMute,
                    color: Colors.white,
                    height: 18,
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    logic.resizeSelfPreview(
                      details.delta,
                      viewport,
                      topPadding: 72,
                      bottomPadding: 136,
                      horizontalPadding: 12,
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.58),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    child: const Icon(
                      Icons.open_in_full,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusedParticipantView(
    VideoCallController logic, {
    required String streamID,
    required Widget focusedWidget,
  }) {
    final locallyAudioMuted = logic.isLocalRemoteAudioMuted(streamID);
    final locallyVideoPaused = logic.isLocalRemoteVideoMuted(streamID);

    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              Container(
                color: AppColors.black,
                child: focusedWidget,
              ),
              if (locallyVideoPaused)
                _buildLocallyPausedVideoOverlay(
                  compact: false,
                  label: 'Video paused for you',
                ),
            ],
          ),
        ),
        Positioned(
          top: 88,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => logic.setFocusedRemoteStream(null),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          logic.focusedRemoteTitle,
                          maxLines: 2,
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 11,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                      if (locallyAudioMuted)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      if (locallyVideoPaused)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.visibility_off,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildParticipantActionMenu(logic, streamID),
              const SizedBox(width: 8),
              _buildTileActionButton(
                icon: Icons.minimize,
                onTap: () => logic.toggleMinimizeRemoteTile(streamID),
              ),
            ],
          ),
        ),
        _buildMinimizedStrip(logic),
      ],
    );
  }

  Widget _buildGroupTile(
    VideoCallController logic, {
    required String streamID,
    required Widget videoWidget,
  }) {
    final locallyAudioMuted = logic.isLocalRemoteAudioMuted(streamID);
    final locallyVideoPaused = logic.isLocalRemoteVideoMuted(streamID);

    return GestureDetector(
      onTap: () => logic.setFocusedRemoteStream(streamID),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: AppColors.black,
                child: videoWidget,
              ),
            ),
            if (locallyVideoPaused)
              _buildLocallyPausedVideoOverlay(
                compact: true,
                label: 'Video paused',
              ),
            Positioned(
              top: 6,
              left: 6,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          logic.remoteDisplayName(streamID),
                          maxLines: 2,
                          softWrap: true,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 9,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                      if (locallyAudioMuted)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      if (locallyVideoPaused)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.visibility_off,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTileActionButton(
                    icon: Icons.minimize,
                    onTap: () => logic.toggleMinimizeRemoteTile(streamID),
                  ),
                  const SizedBox(width: 4),
                  _buildTileActionButton(
                    icon: Icons.open_in_full,
                    onTap: () => logic.setFocusedRemoteStream(streamID),
                  ),
                  const SizedBox(width: 4),
                  _buildParticipantActionMenu(logic, streamID),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLocallyPausedVideoOverlay({
    required bool compact,
    required String label,
  }) {
    return Positioned.fill(
      child: Container(
        color: AppColors.black.withValues(alpha: 0.72),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_off,
                size: compact ? 20 : 24,
                color: Colors.white,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppFontStyle.fontStyleW600(
                  fontSize: compact ? 10 : 12,
                  fontColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantActionMenu(
    VideoCallController logic,
    String streamID,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.more_vert,
          size: 16,
          color: Colors.white,
        ),
        onSelected: (value) {
          switch (value) {
            case 'local_toggle_audio':
              logic.setLocalRemoteAudioMuted(
                streamID,
                muted: !logic.isLocalRemoteAudioMuted(streamID),
              );
              break;
            case 'local_toggle_video':
              logic.setLocalRemoteVideoMuted(
                streamID,
                muted: !logic.isLocalRemoteVideoMuted(streamID),
              );
              break;
            case 'mute_audio':
              logic.hostMuteUserAudio(streamID, mute: true);
              break;
            case 'unmute_audio':
              logic.hostMuteUserAudio(streamID, mute: false);
              break;
            case 'mute_video':
              logic.hostMuteUserVideo(streamID, mute: true);
              break;
            case 'unmute_video':
              logic.hostMuteUserVideo(streamID, mute: false);
              break;
            case 'kick':
              logic.hostRemoveUser(streamID);
              break;
          }
        },
        itemBuilder: (context) {
          final expertAudioMuted = logic.isExpertRemoteAudioMuted(streamID);
          final expertVideoMuted = logic.isExpertRemoteVideoMuted(streamID);

          final items = <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'local_toggle_audio',
              child: Text(
                logic.isLocalRemoteAudioMuted(streamID)
                    ? 'Resume Audio For Me'
                    : 'Pause Audio For Me',
              ),
            ),
            PopupMenuItem<String>(
              value: 'local_toggle_video',
              child: Text(
                logic.isLocalRemoteVideoMuted(streamID)
                    ? 'Resume Video For Me'
                    : 'Pause Video For Me',
              ),
            ),
          ];

          if (logic.isExpertController) {
            items.addAll([
              PopupMenuItem<String>(
                value: expertAudioMuted ? 'unmute_audio' : 'mute_audio',
                child: Text(
                  expertAudioMuted
                      ? 'Unmute Audio For Everyone'
                      : 'Mute Audio For Everyone',
                ),
              ),
              PopupMenuItem<String>(
                value: expertVideoMuted ? 'unmute_video' : 'mute_video',
                child: Text(
                  expertVideoMuted
                      ? 'Unmute Video For Everyone'
                      : 'Mute Video For Everyone',
                ),
              ),
              PopupMenuItem<String>(
                value: 'kick',
                child: Text(EnumLocale.txtRemoveFromSession.name.tr),
              ),
            ]);
          }

          return items;
        },
      ),
    );
  }

  Widget _buildMinimizedStrip(VideoCallController logic) {
    final minimizedEntries = logic.minimizedRemoteVideoEntries;
    if (minimizedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 10,
      right: 10,
      bottom: 120,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: minimizedEntries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = minimizedEntries[index];
              final streamID = entry.key;
              return InkWell(
                onTap: () => logic.toggleMinimizeRemoteTile(streamID),
                child: Container(
                  width: 100,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        logic.remoteDisplayName(streamID),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        softWrap: true,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 9,
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
      ),
    );
  }

  int _gridAxisCount(int count) {
    if (count <= 1) return 1;
    if (count <= 4) return 2;
    if (count <= 9) return 3;
    return 4;
  }
}

class ControlButton extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final bool isDanger;
  final bool isActive;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final VoidCallback? onTap;

  const ControlButton({
    super.key,
    this.icon,
    this.iconData,
    this.isDanger = false,
    this.isActive = false,
    this.backgroundColor,
    this.iconColor,
    this.size = 50,
    this.onTap,
  }) : assert(icon != null || iconData != null);

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.46).clamp(15.0, 20.0);
    final resolvedBackground = backgroundColor ??
        (isDanger
            ? AppColors.redesignBrandRed
            : (isActive
                ? AppColors.redesignAccentSoftBg.withValues(alpha: 0.94)
                : AppColors.black.withValues(alpha: 0.36)));
    final resolvedIconColor = iconColor ??
        (isDanger
            ? AppColors.white
            : (isActive ? AppColors.redesignBrandRed : AppColors.white));
    final borderColor = isDanger
        ? AppColors.redesignBrandRedDark
        : (isActive
            ? AppColors.redesignBrandRed.withValues(alpha: 0.5)
            : AppColors.white.withValues(alpha: 0.15));

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
          color: resolvedBackground,
          border: Border.all(color: borderColor, width: 1.15),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDanger ? 0.20 : 0.16),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: iconData != null
              ? Icon(
                  iconData,
                  color: resolvedIconColor,
                  size: iconSize,
                )
              : Image.asset(
                  icon!,
                  color: resolvedIconColor,
                  height: iconSize,
                  width: iconSize,
                ),
        ),
      ),
    );
  }
}

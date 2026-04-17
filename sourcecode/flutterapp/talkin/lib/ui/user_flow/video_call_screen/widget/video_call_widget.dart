import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:notisboard/custom/bottom_sheet/report_block_ui_bottom_sheet.dart';
import 'package:notisboard/custom/bottom_sheet/report_bottom_sheet.dart';
import 'package:notisboard/custom/dialog/block_dialog.dart';
import 'package:notisboard/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';

/// =================== Video Call View =================== ///
class VideoCallView1 extends StatelessWidget {
  const VideoCallView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withValues(alpha: 0.5),
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: GetBuilder<VideoCallController>(
          id: Constant.idVideoCall,
          builder: (logic) {
            final viewport = Size(Get.width, Get.height);
            logic.prepareSelfPreviewLayout(
              viewport,
              topPadding: 35,
              bottomPadding: 120,
              horizontalPadding: 12,
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: _buildRemoteVideoArea(logic),
                ),
                _buildSelfPreviewOverlay(logic, viewport),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: AppColors.black.withValues(alpha: 0.40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ControlButton(
                          icon: logic.micMute == true
                              ? AppAsset.micMute
                              : AppAsset.microPhoneIcon,
                          bgColor: Colors.white,
                          onTap: logic.onMicMute,
                        ),
                        ControlButton(
                          icon: logic.isCameraOff == true
                              ? AppAsset.videoMute
                              : AppAsset.videoCallIcon,
                          bgColor: Colors.white,
                          onTap: logic.onCameraOff,
                        ),
                        ControlButton(
                          icon: AppAsset.cameraFlipIcon,
                          bgColor: Colors.white,
                          onTap: logic.onCameraTurn,
                        ),
                        logic.isGroupSessionCall
                            ? _buildGroupChatControlButton(context, logic)
                            : ControlButton(
                                icon: AppAsset.circleMoreIcon,
                                bgColor: Colors.white,
                                onTap: () {
                                  showMoreOptionsBottomSheet(
                                    context: context,
                                    isHost: Database.isListener,
                                    userId: Database.loginUserId,
                                    onBlock: () {
                                      Get.dialog(
                                        barrierColor:
                                            AppColors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                        Dialog(
                                          backgroundColor:
                                              AppColors.transparent,
                                          shadowColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          elevation: 0,
                                          child: BlockDialog(
                                            hostId: Database
                                                    .fetchListenerProfileModel
                                                    ?.data
                                                    ?.id ??
                                                '',
                                            isHost:
                                                ((Database.fetchListenerProfileModel
                                                                ?.data?.id ??
                                                            '')
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
                                },
                              ),
                        ControlButton(
                          icon: AppAsset.callCut,
                          bgColor: Colors.red,
                          onTap: logic.endCurrentCall,
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 10),
                  ).paddingSymmetric(horizontal: 10),
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ).copyWith(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppColors.black.withValues(alpha: 0.40),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppAsset.starCoin,
                              height: 26,
                              width: 26,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Database.fetchLoginUserProfileModel?.user
                                          ?.isListener ==
                                      true
                                  ? Database.listenerCoin.toString()
                                  : Database.userCoin.toString(),
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 17,
                                fontColor: AppColors.yellow,
                              ),
                            ),
                          ],
                        ),
                      ).paddingOnly(bottom: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppColors.black.withValues(alpha: 0.40),
                            ),
                            child: Center(
                              child: GetBuilder<VideoCallController>(
                                id: Constant.idVideoCall,
                                builder: (controller) => Text(
                                  overflow: TextOverflow.ellipsis,
                                  controller.formattedTime.toString(),
                                  style: AppFontStyle.fontStyleW400(
                                    fontColor: AppColors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ).paddingOnly(right: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.black.withValues(alpha: 0.40),
                            ),
                            child: Center(
                              child: Image.asset(
                                AppAsset.flagIcon,
                                height: 12,
                                width: 12,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupChatControlButton(
    BuildContext context,
    VideoCallController logic,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ControlButton(
          icon: AppAsset.circleMoreIcon,
          bgColor: Colors.white,
          onTap: () => _showGroupLiveChatBottomSheet(context, logic),
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
            padding: const EdgeInsets.fromLTRB(10, 110, 10, 120),
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
            topPadding: 35,
            bottomPadding: 120,
            horizontalPadding: 12,
          );
        },
        child: Container(
          height: logic.selfPreviewHeight,
          width: logic.selfPreviewWidth,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'You',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 10,
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
                      topPadding: 35,
                      bottomPadding: 120,
                      horizontalPadding: 12,
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.58),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.open_in_full,
                      size: 14,
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
          top: 95,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
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
                constraints: const BoxConstraints(maxWidth: 132),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 10,
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
              const PopupMenuItem<String>(
                value: 'kick',
                child: Text('Remove From Session'),
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
          height: 76,
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
                  width: 82,
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
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        logic.remoteDisplayName(streamID),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 10,
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
  final String icon;
  final Color bgColor;
  final VoidCallback? onTap;

  const ControlButton({
    super.key,
    required this.icon,
    this.bgColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: bgColor,
        child: Image.asset(
          icon,
          color: bgColor == Colors.white ? AppColors.darkPurple : Colors.white,
          height: 26,
          width: 26,
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/report_block_ui_bottom_sheet.dart';
import 'package:talk_in/custom/bottom_sheet/report_bottom_sheet.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/custom_audio_time/custom_format_audio_time.dart';
import 'package:talk_in/custom/custom_chat_time/custom_format_chat_time.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/dialog/block_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:vibration/vibration.dart';

final Color _chatBrandRed = AppColors.redesignBrandRed;
final Color _chatBrandDark = AppColors.redesignBrandDark;
final Color _chatSurface = AppColors.redesignChatSurface;
final Color _chatBorder = AppColors.redesignSoftBorder;
final Color _chatMutedText = AppColors.redesignMutedText;
final Color _incomingBubble = AppColors.redesignIncomingBubble;
final Color _outgoingBubble = AppColors.redesignOutgoingBubble;

class ChatScreenAppBar extends StatelessWidget {
  const ChatScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      builder: (controller) {
        final topInset = MediaQuery.of(context).padding.top;
        final isOnline = controller.receiverStatusLabel == "true" ||
            controller.receiverStatusLabel == "Available";

        Widget actionButton({
          required Widget child,
          required VoidCallback onTap,
        }) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _chatBorder),
              ),
              child: Center(child: child),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.only(
            top: topInset + 8,
            left: 12,
            right: 12,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: _chatSurface,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              actionButton(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: _chatBrandDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.profileDetailScreenView,
                      arguments: controller.receiverId,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.redesignSurfaceNeutral,
                        ),
                        child: CustomProfileImage(
                          image: controller.receiverImage.toString(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.receiverName.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 16,
                                fontColor: _chatBrandDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: isOnline
                                    ? AppColors.redesignStatusSuccessBg
                                    : AppColors.redesignSurfaceNeutral,
                                border: Border.all(
                                  color: isOnline
                                      ? AppColors.redesignStatusSuccessBorder
                                      : _chatBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 8,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline
                                          ? AppColors.redesignStatusSuccess
                                          : _chatMutedText,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOnline
                                        ? EnumLocale.txtOnline.name.tr
                                        : 'Offline',
                                    style: AppFontStyle.fontStyleW500(
                                      fontSize: 11,
                                      fontColor: isOnline
                                          ? AppColors.redesignStatusSuccessDark
                                          : _chatMutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if ((controller.receiverId ?? '').isNotEmpty)
                actionButton(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.userBookSessionScreen,
                      arguments: {
                        'listenerId': controller.receiverId ?? '',
                        'listenerName': controller.receiverName ?? '',
                        'listenerImage': controller.receiverImage ?? '',
                        'availableForPrivateAudioCall':
                            controller.availableForPrivateAudioCall ?? true,
                        'availableForPrivateVideoCall':
                            controller.availableForPrivateVideoCall ?? true,
                        'ratePrivateAudioCall':
                            controller.ratePrivateAudioCall ?? 0,
                        'ratePrivateVideoCall':
                            controller.ratePrivateVideoCall ?? 0,
                      },
                    );
                  },
                  child: Image.asset(
                    AppAsset.calendar,
                    height: 22,
                    width: 22,
                    color: _chatBrandDark,
                  ),
                ),
              if (controller.hasBookedSessionCallContext)
                actionButton(
                  onTap: () {
                    if (controller.isBookedSessionWindowEnded) {
                      Utils.showToast(
                        context,
                        'Session slot time is completed. Call is no longer allowed.',
                      );
                      return;
                    }

                    final sessionType =
                        (controller.bookedSessionCallType ?? '').toLowerCase();
                    final allowAudio = sessionType == 'audio';
                    final allowVideo = sessionType == 'video';

                    Get.bottomSheet(
                      TalkNowButtonBottomSheet(
                        showMessage: false,
                        isFake: false,
                        fakeVideo: const [],
                        fakeAudio: '',
                        callerId: Database.loginUserId,
                        receiverId: controller.receiverId ?? '',
                        receiverName: controller.receiverName ?? '',
                        receiverImage: controller.receiverImage ?? '',
                        callerName: Database
                                .fetchLoginUserProfileModel?.user?.fullName
                                ?.toString() ??
                            '',
                        callerImage: Database
                                .fetchLoginUserProfileModel?.user?.profilePic
                                ?.toString() ??
                            '',
                        callerRole: 'user',
                        receiverRole: 'listener',
                        audioCallRatePrivate:
                            (controller.ratePrivateAudioCall ?? '0').toString(),
                        videoCallRatePrivate:
                            (controller.ratePrivateVideoCall ?? '0').toString(),
                        availableForPrivateAudioCall: allowAudio,
                        availableForPrivateVideoCall: allowVideo,
                        sessionId: controller.sessionId,
                        bookingId: controller.bookingId,
                      ),
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparent,
                    );
                  },
                  child: Image.asset(
                    AppAsset.callGradiant,
                    height: 22,
                    width: 22,
                  ),
                ),
              actionButton(
                onTap: () {
                  showMoreOptionsBottomSheet(
                    context: context,
                    isHost: Database.isListener,
                    userId: Database.loginUserId,
                    onBlock: () {
                      Get.dialog(
                        barrierColor: AppColors.black.withValues(alpha: 0.8),
                        Dialog(
                          backgroundColor: AppColors.transparent,
                          shadowColor: AppColors.transparent,
                          surfaceTintColor: AppColors.transparent,
                          elevation: 0,
                          child: BlockDialog(
                            hostId: "",
                            isHost: Database.isListener,
                            userId: Database.loginUserId,
                          ),
                        ),
                      );
                    },
                    onReport: () {
                      ReportBottomSheetUi.show(
                        context: context,
                        reportType: 'user',
                        targetId: controller.receiverId ?? '',
                      );
                    },
                  );
                },
                child: Image.asset(
                  AppAsset.circleMoreBlack,
                  height: 22,
                  width: 22,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PersonalChatBottomView extends StatelessWidget {
  const PersonalChatBottomView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              .copyWith(bottom: 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: _chatBorder),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  cursorColor: _chatBrandDark,
                  controller: controller.messageController,
                  maxLength: 1000,
                  buildCounter: (
                    BuildContext context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return null;
                  },
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 15,
                    fontColor: _chatBrandDark,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: SizedBox(
                      width: Get.width * 0.23,
                      child: Center(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Utils.showToast(
                                  Get.context!,
                                  EnumLocale.txtLongPressToEnableAudioRecording
                                      .name.tr,
                                );
                              },
                              onLongPressStart: (details) {
                                if (controller.isSendingAudioFile == false) {
                                  Vibration.vibrate(
                                      duration: 50, amplitude: 128);
                                  controller.onLongPressStartMic();
                                }
                              },
                              onLongPressEnd: (details) {
                                if (controller.isSendingAudioFile == false) {
                                  Vibration.vibrate(
                                      duration: 50, amplitude: 128);
                                  controller.onLongPressEndMic();
                                }
                              },
                              child: Image.asset(
                                AppAsset.microPhoneIcon,
                                height: 24,
                                width: 24,
                                color: _chatMutedText,
                              ).paddingOnly(right: 12, left: 4),
                            ),
                            GestureDetector(
                              onTap: () async {
                                controller.showImagePickerDialog();
                              },
                              child: Image.asset(
                                AppAsset.chatImageIcon,
                                height: 24,
                                width: 24,
                                color: _chatMutedText,
                              ).paddingOnly(right: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    hintText: "Write a message...",
                    hintStyle: AppFontStyle.fontStyleW500(
                      fontSize: 15,
                      fontColor: _chatMutedText,
                    ),
                    filled: true,
                    fillColor: _chatSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ).paddingOnly(right: 12),
              ),
              GetBuilder<PersonalChatScreenController>(
                id: Constant.idSendMsg,
                builder: (controller) {
                  return GestureDetector(
                    onTap: () {
                      controller.sendMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _chatBrandRed,
                      ),
                      child: Image.asset(
                        AppAsset.msgSendIcon,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatImageWidget extends StatelessWidget {
  final PersonalChat msg;
  final PersonalChatScreenController controller;
  final bool isRead;

  const ChatImageWidget({
    super.key,
    required this.msg,
    required this.controller,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSender =
        msg.senderId == Database.fetchLoginUserProfileModel?.user?.id;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSender) ...[
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(
                        image: controller.receiverImage.toString()),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 17),
          const SizedBox(width: 6),
        ],
        Container(
          margin: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: msg.senderId == Database.loginUserId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() =>
                      FullScreenImageView(imageUrl: msg.image.toString()));
                },
                child: Container(
                  width: 150,
                  height: 200,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SendMessageImage(
                        image: msg.image.toString(), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 150,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    Text(
                      controller.formatTimeFromDate(msg.date),
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 8,
                        fontColor: _chatMutedText,
                      ),
                    ).paddingOnly(right: 2),
                    if (Database.loginUserId == msg.senderId)
                      Image.asset(
                        isRead ? AppAsset.read2Icon : AppAsset.unreadMsgIcon,
                        height: 18,
                        width: 16,
                        color: _chatMutedText,
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
        if (isSender) ...[
          const SizedBox(width: 6),
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(
                        image: Database
                                .fetchLoginUserProfileModel?.user?.profilePic
                                .toString() ??
                            ''),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 11),
        ],
      ],
    );
  }
}

class ChatTextWidget extends StatelessWidget {
  final PersonalChat msg;
  final PersonalChatScreenController controller;
  final bool isRead;

  const ChatTextWidget({
    super.key,
    required this.msg,
    required this.controller,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = msg.senderId == Database.loginUserId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSender) ...[
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(
                        image: controller.receiverImage.toString()),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 4),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 7),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isSender ? _outgoingBubble : _incomingBubble,
              border: isSender ? null : Border.all(color: _chatBorder),
              borderRadius: isSender
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                    )
                  : const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    msg.message.toString(),
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 16,
                      fontColor: isSender ? AppColors.white : _chatBrandDark,
                    ),
                  ).paddingOnly(right: 6, top: 7, bottom: 7),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      controller.formatTimeFromDate(msg.date),
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 8,
                        fontColor: isSender ? AppColors.white : _chatMutedText,
                      ),
                    ).paddingOnly(right: 2, bottom: 4),
                    if (isSender)
                      Image.asset(
                        isRead ? AppAsset.read2Icon : AppAsset.unreadMsgIcon,
                        height: 18,
                        width: 16,
                        color: AppColors.white,
                      ),
                  ],
                ).paddingOnly(bottom: 2)
              ],
            ),
          ).paddingOnly(right: isSender ? 0 : 55, left: isSender ? 55 : 0),
        ),
        if (isSender) ...[
          const SizedBox(width: 6),
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(
                        image: Database
                                .fetchLoginUserProfileModel?.user?.profilePic
                                .toString() ??
                            ''),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 4),
        ],
      ],
    );
  }
}

class ChatVideoCallWidget extends StatelessWidget {
  final PersonalChat msg;
  final String callDuration;
  final PersonalChatScreenController controller;

  const ChatVideoCallWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.callDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.only(bottom: 3, left: 12, right: 12),
      decoration: BoxDecoration(
        color: _incomingBubble,
        border: Border.all(color: _chatBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              msg.callType == 1 || msg.callType == 2
                  ? AppAsset.chatVideoCallIcon
                  : AppAsset.missedVideoCall,
              height: 26,
              width: 26,
              // color: AppColors.darkPurple,
            ),
          ).paddingOnly(right: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtVideoCall.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 15,
                  fontColor: _chatBrandDark,
                ),
              ).paddingOnly(bottom: 4),
              if (msg.callType == 1)
                Text(
                  callDuration.toString(),
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: _chatMutedText,
                  ),
                ),
            ],
          ).paddingOnly(right: 19),
          Text(
            controller.formatTimeFromDate(msg.date),
            style: AppFontStyle.fontStyleW500(
              fontSize: 9,
              fontColor: _chatMutedText,
            ),
          ).paddingOnly(top: Get.height * 0.06),
        ],
      ),
    );
  }
}

class ChatAudioCallWidget extends StatelessWidget {
  final PersonalChat msg;
  final String audioCallDuration;
  final PersonalChatScreenController controller;

  const ChatAudioCallWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.audioCallDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.only(bottom: 3, left: 12, right: 12),
      decoration: BoxDecoration(
        color: _incomingBubble,
        border: Border.all(color: _chatBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              msg.callType == 1 || msg.callType == 2
                  ? AppAsset.callIcon
                  : AppAsset.missedAudioCall,
              height: 26,
              width: 26,
              color: msg.callType == 3 ? _chatBrandRed : _chatBrandDark,
            ),
          ).paddingOnly(right: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtAudioCall.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 15,
                  fontColor: _chatBrandDark,
                ),
              ).paddingOnly(bottom: 4),
              if (msg.callType == 1)
                Text(
                  audioCallDuration.toString(),
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: _chatMutedText,
                  ),
                ),
            ],
          ).paddingOnly(right: 19),
          Text(
            controller.formatTimeFromDate(msg.date),
            style: AppFontStyle.fontStyleW500(
              fontSize: 9,
              fontColor: _chatMutedText,
            ),
          ).paddingOnly(top: Get.height * 0.06),
        ],
      ),
    );
  }
}

class SenderAudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final String time;
  final String id;
  final dynamic chat;
  final bool isLastMessage;

  const SenderAudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.time,
    required this.id,
    required this.chat,
    required this.isLastMessage,
  });

  @override
  State<SenderAudioMessageWidget> createState() =>
      _SenderAudioMessageWidgetState();
}

class _SenderAudioMessageWidgetState extends State<SenderAudioMessageWidget> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((newDuration) {
      setState(() => duration = newDuration);
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() => position = newPosition);
      log("position=>$position");
    });

    player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  void onPlayAudio() async {
    log("uri audio::::::::::${widget.audioUrl}");

    try {
      final sanitizedUrl = widget.audioUrl.replaceAll('\\', '/');
      final fullUrl = '${Api.baseUrl}$sanitizedUrl';

      log("Attempting to play audio: $fullUrl");

      if (!isPlaying) {
        await player.play(UrlSource(fullUrl));
      } else {
        await player.pause();
      }
    } catch (e) {
      log("Audio playback error: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      // padding: const EdgeInsets.only(bottom: 3, left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: Get.width / 1.6,
            // margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _outgoingBubble,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 70,
                  width: Get.width / 1.6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 75,
                        width: Get.width / 1.6,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            GetBuilder<PersonalChatScreenController>(
                              id: Constant.idGetOldChat,
                              builder: (logic) {
                                return widget.isLastMessage
                                    ? logic.isLoadingAudio
                                        ? CupertinoActivityIndicator(
                                            color: _chatBrandRed,
                                            radius: 12,
                                          )
                                        : GestureDetector(
                                            onTap: () => onPlayAudio(),
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              size: 30,
                                              color: _chatBrandRed,
                                            )

                                            // Image.asset(isPlaying ? AppAsset.icPause1 : AppAsset.icPlay1, color: AppColors.messageColor, width: 24),
                                            )
                                    : GestureDetector(
                                        onTap: () => onPlayAudio(),
                                        child: Icon(
                                          isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 30,
                                          color: _chatBrandRed,
                                        )
                                        // Image.asset(isPlaying ? AppAsset.icPause1 : AppAsset.icPlay1, color: AppColors.messageColor, width: 24),
                                        );
                              },
                            ),
                            5.width,
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  overlayShape: SliderComponentShape.noOverlay,
                                  activeTrackColor: _chatBrandRed,
                                  thumbColor: _chatBrandRed,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 10),
                                  trackHeight: 5,
                                ),
                                child: Slider(
                                  activeColor: _chatBrandRed,
                                  min: 0,
                                  max: duration.inSeconds.toDouble() > 0
                                      ? duration.inSeconds.toDouble()
                                      : 1,
                                  value: position.inSeconds
                                      .toDouble()
                                      .clamp(0, duration.inSeconds.toDouble()),
                                  onChanged: (value) {
                                    player
                                        .seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                            ),
                            3.width,
                            Container(
                              height: 44,
                              width: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: _chatBrandRed),
                              child: Image.asset(
                                AppAsset.microPhoneIcon,
                                width: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 70,
                        child: Text(
                          isPlaying
                              ? formatTime(position)
                              : formatTime(duration),
                          style: AppFontStyle.fontStyleW600(
                              fontColor: _chatBrandRed, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
                GetBuilder<PersonalChatScreenController>(
                  builder: (logic) {
                    return Text(
                      logic.formatTimeFromDate(widget.chat.date),
                      style: AppFontStyle.fontStyleW600(
                          fontColor: AppColors.white, fontSize: 8),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(bottom: 15),
    );
  }
}

class UploadAudioUi extends StatelessWidget {
  const UploadAudioUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 75,
          width: Get.width / 1.6,
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 75,
                width: Get.width / 1.6,
                margin: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  children: [
                    // Lottie.asset(AppAsset.lottieUpload, width: 35),
                    5.width,
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          overlayShape: SliderComponentShape.noOverlay,
                          activeTrackColor: AppColors.grey,
                          thumbColor: AppColors.grey,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 10),
                          trackHeight: 5,
                        ),
                        child: Slider(
                          min: 0,
                          max: 10,
                          value: 0,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    3.width,
                    Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey,
                      ),
                      child: Image.asset(
                        AppAsset.microPhoneIcon,
                        width: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 70,
                child: Text(
                  CustomFormatAudioTime.convert(0),
                  style: AppFontStyle.fontStyleW500(
                      fontColor: _chatBrandRed, fontSize: 9),
                ),
              ),
              Positioned(
                bottom: 3,
                right: 8,
                child: Text(
                  CustomFormatChatTime.convert(DateTime.now().toString()),
                  style: AppFontStyle.fontStyleW500(
                      fontColor: AppColors.white, fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReceiverAudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final String time;
  final String id;
  final dynamic chat;
  const ReceiverAudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.time,
    required this.id,
    required this.chat,
  });

  @override
  State<ReceiverAudioMessageWidget> createState() =>
      _ReceiverAudioMessageWidgetState();
}

class _ReceiverAudioMessageWidgetState
    extends State<ReceiverAudioMessageWidget> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((newDuration) {
      setState(() => duration = newDuration);
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() => position = newPosition);
    });

    player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });

    player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
    });
  }

  void onPlayAudio() async {
    try {
      final sanitizedUrl = widget.audioUrl.replaceAll('\\', '/');
      final fullUrl = '${Api.baseUrl}$sanitizedUrl';

      log("Attempting to play audio: $fullUrl");

      if (!isPlaying) {
        await player.play(UrlSource(fullUrl));
      } else {
        await player.pause();
      }
    } catch (e) {
      log("Audio playback error: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: Get.width / 1.6,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _incomingBubble,
              border: Border.all(color: _chatBorder),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 70,
                  width: Get.width / 1.6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 75,
                        width: Get.width / 1.6,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                                onTap: () => onPlayAudio(),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 30,
                                  color: _chatBrandRed,
                                )

                                // child: Image.asset(isPlaying ? AppAsset.icPause1 : AppAsset.icPlay1, color: AppColors.pinkMessageColor, width: 24),
                                ),
                            5.width,
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  overlayShape: SliderComponentShape.noOverlay,
                                  activeTrackColor: _chatBrandRed,
                                  thumbColor: _chatBrandRed,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 10),
                                  trackHeight: 5,
                                ),
                                child: Slider(
                                  activeColor: _chatBrandRed,
                                  min: 0,
                                  max: duration.inSeconds.toDouble() > 0
                                      ? duration.inSeconds.toDouble()
                                      : 1,
                                  value: position.inSeconds
                                      .toDouble()
                                      .clamp(0, duration.inSeconds.toDouble()),
                                  onChanged: (value) {
                                    player
                                        .seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                            ),
                            3.width,
                            Container(
                              height: 44,
                              width: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: _chatBrandRed),
                              child: Image.asset(
                                AppAsset.microPhoneIcon,
                                width: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 70,
                        child: Text(
                          formatTime(position),
                          style: AppFontStyle.fontStyleW600(
                              fontColor: _chatBrandRed, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
                GetBuilder<PersonalChatScreenController>(
                  builder: (logic) {
                    return Text(
                      logic.formatTimeFromDate(widget.chat.date),
                      style: AppFontStyle.fontStyleW600(
                          fontColor: _chatMutedText, fontSize: 8),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(bottom: 15),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      direction: DismissiblePageDismissDirection.down, // drag down to dismiss
      onDismissed: () => Get.back(), // go back on dismiss
      isFullScreen: true, // optional, ensures it covers the full screen
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: SendMessageImageFullScreen(
                  image: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: CircleAvatar(
                  backgroundColor: AppColors.black.withValues(alpha: 0.54),
                  child: Icon(Icons.close, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

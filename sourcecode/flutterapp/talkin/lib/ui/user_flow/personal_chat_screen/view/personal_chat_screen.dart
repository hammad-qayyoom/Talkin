import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_audio_time/custom_format_audio_time.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/shimmer/personal_chat_screen_shimmer.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/widget/personal_chat_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class PersonalChatScreen extends StatelessWidget {
  const PersonalChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: LayoutBuilder(
        builder: (context, viewportConstraints) {
          final viewportWidth = viewportConstraints.maxWidth;
          final maxContentWidth = viewportWidth >= 760 ? 980.0 : viewportWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GetBuilder<PersonalChatScreenController>(
                    id: Constant.idGetOldChat,
                    builder: (controller) {
                      return Column(
                        children: [
                          const ChatScreenAppBar(),
                          GetBuilder<PersonalChatScreenController>(
                            id: Constant.idPagination,
                            builder: (controller) => Visibility(
                              visible: controller.isPaginationLoading,
                              child: LinearProgressIndicator(
                                color: AppColors.redesignBrandRed,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: AppColors.redesignSurfaceSoft,
                              child: SizedBox(
                                height: Get.height - 100,
                                child: controller.isLoading
                                    ? const PersonalChatScreenShimmer()
                                    : SingleChildScrollView(
                                        controller: controller.scrollController,
                                        child: ListView.builder(
                                          reverse: true,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 8,
                                          ),
                                          itemCount: controller.oldChat.length,
                                          itemBuilder: (context, index) {
                                            final isLastMessage = index == 0;

                                            final msg =
                                                controller.oldChat[index];
                                            Widget messageWidget = msg
                                                        .messageType ==
                                                    1
                                                ? ChatTextWidget(
                                                    msg: msg,
                                                    controller: controller,
                                                    isRead: msg.isRead ?? false,
                                                  )
                                                : msg.messageType == 2
                                                    ? ChatImageWidget(
                                                        msg: msg,
                                                        controller: controller,
                                                        isRead:
                                                            msg.isRead ?? false,
                                                      )
                                                    : msg.messageType == 4
                                                        ? ChatAudioCallWidget(
                                                            msg: msg,
                                                            controller:
                                                                controller,
                                                            audioCallDuration:
                                                                msg.callDuration ??
                                                                    "00:00:00",
                                                          )
                                                        : msg.messageType == 5
                                                            ? ChatVideoCallWidget(
                                                                msg: msg,
                                                                controller:
                                                                    controller,
                                                                callDuration: msg
                                                                        .callDuration ??
                                                                    "00:00:00",
                                                              )
                                                            : msg.messageType ==
                                                                    3
                                                                ? msg.senderId ==
                                                                        Database
                                                                            .loginUserId
                                                                    ? SenderAudioMessageWidget(
                                                                        audioUrl:
                                                                            msg.audio ??
                                                                                "",
                                                                        time: msg.date ??
                                                                            "",
                                                                        id: msg.id ??
                                                                            "",
                                                                        chat:
                                                                            msg,
                                                                        isLastMessage:
                                                                            isLastMessage,
                                                                      )
                                                                    : ReceiverAudioMessageWidget(
                                                                        audioUrl:
                                                                            msg.audio ??
                                                                                "",
                                                                        time: msg.date ??
                                                                            "",
                                                                        id: msg.id ??
                                                                            "",
                                                                        chat:
                                                                            msg,
                                                                      )
                                                                : const SizedBox();

                                            return Align(
                                              alignment: msg.senderId ==
                                                      Database.loginUserId
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              child: messageWidget,
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const PersonalChatBottomView(),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    bottom: 80,
                    child: GetBuilder<PersonalChatScreenController>(
                      id: Constant.idChangeAudioRecordingEvent,
                      builder: (controller) => Visibility(
                        visible: controller.isRecordingAudio,
                        child: Container(
                          height: 42,
                          width: 128,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.redesignAccentSoftBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.redesignBrandRed
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppAsset.microPhoneIcon,
                                color: AppColors.redesignBrandRed,
                                width: 20,
                              ),
                              6.width,
                              Text(
                                CustomFormatAudioTime.convert(
                                  controller.countTime,
                                ),
                                style: AppFontStyle.fontStyleW600(
                                  fontColor: AppColors.redesignBrandRed,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

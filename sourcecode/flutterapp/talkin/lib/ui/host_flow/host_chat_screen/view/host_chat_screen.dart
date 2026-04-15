import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/api/listener_chat_list_api.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/controller/host_chat_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/widget/host_chat_screen_widget.dart';
import 'package:talk_in/ui/user_flow/chat_screen/shimmer/chat_list_shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';

class HostChatScreen extends StatelessWidget {
  const HostChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.redesignScreenBackground,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(130),
          child: HostChatScreenAppBarView(),
        ),
        body: LayoutBuilder(
          builder: (context, viewportConstraints) {
            final viewportWidth = viewportConstraints.maxWidth;
            final maxContentWidth =
                viewportWidth >= 1400 ? 1280.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: GetBuilder<HostChatScreenController>(
                  id: Constant.idChatList,
                  builder: (controller) {
                    return LayoutBuilder(
                      builder: (context, contentConstraints) {
                        final width = contentConstraints.maxWidth;
                        final horizontalInset = width >= 1100
                            ? 28.0
                            : width >= 760
                                ? 22.0
                                : 16.0;

                        if (controller.isLoading) {
                          return ChatListShimmer(
                            horizontalInset: horizontalInset,
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.redesignBrandRed,
                          backgroundColor: AppColors.white,
                          onRefresh: () async => controller.onRefresh(),
                          child: controller.listenerChatList.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    horizontalInset,
                                    30,
                                    horizontalInset,
                                    24,
                                  ),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(22),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: AppColors.redesignSoftBorder,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 64,
                                            width: 64,
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .redesignScreenBackground,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: AppColors.redesignBrandRed,
                                              size: 34,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            'No chats yet',
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: 18,
                                              fontColor:
                                                  AppColors.redesignBrandDark,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Your conversations with users will appear here.',
                                            textAlign: TextAlign.center,
                                            style: AppFontStyle.fontStyleW500(
                                              fontSize: 13,
                                              fontColor:
                                                  AppColors.redesignMutedText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: controller.listenerChatList.length,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    horizontalInset,
                                    10,
                                    horizontalInset,
                                    20,
                                  ),
                                  itemBuilder: (context, index) {
                                    final chat =
                                        controller.listenerChatList[index];

                                    return HostChatViewItem(
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.hostPersonalChatScreen,
                                          arguments: [
                                            chat.id,
                                            chat.fullName,
                                            chat.isOnline,
                                            chat.profilePic,
                                          ],
                                        )?.then(
                                          (value) async {
                                            ListenerChatListApi
                                                .startPagination = 0;
                                            controller.listenerChatList.clear();
                                            controller.getListenerChatList();
                                          },
                                        );
                                      },
                                      index: index,
                                      name: chat.fullName ?? '',
                                      image: chat.profilePic ?? '',
                                      isOnline: chat.isOnline ?? false,
                                      lastMsg: chat.message ?? '',
                                      unReadCount: chat.unreadCount ?? 0,
                                      lastMsgTime:
                                          chat.lastChatMessageTime.toString(),
                                    );
                                  },
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

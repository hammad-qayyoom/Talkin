// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
// import 'package:talk_in/routes/app_routes.dart';
// import 'package:talk_in/ui/user_flow/chat_screen/controller/chat_screen_controller.dart';
// import 'package:talk_in/ui/user_flow/chat_screen/shimmer/chat_list_shimmer.dart';
// import 'package:talk_in/ui/user_flow/chat_screen/widget/chat_screen_widget.dart';
// import 'package:talk_in/utils/app_asset.dart';
// import 'package:talk_in/utils/app_color.dart';
// import 'package:talk_in/utils/constant.dart';
//
// class ChatScreen extends StatelessWidget {
//   const ChatScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (bool didPop) {
//         Get.dialog(
//           barrierColor: AppColors.black.withValues(alpha: 0.8),
//           Dialog(
//             backgroundColor: AppColors.transparent,
//             shadowColor: AppColors.transparent,
//             surfaceTintColor: AppColors.transparent,
//             elevation: 0,
//             child: const ExitAppDialog(),
//           ),
//         );
//         if (didPop) {
//           return;
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           flexibleSpace: const ChatScreenAppBarView(),
//         ),
//         body: GetBuilder<ChatScreenController>(
//           id: Constant.idChatList,
//           builder: (controller) {
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   controller.isLoading
//                       ? ChatListShimmer()
//                       : controller.chatList.isEmpty
//                           ? Center(
//                               child: Image.asset(AppAsset.noChatFound, height: 300),
//                             )
//                           : ListView.builder(
//                               itemCount: controller.chatList.length,
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return Column(
//                                   children: [
//                                     ChatViewItem(
//                                       onTap: () {
//                                         Get.toNamed(AppRoutes.personalChatScreen, arguments: [
//                                           controller.chatList[index].receiverId,
//                                           controller.chatList[index].name,
//                                           controller.chatList[index].isOnline,
//                                           controller.chatList[index].image,
//                                         ]);
//                                       },
//                                       index: index,
//                                       name: controller.chatList[index].name ?? '',
//                                       lastMsg: controller.chatList[index].message ?? '',
//                                       image: controller.chatList[index].image ?? '',
//                                       unReadCount: controller.chatList[index].unreadCount ?? 0,
//                                       lastMsgTime: controller.chatList[index].lastChatMessageTime.toString(),
//                                     ).paddingOnly(left: 14, right: 14),
//                                     Divider(
//                                       color: AppColors.lightGrey,
//                                       height: 0,
//                                     )
//                                   ],
//                                 );
//                               },
//                             )
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/chat_screen/api/chat_list_api.dart';
import 'package:talk_in/ui/user_flow/chat_screen/controller/chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/chat_screen/shimmer/chat_list_shimmer.dart';
import 'package:talk_in/ui/user_flow/chat_screen/widget/chat_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: AppColors.transparent,
            surfaceTintColor: AppColors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: AppColors.redesignScreenBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: const ChatScreenAppBarView(),
        ),
        body: LayoutBuilder(
          builder: (context, viewportConstraints) {
            final viewportWidth = viewportConstraints.maxWidth;
            final maxContentWidth =
                viewportWidth >= 1400 ? 1280.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: GetBuilder<ChatScreenController>(
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
                              horizontalInset: horizontalInset);
                        }

                        return RefreshIndicator(
                          color: AppColors.redesignBrandRed,
                          backgroundColor: AppColors.white,
                          onRefresh: () async => controller.onRefresh(),
                          child: controller.chatList.isEmpty
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
                                            'Your conversations with experts will appear here.',
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
                                  itemCount: controller.chatList.length,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    horizontalInset,
                                    10,
                                    horizontalInset,
                                    20,
                                  ),
                                  itemBuilder: (context, index) {
                                    return ChatViewItem(
                                      onTap: () {
                                        Utils.showLog(
                                            "receiver id ${controller.chatList[index].receiverId}");
                                        Utils.showLog(
                                            "receiver name ${controller.chatList[index].name}");

                                        Get.toNamed(
                                          AppRoutes.personalChatScreen,
                                          arguments: [
                                            controller
                                                .chatList[index].receiverId,
                                            controller.chatList[index].name,
                                            controller.chatList[index].isOnline,
                                            controller.chatList[index].image,
                                            controller.chatList[index]
                                                .ratePrivateAudioCall,
                                            controller.chatList[index]
                                                .ratePrivateVideoCall,
                                            controller.chatList[index].isFake,
                                            controller.chatList[index].video,
                                            controller.chatList[index]
                                                .isAvailableForPrivateVideoCall,
                                            controller.chatList[index]
                                                .isAvailableForPrivateAudioCall,
                                          ],
                                        )?.then(
                                          (value) async {
                                            ChatListApi.startPagination = 0;
                                            controller.chatList.clear();
                                            controller.getChatList();
                                          },
                                        );
                                      },
                                      index: index,
                                      name:
                                          controller.chatList[index].name ?? '',
                                      lastMsg:
                                          controller.chatList[index].message ??
                                              '',
                                      image: controller.chatList[index].image ??
                                          '',
                                      unReadCount: controller
                                              .chatList[index].unreadCount ??
                                          0,
                                      lastMsgTime: controller
                                          .chatList[index].lastChatMessageTime
                                          .toString(),
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

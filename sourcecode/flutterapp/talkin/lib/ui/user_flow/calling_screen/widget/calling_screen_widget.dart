import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_bar/custom_app_bar.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/calling_screen/controller/calling_screen_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class CallingScreenAppBar extends StatelessWidget {
  const CallingScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtCallingHistory.name.tr,
        showLeadingIcon: false,
      ),
    );
  }
}

class CallingScreenItem extends StatelessWidget {
  final int index;
  final String image;
  final String name;
  final String time;
  final String callStatusText;
  final num coin;
  final bool audioCall;
  final bool videoCall;
  final CallingScreenController controller;
  final VoidCallback? onTalkNowTap;

  const CallingScreenItem(
      {super.key,
      required this.index,
      required this.image,
      required this.name,
      required this.time,
      required this.callStatusText,
      required this.coin,
      required this.controller,
      required this.audioCall,
      required this.videoCall,
      this.onTalkNowTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            height: Get.height * 0.078,
            width: Get.height * 0.078,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomListenerProfileImage(
                image: image.toString(), fit: BoxFit.cover),
          ).paddingAll(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        name,
                        style: AppFontStyle.fontStyleW700(
                            fontSize: 15, fontColor: AppColors.black),
                      ).paddingOnly(right: 8),
                    ),
                    // coin == 0
                    //     ? SizedBox.shrink()
                    //     : Container(
                    //         decoration: BoxDecoration(
                    //           color: AppColors.lightYellow100,
                    //           borderRadius: BorderRadius.circular(30),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Image.asset(
                    //               AppAsset.dimondCoin,
                    //               height: 13,
                    //               width: 13,
                    //             ).paddingOnly(left: 6, top: 3, bottom: 3),
                    //             Text(
                    //               coin.toString(),
                    //               style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.orange),
                    //             ).paddingOnly(left: 4, right: 9)
                    //           ],
                    //         ),
                    //       ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      callStatusText == "Missed Call"
                          ? AppAsset.missedCall
                          : callStatusText == "Incoming Call"
                              ? AppAsset.incomingCall
                              : AppAsset.outgoingCall,
                      height: 19,
                      width: 19,
                    ),
                    Text(
                      callStatusText,
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 12,
                          fontColor: callStatusText == "Missed Call"
                              ? Colors.red
                              : callStatusText == "Incoming Call"
                                  ? AppColors.green
                                  : AppColors.blue),
                    ).paddingOnly(left: 4, right: 4)
                  ],
                ).paddingOnly(bottom: 4, top: 2),
                Text(
                  time.toString(),
                  style: AppFontStyle.fontStyleW500(
                      fontSize: 11, fontColor: AppColors.profileText),
                ),
              ],
            ).paddingOnly(left: 3),
          ),
          GestureDetector(
            onTap: () {
              if (onTalkNowTap != null) {
                onTalkNowTap!();
                return;
              }

              Get.toNamed(
                AppRoutes.userBookSessionScreen,
                arguments: {
                  'listenerId': controller.callingHistory[index].listenerId ??
                      controller.callingHistory[index].id ??
                      '',
                  'listenerName': controller.callingHistory[index].name ?? '',
                  'listenerImage': controller.callingHistory[index].image ?? '',
                  'availableForPrivateAudioCall': controller
                          .callingHistory[index]
                          .isAvailableForPrivateAudioCall ??
                      false,
                  'availableForPrivateVideoCall': controller
                          .callingHistory[index]
                          .isAvailableForPrivateVideoCall ??
                      false,
                  'ratePrivateAudioCall':
                      controller.callingHistory[index].ratePrivateAudioCall ??
                          0,
                  'ratePrivateVideoCall':
                      controller.callingHistory[index].ratePrivateVideoCall ??
                          0,
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffFF1261),
                    Color(0xffFF1C20),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                color: AppColors.appColor,
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppAsset.calendar,
                    color: AppColors.white,
                    height: 18,
                    width: 18,
                  ),
                  Text(
                    EnumLocale.txtBookSession.name.tr,
                    style: AppFontStyle.fontStyleW600(
                        fontSize: 11, fontColor: AppColors.white),
                  ).paddingOnly(left: 6)
                ],
              ),
            ).paddingOnly(right: 6),
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 16);
  }
}

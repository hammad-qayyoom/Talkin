import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class TopListenerWidget extends StatelessWidget {
  const TopListenerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeScreenController homeController =
        Get.find<HomeScreenController>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 1,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                EnumLocale.txtTopListener.name.tr,
                style: AppFontStyle.fontStyleW600(
                    fontSize: 18, fontColor: AppColors.appDarkColor),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.topListenersViewAll,
                    arguments: {
                      'categoryId': homeController.selectedCategoryId,
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4).copyWith(left: 5),
                  color: AppColors.transparent,
                  child: Text(
                    EnumLocale.txtViewAll.name.tr,
                    style: AppFontStyle.fontStyleW500(
                        decorationColor: AppColors.appTextColor,
                        textDecoration: TextDecoration.underline,
                        fontSize: 13,
                        fontColor: AppColors.appTextColor),
                  ),
                ),
              ),
            ],
          ).paddingOnly(top: 16, bottom: 16),
          GetBuilder<HomeScreenController>(
            id: Constant.idGetListener,
            builder: (controller) {
              return controller.isLoading
                  ? TopListenerShimmer()
                  : controller.topListenersModel?.data?.isEmpty == true
                      ? Image.asset(AppAsset.noListenerFound).paddingAll(50)
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.topListeners.take(4).length,
                          itemBuilder: (context, index) {
                            return CustomListeners(
                                fake: controller.topListeners[index].isFake ??
                                    false,
                                availableForPrivateAudioCall: controller
                                        .topListeners[index]
                                        .isAvailableForPrivateAudioCall ??
                                    false,
                                availableForPrivateVideoCall: controller
                                        .topListeners[index]
                                        .isAvailableForPrivateVideoCall ??
                                    false,
                                uniqueId: controller.topListeners[index].uniqueId ??
                                    '',
                                statusTxtColor:
                                    controller.topListeners[index].statusLabel ==
                                            "Offline"
                                        ? AppColors.appTextColor
                                        : AppColors.white,
                                statusColor: controller
                                            .topListeners[index].statusLabel ==
                                        "Available"
                                    ? AppColors.green
                                    : controller.topListeners[index].statusLabel ==
                                            "On Call"
                                        ? AppColors.red
                                        : AppColors.lightGrey1,
                                statusImage: controller.topListeners[index].statusLabel == "Available"
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white
                                              .withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          height: 7,
                                          width: 7,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ).paddingAll(1.8),
                                      ).paddingOnly(right: 4)
                                    : controller.topListeners[index].statusLabel == "On Call"
                                        ? Image.asset(
                                            AppAsset.onCallIcon,
                                            height: 10,
                                            width: 10,
                                          ).paddingOnly(right: 3)
                                        : Container(
                                            // height: 12,
                                            // width: 12,
                                            decoration: BoxDecoration(
                                              color: AppColors.onBoardingTxt
                                                  .withValues(alpha: 0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              height: 7,
                                              width: 7,
                                              decoration: BoxDecoration(
                                                color: AppColors.onBoardingTxt,
                                                shape: BoxShape.circle,
                                              ),
                                            ).paddingAll(1.8),
                                          ).paddingOnly(right: 4),
                                image: controller.topListeners[index].image ?? '',
                                status: controller.topListeners[index].statusLabel ?? '',
                                language: controller.topListeners[index].language?[0].toString() ?? '',
                                callCount: controller.topListeners[index].callCount ?? 0,
                                talkTopicName: controller.topListeners[index].talkTopics ?? [],
                                talkTopicLength: controller.topListeners[index].talkTopics?.length ?? 0,
                                index: index,
                                name: controller.topListeners[index].name ?? '',
                                age: controller.topListeners[index].age == null ? "" : ",${controller.topListeners[index].age.toString()}",
                                viewProfileOnTap: () {
                                  Utils.showLog(
                                      "Call Matching ==>> ${controller.topListeners[index].id}");
                                  Get.delete<ProfileDetailScreenController>();
                                  Get.toNamed(
                                    AppRoutes.profileDetailScreenView,
                                    arguments:
                                        controller.topListeners[index].id,
                                  );
                                },
                                talkNowOnTap: () {
                                  Get.toNamed(
                                    AppRoutes.userBookSessionScreen,
                                    arguments: {
                                      'listenerId':
                                          controller.topListeners[index].id ??
                                              '',
                                      'listenerName':
                                          controller.topListeners[index].name ??
                                              '',
                                      'listenerImage': controller
                                              .topListeners[index].image ??
                                          '',
                                      'availableForPrivateAudioCall': controller
                                              .topListeners[index]
                                              .isAvailableForPrivateAudioCall ??
                                          false,
                                      'availableForPrivateVideoCall': controller
                                              .topListeners[index]
                                              .isAvailableForPrivateVideoCall ??
                                          false,
                                      'ratePrivateAudioCall': controller
                                              .topListeners[index]
                                              .ratePrivateAudioCall ??
                                          0,
                                      'ratePrivateVideoCall': controller
                                              .topListeners[index]
                                              .ratePrivateVideoCall ??
                                          0,
                                    },
                                  );
                                }).paddingOnly(bottom: 12);
                          },
                        );
            },
          ),
        ],
      ),
    );
  }
}

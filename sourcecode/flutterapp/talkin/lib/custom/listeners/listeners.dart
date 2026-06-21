import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class CustomListeners extends StatelessWidget {
  final String name;
  final String? age;
  final num callCount;
  final String uniqueId;
  final String language;
  final List<String> talkTopicName;
  final String image;
  final String? status;
  final Widget? statusImage;
  final Color? statusColor;
  final Color statusTxtColor;
  final int index;
  final int talkTopicLength;
  final VoidCallback? talkNowOnTap;
  final VoidCallback? viewProfileOnTap;
  final bool availableForPrivateAudioCall;
  final bool availableForPrivateVideoCall;
  final bool fake;
  final bool isVerifiedBadge;

  const CustomListeners({
    super.key,
    required this.name,
    this.age,
    required this.index,
    this.talkNowOnTap,
    this.viewProfileOnTap,
    required this.status,
    required this.talkTopicLength,
    required this.talkTopicName,
    required this.callCount,
    required this.language,
    required this.image,
    required this.statusImage,
    required this.statusColor,
    required this.statusTxtColor,
    required this.uniqueId,
    required this.availableForPrivateAudioCall,
    required this.availableForPrivateVideoCall,
    required this.fake,
    this.isVerifiedBadge = false,
  });

  Widget _fittedLabel({
    required String text,
    required TextStyle style,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: viewProfileOnTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  height: Get.height * 0.11,
                  width: Get.height * 0.11,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: CustomListenerProfileImage(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ).paddingOnly(right: 10, left: 8, top: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "@name @age".trParams({'name': name, 'age': age ?? ''}),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: AppFontStyle.fontStyleW600(
                                        fontSize: 14,
                                        fontColor: AppColors.appDarkColor),
                                  ),
                                ),
                                VerifiedBadge(
                                  isVerified: isVerifiedBadge,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(width: 4),

                          // Spacer(),
                          Container(
                            padding: EdgeInsets.only(
                                right: 8, bottom: 3, top: 3, left: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: statusColor,
                            ),
                            child: Row(
                              children: [
                                if (statusImage != null)
                                  Container(
                                    child: statusImage,
                                  ).paddingOnly(right: 3),
                                Text(
                                  status ?? '',
                                  style: AppFontStyle.fontStyleW500(
                                      fontSize: 9, fontColor: statusTxtColor),
                                ),
                              ],
                            ),
                          ).paddingOnly(right: 6),
                        ],
                      ).paddingOnly(top: 8, bottom: 5),
                      Row(
                        children: [
                          Image.asset(
                            AppAsset.speakingBoy,
                            height: 15,
                          ).paddingOnly(right: 2),
                          Flexible(
                            child: Text(
                              language,
                              overflow: TextOverflow
                                  .ellipsis, // prevent long text from breaking layout
                              style: AppFontStyle.fontStyleW500(
                                  fontSize: 11,
                                  fontColor: AppColors.appTextColor),
                            ).paddingOnly(right: 12),
                          ),
                          Image.asset(
                            AppAsset.callIcon,
                            height: 15,
                          ).paddingOnly(right: 2),
                          Text(
                            callCount.toString(),
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 11,
                                fontColor: AppColors.appTextColor),
                          ).paddingOnly(right: 16),
                          Image.asset(
                            AppAsset.uniqueIdIcon,
                            height: 15,
                          ).paddingOnly(right: 2),
                          Text(
                            uniqueId.toString(),
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 11,
                                fontColor: AppColors.appTextColor),
                          ).paddingOnly(right: 16),
                        ],
                      ).paddingOnly(bottom: 2),
                      Divider(
                        color: AppColors.lightGrey,
                      ).paddingOnly(right: 10, bottom: 4),
                      SizedBox(
                        height: Get.height * 0.026,
                        child: ListView.builder(
                          itemCount: talkTopicLength,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  talkTopicName[index],
                                  style: AppFontStyle.fontStyleW500(
                                    fontSize: 10,
                                    fontColor: AppColors.grey,
                                  ),
                                ),
                              ),
                            ).paddingOnly(right: 5);
                          },
                        ).paddingOnly(right: 6),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: PrimaryAppButton(
                  onTap: viewProfileOnTap,
                  height: 38,
                  color: AppColors.white,
                  borderColor: AppColors.appColor,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _fittedLabel(
                        text: EnumLocale.txtViewProfile.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: AppColors.appColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: PrimaryAppButton(
                  onTap: talkNowOnTap,
                  height: 38,
                  color: AppColors.appColor,
                  borderColor: AppColors.appColor,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AppAsset.calendar,
                              color: AppColors.white,
                              height: 19,
                              width: 19,
                            ).paddingOnly(right: 8),
                            Text(
                              EnumLocale.txtBookSession.name.tr,
                              maxLines: 1,
                              softWrap: false,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 14,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).paddingOnly(top: 13, left: 6, right: 6, bottom: 10)
        ],
      ),
    );
  }
}

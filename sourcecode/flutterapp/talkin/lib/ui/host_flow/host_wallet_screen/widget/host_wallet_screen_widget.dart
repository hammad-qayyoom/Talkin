import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_wallet_screen/controller/host_wallet_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostWalletScreenTopView extends StatelessWidget {
  const HostWalletScreenTopView({super.key});

  @override
  Widget build(BuildContext context) {
    final double coinArtSize = (Get.width * 0.32).clamp(120.0, 160.0);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(AppAsset.walletBg), fit: BoxFit.cover),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: SizedBox.shrink()),
              Text(
                EnumLocale.txtMyWallet.name.tr,
                style: AppFontStyle.fontStyleW600(
                    fontSize: 20, fontColor: AppColors.white),
              ).paddingOnly(top: 18, bottom: 20),
              Expanded(child: SizedBox.shrink()),
            ],
          ).paddingOnly(bottom: 10),
          Container(
            padding: EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: coinArtSize,
                  width: coinArtSize,
                  child: Image.asset(
                    AppAsset.walletCross,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EnumLocale.txtCurrentCoinBalance.name.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: AppColors.yellowDark800,
                          decorationColor: AppColors.yellowDark800,
                          textDecoration: TextDecoration.underline,
                        ),
                      ).paddingOnly(bottom: 6, top: 15),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            Database.listenerCoin,
                            maxLines: 1,
                            style: AppFontStyle.fontStyleW900(
                                fontSize: 44,
                                fontColor: AppColors.yellowDark800),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.hostViewCoinHistory);
                        },
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: Get.width * 0.45),
                          padding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  EnumLocale.txtViewCoinHistory.name.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW600(
                                      fontSize: 12,
                                      fontColor: AppColors.yellowDark800),
                                ).paddingOnly(left: 6, right: 6),
                              ),
                              RotatedBox(
                                quarterTurns: 2,
                                child: Image.asset(
                                  AppAsset.backArrowIcon,
                                  height: 10,
                                  width: 10,
                                  color: AppColors.yellowDark800,
                                ),
                              ).paddingOnly(right: 4),
                            ],
                          ),
                        ).paddingOnly(right: 14),
                      ).paddingOnly(bottom: 20, top: 4),
                    ],
                  ),
                ),
              ],
            ),
          ).paddingOnly(bottom: 21, left: 20, right: 20),
        ],
      ).paddingOnly(top: Get.height * 0.042),
    );
  }
}

class HostWalletGuideView extends StatelessWidget {
  const HostWalletGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtWalletGuide.name.tr,
          style: AppFontStyle.fontStyleW800(
              fontSize: 17, fontColor: AppColors.black),
        ).paddingOnly(top: 22),
        Text(
          EnumLocale.txtUserGuide.name.tr,
          style: AppFontStyle.fontStyleW500(
              fontSize: 11, fontColor: AppColors.profileText, height: 1.7),
        ).paddingOnly(top: 8, bottom: 24),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}

class WithdrawCoinView extends StatelessWidget {
  const WithdrawCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${EnumLocale.txtWithdrawCoin.name.tr} :-",
          style: AppFontStyle.fontStyleW800(
              fontSize: 17, fontColor: AppColors.black),
        ).paddingOnly(bottom: 8, top: 22),
        Text(
          EnumLocale.txtListenerWithdrawDescription.name.tr,
          style: AppFontStyle.fontStyleW500(
              fontSize: 11, fontColor: AppColors.profileText, height: 1.7),
        ),
        PrimaryAppButton(
          onTap: () {
            Get.toNamed(AppRoutes.hostWithdrawCoinScreen);
          },
          height: 47,
          width: Get.width,
          color: AppColors.orangeButton,
          text: EnumLocale.txtWithdrawCoin.name.tr,
          textStyle: AppFontStyle.fontStyleW600(
            fontSize: 16,
            fontColor: AppColors.yellowDark800,
          ),
        ).paddingOnly(top: 16, bottom: 18),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}

class BottomView extends StatelessWidget {
  final HostWalletScreenController controller;

  const BottomView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 16),
      width: Get.width,
      decoration:
          BoxDecoration(color: AppColors.optionColor.withValues(alpha: 0.5)),
      child: Row(
        children: List.generate(
          4,
          (index) {
            return Expanded(
              child: Column(
                children: [
                  Image.asset(
                    controller.item[index]['image'],
                    color: AppColors.lightBlue,
                    height: 40,
                    width: 40,
                  ).paddingOnly(bottom: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      textAlign: TextAlign.center,
                      controller.item[index]['name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 11, fontColor: AppColors.lightBlue),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).paddingOnly(bottom: 20);
  }
}

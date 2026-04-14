import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/shimmer/coin_plan_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

import '../model/fetch_coin_plan.dart';

class CoinPlanWidget extends GetView<MyWalletController> {
  const CoinPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a Subscription Plan',
          style: AppFontStyle.fontStyleW700(
            fontSize: 18,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Select a plan and continue to secure checkout',
          style: AppFontStyle.fontStyleW500(
            fontSize: 11,
            fontColor: AppColors.redesignMutedText,
          ),
        ),
        const SizedBox(height: 10),
        GetBuilder<MyWalletController>(
          id: Constant.idGetCoinPlan,
          builder: (controller) {
            return controller.isLoading
                ? const CoinPlanShimmer()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: controller.coinPlan.length,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return Material(
                        color: AppColors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.selectedPaymentMethod = -1;
                            controller.update([Constant.onChangePaymentMethod]);
                            controller.selectedCoinPlan =
                                controller.coinPlan[index];
                            controller.update([Constant.idGetCoinPlan]);
                            Utils.showLog(
                              '.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,${controller.selectedCoinPlan?.productId.toString() ?? ' '}',
                            );

                            Get.bottomSheet(
                              PaymentOptionBottomSheet(index: index),
                              isScrollControlled: true,
                              backgroundColor: AppColors.transparent,
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: CoinPlanTile(
                            coinPlan: controller.coinPlan[index],
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ],
    );
  }
}

class PaymentOptionTile extends StatelessWidget {
  final int index;
  final double? width;
  final double? height;
  final String title;
  final String image;
  final MyWalletController controller;

  const PaymentOptionTile({
    super.key,
    required this.index,
    required this.title,
    required this.image,
    required this.controller,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.selectedPaymentMethod == index;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => controller.onChangePaymentMethod(index),
        child: Container(
          height: 58,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.redesignAccentSoftBg
                : AppColors.redesignSurfaceNeutralAlt,
            border: Border.all(
              color: isSelected
                  ? AppColors.redesignBrandRed
                  : AppColors.redesignSoftBorder,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Image.asset(
                image,
                width: width ?? 50,
                height: height ?? 50,
                fit: BoxFit.contain,
              ),
              Text(
                title,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ).paddingOnly(left: 16),
              const Spacer(),
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.transparent
                        : AppColors.redesignMutedText,
                  ),
                  color:
                      isSelected ? AppColors.redesignBrandRed : AppColors.white,
                ),
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.all(0.5),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.redesignBrandRed,
                            border: Border.all(color: AppColors.white),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoinPlanTile extends StatelessWidget {
  const CoinPlanTile({super.key, required this.coinPlan});

  final CoinPlan coinPlan;

  @override
  Widget build(BuildContext context) {
    final credits = coinPlan.sessionCredits ?? coinPlan.coins ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.redesignSoftBorder),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Image.asset(
                    AppAsset.starCoin,
                    height: 38,
                    width: 38,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (coinPlan.name?.trim().isNotEmpty == true)
                          ? coinPlan.name!.trim()
                          : 'Subscription Plan',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$credits session credits',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 11,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${Database.settingApiModel?.data?.currency?.symbol} ${coinPlan.price}',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 18,
                      fontColor: AppColors.redesignBrandRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.redesignMutedText,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (coinPlan.isPopular == true)
          Positioned(
            top: -7,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.redesignBrandRed,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                EnumLocale.txtMostPopularPlan.name.tr,
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
}

class PaymentOptionBottomSheet extends StatelessWidget {
  final int index;
  const PaymentOptionBottomSheet({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: GetBuilder<MyWalletController>(
        id: Constant.onChangePaymentMethod,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.redesignSoftBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                EnumLocale.txtPaymentMethod.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 10),
              if ((Platform.isAndroid &&
                      Database.settingApiModel?.data?.isRazorpayEnabled ==
                          true) ||
                  (Platform.isIOS &&
                      Database.settingApiModel?.data?.isRazorpayIosEnabled ==
                          true))
                PaymentOptionTile(
                  index: 0,
                  title: 'Razorpay',
                  controller: controller,
                  image: AppAsset.razorpay,
                ),
              if ((Platform.isAndroid &&
                      Database.settingApiModel?.data?.isStripeEnabled ==
                          true) ||
                  (Platform.isIOS &&
                      Database.settingApiModel?.data?.isStripeIosEnabled ==
                          true))
                PaymentOptionTile(
                  index: 1,
                  title: 'Stripe',
                  controller: controller,
                  image: AppAsset.stripe,
                ),
              if ((Platform.isAndroid &&
                      Database.settingApiModel?.data?.isFlutterwaveEnabled ==
                          true) ||
                  (Platform.isIOS &&
                      Database.settingApiModel?.data?.isFlutterwaveIosEnabled ==
                          true))
                PaymentOptionTile(
                  index: 2,
                  title: 'Flutterwave',
                  controller: controller,
                  image: AppAsset.flutterWave,
                ),
              if ((Platform.isAndroid &&
                      Database.settingApiModel?.data?.isGooglePlayEnabled ==
                          true) ||
                  (Platform.isIOS &&
                      Database.settingApiModel?.data?.isGooglePlayIosEnabled ==
                          true))
                PaymentOptionTile(
                  index: 3,
                  title: 'In App Purchase',
                  controller: controller,
                  image: Platform.isIOS
                      ? AppAsset.appStoreImage
                      : AppAsset.googleIcon,
                  width: 50,
                  height: 26,
                ),
              if ((Platform.isAndroid &&
                      Database.settingApiModel?.data
                              ?.isCashfreeAndroidEnabled ==
                          true) ||
                  (Platform.isIOS &&
                      Database.settingApiModel?.data?.isCashfreeIosEnabled ==
                          true))
                PaymentOptionTile(
                  index: 4,
                  title: 'Cash Free',
                  controller: controller,
                  image: AppAsset.cashFreeImage,
                  width: 50,
                  height: 26,
                ),
              if ((Platform.isAndroid &&
                      Database.settingApiModel?.data
                              ?.isPaystackAndroidEnabled ==
                          true) ||
                  (Platform.isIOS &&
                      Database.settingApiModel?.data?.isPaystackIosEnabled ==
                          true))
                PaymentOptionTile(
                  index: 5,
                  title: 'Pay Stack',
                  controller: controller,
                  image: AppAsset.payStackImage,
                  width: 50,
                  height: 26,
                ),
              if ((Platform.isAndroid &&
                      Database.settingApiModel?.data?.isPaypalAndroidEnabled ==
                          true) ||
                  (Platform.isIOS &&
                      Database.settingApiModel?.data?.isPaypalIosEnabled ==
                          true))
                PaymentOptionTile(
                  index: 6,
                  title: 'Pay Pal',
                  controller: controller,
                  image: AppAsset.payPalImage,
                  width: 50,
                  height: 26,
                ),
              const SizedBox(height: 12),
              PrimaryAppButton(
                onTap: () {
                  log('message ${controller.coinPlan[index].id}');
                  log('message ${controller.selectedCoinPlan?.productId}');
                  controller.onClickPayNow(
                    id: controller.coinPlan[index].id ?? '',
                    amount: controller.coinPlan[index].price ?? 0,
                    productKey: controller.selectedCoinPlan?.productId ?? '',
                  );
                },
                height: 52,
                borderRadius: 16,
                color: AppColors.redesignBrandRed,
                text: EnumLocale.txtPay.name.tr,
                textStyle: AppFontStyle.fontStyleW600(
                  fontSize: 17,
                  fontColor: AppColors.white,
                ),
              ).paddingOnly(bottom: 10),
            ],
          );
        },
      ),
    );
  }
}

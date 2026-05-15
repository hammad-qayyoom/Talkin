import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/shimmer/coin_plan_shimmer.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

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
    final isDisabled =
        controller.isPaymentProcessing || controller.isRestoreProcessing;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap:
            isDisabled ? null : () => controller.onChangePaymentMethod(index),
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

  String _currencySymbol() {
    final settingsSymbol =
        Database.settingApiModel?.data?.currency?.symbol?.trim();
    if (settingsSymbol != null &&
        settingsSymbol.isNotEmpty &&
        settingsSymbol.toLowerCase() != 'null') {
      return settingsSymbol;
    }

    switch ((coinPlan.currency ?? '').trim().toUpperCase()) {
      case 'USD':
        return r'$';
      case 'INR':
        return 'INR';
      case 'GBP':
        return 'GBP';
      case 'EUR':
        return 'EUR';
      case 'PKR':
        return 'PKR';
      default:
        return '';
    }
  }

  String _priceText() {
    final value = coinPlan.price ?? 0;
    final formattedPrice =
        value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    final symbol = _currencySymbol();
    return symbol.isEmpty ? formattedPrice : '$symbol $formattedPrice';
  }

  @override
  Widget build(BuildContext context) {
    final credits = coinPlan.sessionCredits ?? coinPlan.coins ?? 0;
    final controller = Get.find<MyWalletController>();
    final isActive = controller.isPlanActive(coinPlan);

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
                    if (isActive) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redesignAccentSoftBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Active',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 9,
                            fontColor: AppColors.redesignBrandRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _priceText(),
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
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.84),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: GetBuilder<MyWalletController>(
            id: Constant.onChangePaymentMethod,
            builder: (controller) {
              final paymentMethods = controller.availablePaymentMethods;
              final hasActiveSubscription = controller.hasActiveSubscription;
              final isRestoreProcessing = controller.isRestoreProcessing;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Center(
                      child: Container(
                        height: 5,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.redesignSoftBorder,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Text(
                      EnumLocale.txtPaymentMethod.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 20,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasActiveSubscription)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.redesignAccentSoftBg,
                                border: Border.all(
                                  color: AppColors.redesignBrandRed
                                      .withValues(alpha: 0.24),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                controller.activeSubscriptionMessage(),
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 12,
                                  fontColor: AppColors.redesignBrandDark,
                                ),
                              ),
                            ),
                          if (!hasActiveSubscription && paymentMethods.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.redesignSurfaceNeutralAlt,
                                border: Border.all(
                                  color: AppColors.redesignSoftBorder,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'No payment method is enabled',
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 13,
                                  fontColor: AppColors.redesignMutedText,
                                ),
                              ),
                            ),
                          if (!hasActiveSubscription)
                            for (final method in paymentMethods)
                              PaymentOptionTile(
                                index: method.id,
                                title: method.title,
                                controller: controller,
                                image: method.image,
                                width: method.width,
                                height: method.height,
                              ),
                          if (Platform.isIOS) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: AppleCheckoutActionButton(
                                    icon: Icons.restore_rounded,
                                    label: isRestoreProcessing
                                        ? 'Restoring'
                                        : 'Restore',
                                    showTrailingIcon: false,
                                    onTap: controller.isPaymentProcessing ||
                                            isRestoreProcessing
                                        ? null
                                        : controller.restoreAppleSubscriptions,
                                    leading: isRestoreProcessing
                                        ? SizedBox(
                                            height: 14,
                                            width: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.redesignBrandRed,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppleCheckoutActionButton(
                                    icon: Icons.tune_rounded,
                                    label: 'Manage',
                                    onTap: controller.isPaymentProcessing ||
                                            isRestoreProcessing
                                        ? null
                                        : controller
                                            .openAppleManageSubscriptions,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AppleCheckoutActionButton(
                              icon: Icons.description_outlined,
                              label: 'Terms of Use (EULA)',
                              onTap: controller.isPaymentProcessing ||
                                      isRestoreProcessing
                                  ? null
                                  : controller.openAppleEula,
                            ),
                            const SizedBox(height: 8),
                            AppleCheckoutActionButton(
                              icon: Icons.privacy_tip_outlined,
                              label: 'Privacy Policy',
                              onTap: controller.isPaymentProcessing ||
                                      isRestoreProcessing
                                  ? null
                                  : controller.openPrivacyPolicy,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: PrimaryAppButton(
                      onTap: controller.isPaymentProcessing ||
                              controller.isRestoreProcessing ||
                              (!hasActiveSubscription && paymentMethods.isEmpty)
                          ? null
                          : () async {
                              if (hasActiveSubscription) {
                                if (Platform.isIOS ||
                                    (controller.activeSubscription
                                                ?.paymentGateway ??
                                            '')
                                        .toLowerCase()
                                        .contains('app store')) {
                                  await controller
                                      .openAppleManageSubscriptions();
                                } else {
                                  Utils.showToast(Get.context,
                                      controller.activeSubscriptionMessage());
                                }
                                return;
                              }

                              log('message ${controller.coinPlan[index].id}');
                              log('message ${controller.selectedCoinPlan?.productId}');
                              await controller.onClickPayNow(
                                id: controller.coinPlan[index].id ?? '',
                                amount: controller.coinPlan[index].price ?? 0,
                                productKey:
                                    controller.productKeyForSelectedPlan(),
                              );
                            },
                      height: 52,
                      borderRadius: 16,
                      color: AppColors.redesignBrandRed,
                      text: controller.isPaymentProcessing
                          ? null
                          : hasActiveSubscription
                              ? 'Manage Subscription'
                              : EnumLocale.txtPay.name.tr,
                      textStyle: AppFontStyle.fontStyleW600(
                        fontSize: 17,
                        fontColor: AppColors.white,
                      ),
                      child: controller.isPaymentProcessing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AppleCheckoutActionButton extends StatelessWidget {
  const AppleCheckoutActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.leading,
    this.showTrailingIcon = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool showTrailingIcon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Material(
      color: isDisabled
          ? AppColors.redesignSurfaceNeutralAlt.withValues(alpha: 0.62)
          : AppColors.redesignSurfaceNeutralAlt,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDisabled
                  ? AppColors.redesignSoftBorder.withValues(alpha: 0.65)
                  : AppColors.redesignSoftBorder,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading ??
                  Icon(
                    icon,
                    size: 17,
                    color: isDisabled
                        ? AppColors.redesignMutedText.withValues(alpha: 0.52)
                        : AppColors.redesignBrandRed,
                  ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 12,
                    fontColor: isDisabled
                        ? AppColors.redesignMutedText.withValues(alpha: 0.7)
                        : AppColors.redesignBrandDark,
                  ),
                ),
              ),
              if (!isDisabled && showTrailingIcon) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: AppColors.redesignMutedText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

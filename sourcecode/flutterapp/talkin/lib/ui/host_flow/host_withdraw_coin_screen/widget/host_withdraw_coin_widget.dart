import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/controller/host_withdraw_coin_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostWithdrawCoinAppBar extends StatelessWidget {
  const HostWithdrawCoinAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 760;

    return Row(
      children: [
        _HeaderIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: Get.back,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtWithdrawCoin.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: isTablet ? 28 : 22,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Transfer your session credits to cash',
                style: AppFontStyle.fontStyleW500(
                  fontSize: isTablet ? 12 : 11,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: AppColors.redesignAccentSoftBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.payments_outlined,
            size: 18,
            color: AppColors.redesignBrandRed,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class HostWithdrawCoinTopView extends StatelessWidget {
  const HostWithdrawCoinTopView({super.key});

  @override
  Widget build(BuildContext context) {
    final conversionCredit =
        Database.settingApiModel?.data?.minimumCoinsForConversion?.toString() ??
            '0';
    final currencySymbol =
        Database.settingApiModel?.data?.currency?.symbol ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 760;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.redesignBrandRed,
                AppColors.redesignBrandRedDeep,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.redesignBrandRed.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        EnumLocale.txtAvailableCoinBalance.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 11,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ready to Withdraw',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: isTablet ? 27 : 21,
                        fontColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: isTablet ? 56 : 44,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Database.listenerCoin,
                          maxLines: 1,
                          style: AppFontStyle.fontStyleW900(
                            fontSize: isTablet ? 54 : 42,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.redesignBrandDark,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                AppAsset.starCoin,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$conversionCredit Session Credit = $currencySymbol 1.00',
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 12,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: isTablet ? 110 : 88,
                width: isTablet ? 110 : 88,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    AppAsset.starCoinBig,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HostWithdrawCoinView extends StatelessWidget {
  const HostWithdrawCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostWithdrawCoinController>(builder: (controller) {
      final hasSelectedMethod = controller.selectedPaymentMethod != null &&
          controller.selectedPaymentMethod! >= 0 &&
          controller.selectedPaymentMethod! < controller.withdrawMethods.length;
      final selectedMethod = hasSelectedMethod
          ? controller.withdrawMethods[controller.selectedPaymentMethod ?? 0]
          : null;
      final minimumPayout =
          Database.settingApiModel?.data?.minimumCoinsForPayout ?? 0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.redesignSoftBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionChip(title: 'Withdrawal Details'),
            const SizedBox(height: 8),
            Text(
              EnumLocale.txtListenerWithdrawDescription.name.tr,
              style: AppFontStyle.fontStyleW500(
                fontSize: 11,
                fontColor: AppColors.redesignMutedText,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 12),
            _FieldLabel(title: EnumLocale.txtWithdrawAmount.name.tr),
            TextFormField(
              controller: controller.coinController,
              keyboardType: TextInputType.number,
              style: AppFontStyle.fontStyleW600(
                fontSize: 13,
                fontColor: AppColors.redesignBrandDark,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter Session Credit',
                hintStyle: AppFontStyle.fontStyleW500(
                  fontSize: 13,
                  fontColor: AppColors.redesignMutedText,
                ),
                filled: true,
                fillColor: AppColors.redesignSurfaceInput,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.redesignSoftBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.redesignSoftBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.redesignBrandRed),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  '${EnumLocale.txtMinimumWithdrawCoin.name.tr}$minimumPayout',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 11,
                    fontColor: AppColors.redesignBrandRed,
                  ),
                ),
              ),
            ),
            _FieldLabel(title: EnumLocale.txtPaymentMethod.name.tr),
            _PaymentMethodTile(
              title: hasSelectedMethod
                  ? (selectedMethod?.name ?? '')
                  : EnumLocale.txtSelectPaymentGateway.name.tr,
              image: hasSelectedMethod ? selectedMethod?.image : null,
              isPlaceholder: !hasSelectedMethod,
              onTap: controller.onSwitchWithdrawMethod,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: controller.isShowPaymentMethod
                  ? Container(
                      key: const ValueKey('payment-method-list'),
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.redesignSurfaceNeutralAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.redesignSoftBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          for (int index = 0;
                              index < controller.withdrawMethods.length;
                              index++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index ==
                                        controller.withdrawMethods.length - 1
                                    ? 0
                                    : 8,
                              ),
                              child: _PaymentMethodOptionTile(
                                title: controller.withdrawMethods[index].name ??
                                    '',
                                image:
                                    controller.withdrawMethods[index].image ??
                                        '',
                                isSelected:
                                    controller.selectedPaymentMethod == index,
                                onTap: () {
                                  controller.onChangePaymentMethod(index);
                                },
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('payment-method-empty')),
            ),
            if ((selectedMethod?.details?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  children: [
                    for (int i = 0;
                        i < (selectedMethod?.details?.length ?? 0);
                        i++)
                      WithdrawDetailsItemUi(
                        title: selectedMethod?.details?[i] ?? '',
                        controller: controller.withdrawPaymentDetails[i],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            PrimaryAppButton(
              height: 50,
              borderRadius: 14,
              gradientColor: [
                AppColors.redesignBrandDark,
                AppColors.redesignBrandDarkAlt,
              ],
              onTap: () {
                if (Database.demoListener == true) {
                  Utils.showToast(
                    Get.context!,
                    EnumLocale.txtDEmoListenerText.name.tr,
                  );
                } else {
                  controller.onClickWithdraw();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    EnumLocale.txtWithdrawCoin.name.tr,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 15,
                      fontColor: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        title,
        style: AppFontStyle.fontStyleW600(
          fontSize: 10,
          fontColor: AppColors.redesignMutedText,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: AppFontStyle.fontStyleW600(
          fontSize: 12,
          fontColor: AppColors.redesignMutedText,
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.image,
    required this.isPlaceholder,
    required this.onTap,
  });

  final String title;
  final String? image;
  final bool isPlaceholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.redesignSurfaceInput,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Row(
            children: [
              if (!isPlaceholder)
                SizedBox(
                  width: 30,
                  child: Center(
                    child: CustomProfileImage(
                      image: image ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              if (!isPlaceholder) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 14,
                    fontColor: isPlaceholder
                        ? AppColors.redesignMutedText
                        : AppColors.redesignBrandDark,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: AppColors.redesignMutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodOptionTile extends StatelessWidget {
  const _PaymentMethodOptionTile({
    required this.title,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.redesignAccentSoftBg
                : AppColors.redesignSurfaceInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.redesignBrandRed
                  : AppColors.redesignSoftBorder,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Center(
                  child: CustomProfileImage(
                    image: image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 13,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              Container(
                height: 18,
                width: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.redesignBrandRed
                        : AppColors.redesignMutedText,
                  ),
                  color: isSelected
                      ? AppColors.redesignBrandRed
                      : AppColors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.white,
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

class WithdrawDetailsItemUi extends StatelessWidget {
  const WithdrawDetailsItemUi({
    super.key,
    required this.title,
    required this.controller,
  });

  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFontStyle.fontStyleW600(
              fontColor: AppColors.redesignMutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.text,
            controller: controller,
            style: AppFontStyle.fontStyleW600(
              fontColor: AppColors.redesignBrandDark,
              fontSize: 13,
            ),
            cursorColor: AppColors.redesignBrandDark,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.redesignSurfaceInput,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.redesignSoftBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.redesignSoftBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.redesignBrandRed),
              ),
              hintText: "Enter your ${title.toLowerCase()}...",
              hintStyle: AppFontStyle.fontStyleW500(
                fontColor: AppColors.redesignMutedText,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

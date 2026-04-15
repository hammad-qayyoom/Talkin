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

class HostWalletScreenAppBar extends StatelessWidget {
  const HostWalletScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 760;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtMyWallet.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 28 : 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track earnings and withdraw securely',
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
              Icons.account_balance_wallet_outlined,
              size: 18,
              color: AppColors.redesignBrandRed,
            ),
          ),
        ],
      ),
    );
  }
}

class HostWalletScreenTopView extends StatelessWidget {
  const HostWalletScreenTopView({super.key});

  @override
  Widget build(BuildContext context) {
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
                        EnumLocale.txtCurrentCoinBalance.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 11,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Session Credit Balance',
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
                          style: AppFontStyle.fontStyleW900(
                            fontSize: isTablet ? 54 : 42,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.hostViewCoinHistory);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                EnumLocale.txtViewCoinHistory.name.tr,
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: isTablet ? 13 : 12,
                                  fontColor: AppColors.redesignBrandDark,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: AppColors.redesignBrandDark,
                              ),
                            ],
                          ),
                        ),
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
                    AppAsset.walletCross,
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

class WithdrawCoinView extends StatelessWidget {
  const WithdrawCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    final conversionCredit =
        Database.settingApiModel?.data?.minimumCoinsForConversion?.toString() ??
            '0';
    final currencySymbol =
        Database.settingApiModel?.data?.currency?.symbol ?? '';

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceNeutralAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Payout',
              style: AppFontStyle.fontStyleW600(
                fontSize: 10,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            EnumLocale.txtWithdrawCoin.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            EnumLocale.txtListenerWithdrawDescription.name.tr,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.redesignMutedText,
              height: 1.75,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceNeutralAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.redesignSoftBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: AppColors.redesignAccentSoftBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      AppAsset.starCoin,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion Rate',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 10,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$conversionCredit Session Credit = $currencySymbol 1.00',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PrimaryAppButton(
            onTap: () {
              Get.toNamed(AppRoutes.hostWithdrawCoinScreen);
            },
            height: 50,
            borderRadius: 14,
            gradientColor: [
              AppColors.redesignBrandDark,
              AppColors.redesignBrandDarkAlt,
            ],
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
  }
}

class BottomView extends StatelessWidget {
  final HostWalletScreenController controller;

  const BottomView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final crossAxisCount = isWide ? 4 : 2;

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
              Text(
                'Why Experts Trust Talkin',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 17,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fast payouts, secure transactions and a trusted community.',
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.item.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: isWide ? 0.98 : 1.55,
                ),
                itemBuilder: (context, index) {
                  return _TrustTile(
                    image: controller.item[index]['image'],
                    title: controller.item[index]['name'],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({
    required this.image,
    required this.title,
  });

  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.asset(
                image,
                color: AppColors.redesignBrandRed,
                height: 20,
                width: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW600(
              fontSize: 11,
              fontColor: AppColors.redesignTextMeta,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class MyWalletScreenAppBar extends StatelessWidget {
  const MyWalletScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 760;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              Utils.onChangeStatusBar(brightness: Brightness.dark);
              Get.back();
            },
          ),
          const SizedBox(width: 12),
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
                  'Credits, plans and payment history',
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

class MyWalletScreenTopView extends StatelessWidget {
  const MyWalletScreenTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 760;

        return GetBuilder<MyWalletController>(
          id: Constant.idGetCoinPlan,
          builder: (controller) {
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
                            'Wallet Balance',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 11,
                              fontColor: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Current Session Credits',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: isTablet ? 28 : 22,
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
                              Database.userCoin,
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
                              Get.toNamed(AppRoutes.coinHistoryScreen);
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
                                    'View Payment History',
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
      },
    );
  }
}

class WalletGuideView extends StatelessWidget {
  const WalletGuideView({super.key});

  @override
  Widget build(BuildContext context) {
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
              'How It Works',
              style: AppFontStyle.fontStyleW600(
                fontSize: 10,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscription Guide',
            style: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a subscription plan to unlock session credits. Paid sessions are booked only after successful payment, and each booking is recorded in your payment history.',
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.redesignMutedText,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}

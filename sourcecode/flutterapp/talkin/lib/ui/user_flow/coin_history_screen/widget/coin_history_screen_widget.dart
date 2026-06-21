import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/range_picker/custom_range_picker.dart';
import 'package:notisboard/ui/user_flow/coin_history_screen/controller/coin_history_screen_controller.dart';
import 'package:notisboard/ui/user_flow/coin_history_screen/model/coin_history_model.dart';
import 'package:notisboard/ui/user_flow/coin_history_screen/model/purchase_cpin_plan_model.dart';
import 'package:notisboard/ui/user_flow/coin_history_screen/shimmer/coin_history_shimmer.dart';
import 'package:notisboard/ui/user_flow/coin_history_screen/shimmer/payment_history_shimmer.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class CoinHistoryScreenAppBar extends StatelessWidget {
  const CoinHistoryScreenAppBar({super.key});

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
                  EnumLocale.txtHistory.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 28 : 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  EnumLocale.txtPaymentsAndSessionCreditsTimeline.name.tr,
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
              Icons.receipt_long_rounded,
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

class CoinHistoryScreenTabBar extends GetView<CoinHistoryScreenController> {
  const CoinHistoryScreenTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        final isPaymentTab = controller.tabIndex == 0;

        String rangeText = EnumLocale.txtAll.name.tr;
        if (isPaymentTab && controller.selectedPaymentDateRange != null) {
          final range = controller.selectedPaymentDateRange!;
          rangeText =
              '${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}';
        } else if (!isPaymentTab && controller.selectedCoinDateRange != null) {
          final range = controller.selectedCoinDateRange!;
          rangeText =
              '${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}';
        }

        final hasFilter =
            (isPaymentTab && controller.selectedPaymentDateRange != null) ||
                (!isPaymentTab && controller.selectedCoinDateRange != null);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.redesignBrandRed,
                      AppColors.redesignBrandRedDeep,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.redesignBrandRed.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
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
                        EnumLocale.txtSmartLedger.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 11,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      EnumLocale.txtTrackAllPaymentAndCreditActivityInOneCleanTimeline.name.tr,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.white.withValues(alpha: 0.92),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 52,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Row(
                  children: [
                    _HistoryTab(
                      isSelected: isPaymentTab,
                      title: EnumLocale.txtPayment.name.tr,
                      onTap: () => controller.changeTab(0),
                    ),
                    _HistoryTab(
                      isSelected: !isPaymentTab,
                      title: EnumLocale.txtCoin.name.tr,
                      onTap: () => controller.changeTab(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      EnumLocale.txtSelectDate.name.tr,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 16,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                  Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final picked = await CustomRangePicker.onShow(
                          context,
                          isPaymentTab
                              ? controller.selectedPaymentDateRange
                              : controller.selectedCoinDateRange,
                        );
                        if (picked != null) {
                          await controller.applyDateFilter(
                            picked.start,
                            picked.end,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: AppColors.redesignSoftBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: AppColors.redesignMutedText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              rangeText,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 13,
                                fontColor: AppColors.redesignBrandDark,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.redesignMutedText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hasFilter) ...[
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await controller.clearDateFilter();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppColors.redesignSoftBorder),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.redesignMutedText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({
    required this.isSelected,
    required this.title,
    required this.onTap,
  });

  final bool isSelected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.redesignBrandDark
                : AppColors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppFontStyle.fontStyleW700(
              fontSize: 16,
              fontColor:
                  isSelected ? AppColors.white : AppColors.redesignMutedText,
            ),
          ),
        ),
      ),
    );
  }
}

class CoinHistoryScreenTabBarScreen extends StatelessWidget {
  const CoinHistoryScreenTabBarScreen({super.key});

  String _coinTypeLabel(CoinHistory item) {
    final type = item.type ?? 0;
    switch (type) {
      case 2:
        return 'Subscription Purchase';
      case 10:
        return 'Subscription Purchase';
      case 11:
        return _isIncome(item)
            ? 'Session Cancellation Refund'
            : 'Session Booking';
      case 3:
        return 'Private Audio Call';
      case 4:
        return 'Private Video Call';
      case 5:
        return 'Audio Call';
      case 6:
        return 'Video Call';
      case 7:
        return 'Withdrawal by Expert';
      case 8:
        return 'Admin Added Session Credit';
      case 9:
        return 'Admin Deducted Session Credit';
      default:
        return type == 1 ? 'Log In Bonus' : 'Session Credit Activity';
    }
  }

  IconData _coinTypeIcon(CoinHistory item) {
    final type = item.type ?? 0;
    switch (type) {
      case 2:
        return Icons.shopping_bag_outlined;
      case 10:
        return Icons.shopping_bag_outlined;
      case 11:
        return _isIncome(item)
            ? Icons.replay_circle_filled_outlined
            : Icons.event_available_outlined;
      case 3:
        return Icons.call_outlined;
      case 4:
        return Icons.videocam_outlined;
      case 5:
        return Icons.call_rounded;
      case 6:
        return Icons.videocam_rounded;
      case 7:
        return Icons.account_balance_wallet_outlined;
      case 8:
        return Icons.add_circle_outline_rounded;
      case 9:
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  bool _isIncome(CoinHistory item) {
    if (item.isIncome != null) {
      return item.isIncome!;
    }

    final type = item.type ?? 0;
    return type == 1 || type == 2 || type == 8 || type == 10;
  }

  Widget _emptyView({required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAsset.noHistoryFound,
              height: 190,
            ),
            const SizedBox(height: 10),
            Text(
              EnumLocale.txtNoHistoryFound.name.tr,
              style: AppFontStyle.fontStyleW700(
                fontSize: 28,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(Datum item) {
    final currency = Database.settingApiModel?.data?.currency?.symbol ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payments_outlined,
              size: 22,
              color: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.uniqueId?.trim().isNotEmpty == true
                      ? item.uniqueId!.trim()
                      : 'Transaction',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.date ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW500(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceInput,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.paymentGateway ?? '-',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 10,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                EnumLocale.txtPlusUserCoin.name.trParams({
                  'userCoin': '${item.userCoin ?? 0}',
                  'coin': EnumLocale.txtCoin.name.tr,
                }),
                style: AppFontStyle.fontStyleW700(
                  fontSize: 12,
                  fontColor: AppColors.redesignStatusSuccessDark,
                ),
              ),
              Text(
                EnumLocale.txtPriceWithCurrency.name.trParams({
                  'currency': currency,
                  'price': '${item.price ?? 0}',
                }),
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: AppColors.redesignCoinText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _coinCard(CoinHistory item) {
    final type = item.type ?? 0;
    final isIncome = _isIncome(item);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.redesignSurfaceSoft,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: type == 1 || type == 2 || type == 10
                  ? CustomProfileImage(
                      image: Database.loginUserProfilePic,
                    )
                  : CustomProfileImage(
                      image: item.receiverImage ?? '',
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (type == 1 || type == 2 || type == 10)
                      ? Database.loginUserName
                      : (item.receiverName ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 15,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _coinTypeIcon(item),
                      size: 13,
                      color: AppColors.redesignMutedText,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _coinTypeLabel(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    ),
                    if (!(type == 1 ||
                            type == 2 ||
                            type == 10 ||
                            type == 7 ||
                            type == 8 ||
                            type == 9) &&
                        (item.duration ?? '').trim().isNotEmpty)
                      Text(
                        item.duration ?? '',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 11,
                          fontColor: AppColors.redesignCoinText,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.date ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            EnumLocale.txtCoinWithSign.name.trParams({
              'sign': isIncome ? '+' : '-',
              'coin': '${item.userCoin ?? 0}',
            }),
            style: AppFontStyle.fontStyleW700(
              fontSize: 18,
              fontColor: isIncome
                  ? AppColors.redesignStatusSuccessDark
                  : AppColors.redesignBrandRed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        if (controller.tabIndex == 0) {
          if (controller.isPaymentLoading &&
              controller.purchaseCoinList.isEmpty) {
            return const Expanded(child: PaymentHistoryShimmer());
          }

          if (controller.purchaseCoinList.isEmpty) {
            return Expanded(
              child: RefreshIndicator(
                color: AppColors.redesignBrandRed,
                backgroundColor: AppColors.white,
                onRefresh: controller.onPaymentRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 70),
                    _emptyView(
                      subtitle:
                          EnumLocale.txtYourPaymentHistoryWillAppearHereOnceYouPurchaseCredits.name.tr,
                    ),
                  ],
                ),
              ),
            );
          }

          return Expanded(
            child: RefreshIndicator(
              color: AppColors.redesignBrandRed,
              backgroundColor: AppColors.white,
              onRefresh: controller.onPaymentRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                controller: controller.scrollController1,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: controller.purchaseCoinList.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index == controller.purchaseCoinList.length) {
                    return GetBuilder<CoinHistoryScreenController>(
                      id: Constant.idPaginationListener,
                      builder: (controller) {
                        return Visibility(
                          visible: controller.isPaginationLoading,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  final item = controller.purchaseCoinList[index];
                  return _paymentCard(item);
                },
              ),
            ),
          );
        }

        if (controller.isCoinLoading && controller.coinHistoryList.isEmpty) {
          return const Expanded(child: CoinHistoryShimmer());
        }

        if (controller.coinHistoryList.isEmpty) {
          return Expanded(
            child: RefreshIndicator(
              color: AppColors.redesignBrandRed,
              backgroundColor: AppColors.white,
              onRefresh: controller.onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 70),
                  _emptyView(
                    subtitle:
                        EnumLocale.txtYourSessionCreditLedgerWillAppearHereAfterActivity.name.tr,
                  ),
                ],
              ),
            ),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            color: AppColors.redesignBrandRed,
            backgroundColor: AppColors.white,
            onRefresh: controller.onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              controller: controller.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: controller.coinHistoryList.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == controller.coinHistoryList.length) {
                  return GetBuilder<CoinHistoryScreenController>(
                    id: Constant.idPaginationListener,
                    builder: (controller) {
                      return Visibility(
                        visible: controller.isPaginationLoading,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    },
                  );
                }

                final item = controller.coinHistoryList[index];
                return _coinCard(item);
              },
            ),
          ),
        );
      },
    );
  }
}

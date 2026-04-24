import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_bar/custom_app_bar.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/range_picker/custom_range_picker.dart';
import 'package:notisboard/ui/host_flow/host_coin_history_screen/controller/host_coin_history_screen_controller.dart';
import 'package:notisboard/ui/user_flow/coin_history_screen/shimmer/coin_history_shimmer.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class HostCoinHistoryScreenAppBar extends StatelessWidget {
  const HostCoinHistoryScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtHistory.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class HostCoinHistoryScreenTabBar extends StatelessWidget {
  const HostCoinHistoryScreenTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostCoinHistoryScreenController>(
      id: Constant.idTabChange, // Listen for tab switch and content change
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              height: Get.height * 0.06,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.tabIndex == 0
                              ? Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          EnumLocale.txtCoin.name.tr,
                          style: controller.tabIndex == 0
                              ? AppFontStyle.fontStyleW600(
                                  fontSize: 14,
                                  fontColor: AppColors.white,
                                )
                              : AppFontStyle.fontStyleW500(
                                  fontSize: 14,
                                  fontColor: AppColors.profileText,
                                ),
                        ),
                      ).paddingAll(controller.tabIndex == 0 ? 2 : 0),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.tabIndex == 1
                              ? Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          EnumLocale.txtWithdraw.name.tr,
                          style: controller.tabIndex == 1
                              ? AppFontStyle.fontStyleW600(
                                  fontSize: 14,
                                  fontColor: AppColors.white,
                                )
                              : AppFontStyle.fontStyleW500(
                                  fontSize: 14,
                                  fontColor: AppColors.profileText,
                                ),
                        ),
                      ).paddingAll(controller.tabIndex == 1 ? 2 : 0),
                    ),
                  ),
                ],
              ),
            ),
            10.height,
            Row(
              children: [
                Text(EnumLocale.txtSelectDate.name.tr,
                    style: AppFontStyle.fontStyleW500(
                        fontSize: 14, fontColor: AppColors.black)),
                Spacer(),
                GetBuilder<HostCoinHistoryScreenController>(
                  id: Constant.idTabChange,
                  builder: (controller) {
                    String displayText = EnumLocale.txtAll.name.tr;

                    if (controller.tabIndex == 1 &&
                        controller.selectedWithdrawDateRange != null) {
                      final range = controller.selectedWithdrawDateRange!;
                      displayText =
                          "${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}";
                    } else if (controller.tabIndex == 0 &&
                        controller.selectedCoinDateRange != null) {
                      final range = controller.selectedCoinDateRange!;
                      displayText =
                          "${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}";
                    }

                    return GestureDetector(
                      onTap: () async {
                        final picked = await CustomRangePicker.onShow(
                          context,
                          controller.tabIndex == 1
                              ? controller.selectedWithdrawDateRange
                              : controller.selectedCoinDateRange,
                        );
                        if (picked != null) {
                          controller.applyDateFilter(picked.start, picked.end);
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              displayText,
                              style: AppFontStyle.fontStyleW500(
                                  fontSize: 14, fontColor: AppColors.black),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 20, color: AppColors.black),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                12.width,
                Visibility(
                  visible: (controller.tabIndex == 1 &&
                          controller.selectedWithdrawDateRange != null) ||
                      (controller.tabIndex == 0 &&
                          controller.selectedCoinDateRange != null),
                  child: GestureDetector(
                    onTap: () {
                      controller.clearDateFilter();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        AppAsset.filterClearIcon,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                )
              ],
            ).paddingSymmetric(horizontal: 16),
            16.height,
          ],
        );
      },
    );
  }
}

class HostCoinHistoryScreenTabBarScreen extends StatelessWidget {
  const HostCoinHistoryScreenTabBarScreen({super.key});

  String _coinTypeLabel(
    int? type, {
    String? reason,
    String? entityType,
  }) {
    switch (type ?? 0) {
      case 1:
        return "Log In Bonus";
      case 2:
      case 10:
        return "Subscription Purchase";
      case 3:
        return "Private audio call";
      case 4:
        return "Private video call";
      case 5:
        return "Audio call";
      case 6:
        return "Video call";
      case 7:
        return "Withdraw Request";
      case 8:
        return "Admin Added Session Credit";
      case 9:
        return "Admin Deducted Session Credit";
      case 11:
        final entity = (entityType ?? "").trim().toLowerCase();
        if (entity == "group_session_booking") {
          return "Group Session Booking";
        }
        if (entity == "session_booking") {
          return "1-to-1 Session Booking";
        }
        return "Session Booking";
      default:
        final fallback = (reason ?? "").trim();
        return fallback.isNotEmpty ? fallback : "Session Credit Activity";
    }
  }

  String _coinTypeIconAsset(int? type) {
    switch (type ?? 0) {
      case 2:
      case 10:
        return AppAsset.coinPurchaseIcon;
      case 3:
      case 5:
        return AppAsset.callIcon;
      case 4:
      case 6:
        return AppAsset.videoCallIcon;
      case 7:
        return AppAsset.withdrawIcon;
      case 8:
        return AppAsset.addWalletCoin;
      case 9:
        return AppAsset.removeWalletCoin;
      case 11:
        return AppAsset.coinPurchaseIcon;
      default:
        return AppAsset.loginBonusIcon;
    }
  }

  bool _showDuration(int? type, String? duration) {
    final isCallType = type == 3 || type == 4 || type == 5 || type == 6;
    if (!isCallType) return false;
    return (duration ?? "").trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostCoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        return Expanded(
          child: controller.tabIndex == 0
              ? (!controller.isLoading &&
                      controller.hostCoinHistoryList.isEmpty)
                  ? SizedBox(
                      height: 100,
                      child: Image.asset(
                        AppAsset.noHistoryFound,
                      )).paddingAll(90)
                  : receiveCoinList(controller)
              : (!controller.isLoading &&
                      controller.withdrawalRecordList.isEmpty)
                  ? SizedBox(
                      height: 100,
                      child: Image.asset(
                        AppAsset.noHistoryFound,
                      )).paddingAll(90)
                  : withdrawAmount(controller),
        );
      },
    );
  }

  Widget receiveCoinList(HostCoinHistoryScreenController controller) {
    return GetBuilder<HostCoinHistoryScreenController>(
        id: Constant.idTabChange,
        builder: (controller) {
          return controller.isLoading
              ? CoinHistoryShimmer()
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.10),
                        offset: Offset(0, 0),
                        blurRadius: 14,
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
                            EnumLocale.txtDetails.name.tr,
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 12, fontColor: AppColors.profileMail),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            EnumLocale.txtCoin.name.tr,
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 12, fontColor: AppColors.profileMail),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 14, vertical: 14),
                      Divider(color: AppColors.lightGrey, height: 0),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async =>
                              controller.refreshHostCoinHistory(),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: controller.scrollController,
                                  itemCount:
                                      controller.hostCoinHistoryList.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        controller.hostCoinHistoryList[index];
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: ClipOval(
                                                        child:
                                                            CustomProfileImage(
                                                      image:
                                                          item.profilePic ?? '',
                                                    )),
                                                  ).paddingOnly(right: 5),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.type == 1
                                                            ? Database
                                                                .loginUserName
                                                            : (item.fullName ??
                                                                ''),
                                                        style: AppFontStyle
                                                            .fontStyleW700(
                                                          fontSize: 13,
                                                          fontColor:
                                                              AppColors.black,
                                                        ),
                                                      ).paddingOnly(bottom: 3),
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            _coinTypeIconAsset(
                                                                item.type),
                                                            color: AppColors
                                                                .historyCallType,
                                                            height: 12,
                                                            width: 12,
                                                            fit: BoxFit.fill,
                                                          ).paddingOnly(
                                                              right: 4),
                                                          Text(
                                                            _coinTypeLabel(
                                                              item.type,
                                                              reason:
                                                                  item.reason,
                                                              entityType: item
                                                                  .entityType,
                                                            ),
                                                            style: AppFontStyle
                                                                .fontStyleW500(
                                                                    fontSize:
                                                                        11,
                                                                    fontColor:
                                                                        AppColors
                                                                            .historyCallType),
                                                          ).paddingOnly(
                                                              right: 6),
                                                          Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            _showDuration(
                                                                    item.type,
                                                                    item.duration)
                                                                ? "${item.duration}"
                                                                : "",
                                                            style: AppFontStyle
                                                                .fontStyleW600(
                                                              fontSize: 11,
                                                              fontColor: AppColors
                                                                  .darkOrange,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  textAlign: TextAlign.center,
                                                  "+ ${item.listenerCoin}",
                                                  style: AppFontStyle
                                                      .fontStyleW700(
                                                    fontSize: 13,
                                                    fontColor: AppColors.green,
                                                  ),
                                                ).paddingOnly(bottom: 4),
                                                Text(
                                                  item.date.toString(),
                                                  style: AppFontStyle
                                                      .fontStyleW500(
                                                          fontSize: 10,
                                                          fontColor: AppColors
                                                              .profileMail),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ).paddingOnly(
                                            right: 14,
                                            bottom: 14,
                                            top: 14,
                                            left: 10),
                                        Divider(
                                            color: AppColors.historyDivider,
                                            height: 0),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              GetBuilder<HostCoinHistoryScreenController>(
                                id: Constant.idPaginationListener,
                                builder: (controller) => Visibility(
                                  visible: controller.isPaginationLoading,
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).paddingOnly(left: 10, right: 10, top: 8);
        });
  }

  Widget withdrawAmount(HostCoinHistoryScreenController controller) {
    return GetBuilder<HostCoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        final itemCount = controller.withdrawalRecordList.isNotEmpty == true
            ? controller.withdrawalRecordList.length
            : 0;

        if (controller.isExpandedList.length != itemCount) {
          controller.initializeExpansionState(itemCount);
        }

        if (controller.withdrawalRecordModel?.data == null ||
            controller.isExpandedList.length != itemCount) {
          return CoinHistoryShimmer();
        }

        return controller.isLoading
            ? CoinHistoryShimmer()
            : Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.10),
                      offset: Offset(0, 0),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: RefreshIndicator(
                  onRefresh: () async => controller.onRefresh(),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: controller.scrollController1,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            final item = controller.withdrawalRecordList[index];
                            final isItemExpanded =
                                (index < controller.isExpandedList.length)
                                    ? controller.isExpandedList[index]
                                    : false;

                            return Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppColors.historyBorder),
                              ),
                              child: Column(
                                children: [
                                  // Top row: title + amount
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        EnumLocale.txtCoin.name.tr,
                                        style: AppFontStyle.fontStyleW800(
                                          fontSize: 18,
                                          fontColor: AppColors.black,
                                        ),
                                      ),
                                      Text(
                                        "${item.coin ?? ''}",
                                        style: AppFontStyle.fontStyleW800(
                                          fontSize: 18,
                                          fontColor: AppColors.red,
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(bottom: 16),

                                  // Session Credit count
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        EnumLocale.txtAmount.name.tr,
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 12,
                                          fontColor: AppColors.profileText,
                                        ),
                                      ),
                                      Text(
                                        "${Database.settingApiModel?.data?.currency?.symbol}${item.amount ?? ''}",
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: 12,
                                          fontColor: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(bottom: 16),

                                  // Withdrawal ID
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        EnumLocale.txtWithdrawalID.name.tr,
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 12,
                                          fontColor: AppColors.profileText,
                                        ),
                                      ),
                                      Text(
                                        item.uniqueId ?? '',
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: 12,
                                          fontColor: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(bottom: 16),

                                  // Payment method
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        EnumLocale.txtPaymentMethod.name.tr,
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 12,
                                          fontColor: AppColors.profileText,
                                        ),
                                      ),
                                      Text(
                                        item.paymentGateway ?? '',
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: 12,
                                          fontColor: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(bottom: 16),

                                  // Expanded details
                                  if (isItemExpanded) ...[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          EnumLocale.txtPaymentDetails.name.tr,
                                          style: AppFontStyle.fontStyleW600(
                                            fontSize: 12,
                                            fontColor: AppColors.profileText,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: item.paymentDetails?.details
                                                  ?.entries
                                                  .map((entry) {
                                                return Text(
                                                  entry.value.toString(),
                                                  style: AppFontStyle
                                                      .fontStyleW700(
                                                    fontSize: 12,
                                                    fontColor: AppColors.black,
                                                  ),
                                                ).paddingOnly(bottom: 2);
                                              }).toList() ??
                                              [],
                                        )
                                      ],
                                    ).paddingOnly(bottom: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          EnumLocale.txtRequestDate.name.tr,
                                          style: AppFontStyle.fontStyleW600(
                                            fontSize: 12,
                                            fontColor: AppColors.profileText,
                                          ),
                                        ),
                                        Text(
                                          item.requestDate ?? '',
                                          style: AppFontStyle.fontStyleW700(
                                            fontSize: 12,
                                            fontColor: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ).paddingOnly(bottom: 16),
                                    if (item.status != 1)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            EnumLocale
                                                .txtAcceptDeclineDate.name.tr,
                                            style: AppFontStyle.fontStyleW600(
                                              fontSize: 12,
                                              fontColor: AppColors.profileText,
                                            ),
                                          ),
                                          Text(
                                            item.acceptOrDeclineDate ?? '',
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: 12,
                                              fontColor: AppColors.black,
                                            ),
                                          ),
                                        ],
                                      ).paddingOnly(bottom: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${EnumLocale.txtStatus.name.tr} :",
                                          style: AppFontStyle.fontStyleW600(
                                            fontSize: 12,
                                            fontColor: AppColors.profileText,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: item.status == 1
                                                ? AppColors.getCoinText
                                                    .withValues(alpha: 0.2)
                                                : item.status == 2
                                                    ? AppColors.green
                                                        .withValues(alpha: 0.1)
                                                    : AppColors.red
                                                        .withValues(alpha: 0.1),
                                          ),
                                          child: Text(
                                            item.status == 1
                                                ? "Pending"
                                                : item.status == 2
                                                    ? "Success"
                                                    : "Failed",
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: 12,
                                              fontColor: item.status == 1
                                                  ? AppColors.getCoinText
                                                      .withValues(alpha: 0.7)
                                                  : item.status == 2
                                                      ? AppColors.green
                                                      : AppColors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ).paddingOnly(bottom: 16),
                                    if (item.reason?.isNotEmpty == true)
                                      Container(
                                        width: Get.width,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: AppColors.historyViewMore,
                                        ),
                                        child: Text(
                                          item.reason ?? '',
                                          style: AppFontStyle.fontStyleW500(
                                            fontSize: 10,
                                            fontColor:
                                                AppColors.historyReasonTxt,
                                          ),
                                        ),
                                      ).paddingOnly(bottom: 16),
                                  ],

                                  // View More / Less button
                                  PrimaryAppButton(
                                    onTap: () =>
                                        controller.toggleExpanded(index),
                                    height: 47,
                                    borderRadius: 8,
                                    color: AppColors.historyViewMore,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isItemExpanded
                                              ? EnumLocale.txtViewLess.name.tr
                                              : EnumLocale.txtViewMore.name.tr,
                                          style: AppFontStyle.fontStyleW700(
                                            fontSize: 12,
                                            fontColor:
                                                AppColors.historyViewMoreTxt,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                        Icon(
                                          isItemExpanded
                                              ? Icons
                                                  .keyboard_arrow_down_rounded
                                              : Icons.keyboard_arrow_up_rounded,
                                          size: 18,
                                          color: AppColors.historyViewMoreTxt,
                                        ),
                                      ],
                                    ),
                                  ).paddingOnly(top: 5),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      GetBuilder<HostCoinHistoryScreenController>(
                        id: Constant.idPaginationListener,
                        builder: (controller) => Visibility(
                          visible: controller.isPaginationLoading,
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ).paddingOnly(left: 10, right: 10, top: 8);
      },
    );
  }
}

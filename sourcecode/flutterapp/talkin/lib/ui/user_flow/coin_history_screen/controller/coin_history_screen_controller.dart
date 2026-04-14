import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/api/coin_history_api.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/api/purchase_coin_plan_api.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/model/coin_history_model.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/model/purchase_cpin_plan_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class CoinHistoryScreenController extends GetxController {
  int tabIndex = 0;

  GetPurchaseCoinPlanModel? purchaseCoinPlanModel;
  final List<Datum> purchaseCoinList = <Datum>[];

  CoinHistoryModel? coinHistoryModel;
  final List<CoinHistory> coinHistoryList = <CoinHistory>[];

  bool isLoading = false;
  bool isPaginationLoading = false;

  bool hasMorePaymentData = true;
  bool hasMoreCoinData = true;

  final ScrollController scrollController = ScrollController();
  final ScrollController scrollController1 = ScrollController();

  DateTimeRange? selectedCoinDateRange;
  DateTimeRange? selectedPaymentDateRange;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    scrollController.addListener(onCoinHistoryPagination);
    scrollController1.addListener(onPaymentHistoryPagination);

    await Future.wait([
      _fetchPaymentHistory(reset: true),
      _fetchCoinHistory(reset: true),
    ]);
  }

  Future<void> _fetchPaymentHistory({required bool reset}) async {
    if (reset) {
      PurchaseCoinGetPlanApi.startPagination = 0;
      hasMorePaymentData = true;
      isLoading = true;
      update([Constant.idTabChange]);
    } else {
      if (isPaginationLoading || !hasMorePaymentData) {
        return;
      }
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);
    }

    final range = selectedPaymentDateRange;

    try {
      final data = await PurchaseCoinGetPlanApi.callApi(
        startDate: range != null ? Utils.formatDateToApi(range.start) : 'All',
        endDate: range != null ? Utils.formatDateToApi(range.end) : 'All',
      );

      final items = data?.data ?? <Datum>[];

      purchaseCoinPlanModel = data ?? purchaseCoinPlanModel;

      if (reset) {
        purchaseCoinList.clear();
      }

      purchaseCoinList.addAll(items);
      hasMorePaymentData =
          items.length >= PurchaseCoinGetPlanApi.limitPagination;
    } finally {
      if (reset) {
        isLoading = false;
        update([Constant.idTabChange]);
      } else {
        isPaginationLoading = false;
        update([Constant.idPaginationListener, Constant.idTabChange]);
      }
    }
  }

  Future<void> _fetchCoinHistory({required bool reset}) async {
    if (reset) {
      CoinHistoryApi.startPagination = 0;
      hasMoreCoinData = true;
      isLoading = true;
      update([Constant.idTabChange]);
    } else {
      if (isPaginationLoading || !hasMoreCoinData) {
        return;
      }
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);
    }

    final range = selectedCoinDateRange;

    try {
      final data = await CoinHistoryApi.callApi(
        startDate: range != null ? Utils.formatDateToApi(range.start) : 'All',
        endDate: range != null ? Utils.formatDateToApi(range.end) : 'All',
      );

      final items = data?.data ?? <CoinHistory>[];

      coinHistoryModel = data ?? coinHistoryModel;

      if (reset) {
        coinHistoryList.clear();
      }

      coinHistoryList.addAll(items);
      hasMoreCoinData = items.length >= CoinHistoryApi.limitPagination;
    } finally {
      if (reset) {
        isLoading = false;
        update([Constant.idTabChange]);
      } else {
        isPaginationLoading = false;
        update([Constant.idPaginationListener, Constant.idTabChange]);
      }
    }
  }

  void changeTab(int index) {
    tabIndex = index;
    update([Constant.idTabChange]);

    if (index == 0 && purchaseCoinList.isEmpty && !isLoading) {
      onPaymentRefresh();
    }

    if (index == 1 && coinHistoryList.isEmpty && !isLoading) {
      onRefresh();
    }
  }

  Future<void> onRefresh() async {
    await _fetchCoinHistory(reset: true);
  }

  Future<void> onPaymentRefresh() async {
    await _fetchPaymentHistory(reset: true);
  }

  Future<void> onCoinHistoryPagination() async {
    if (!scrollController.hasClients || isLoading) {
      return;
    }

    final maxScroll = scrollController.position.maxScrollExtent;
    final current = scrollController.position.pixels;

    if (current >= maxScroll - 40) {
      await _fetchCoinHistory(reset: false);
    }
  }

  Future<void> onPaymentHistoryPagination() async {
    if (!scrollController1.hasClients || isLoading) {
      return;
    }

    final maxScroll = scrollController1.position.maxScrollExtent;
    final current = scrollController1.position.pixels;

    if (current >= maxScroll - 40) {
      await _fetchPaymentHistory(reset: false);
    }
  }

  Future<void> applyDateFilter(DateTime startDate, DateTime endDate) async {
    if (tabIndex == 0) {
      selectedPaymentDateRange = DateTimeRange(start: startDate, end: endDate);
      await _fetchPaymentHistory(reset: true);
    } else {
      selectedCoinDateRange = DateTimeRange(start: startDate, end: endDate);
      await _fetchCoinHistory(reset: true);
    }
  }

  Future<void> clearDateFilter() async {
    if (tabIndex == 0) {
      selectedPaymentDateRange = null;
      await _fetchPaymentHistory(reset: true);
    } else {
      selectedCoinDateRange = null;
      await _fetchCoinHistory(reset: true);
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(onCoinHistoryPagination);
    scrollController1.removeListener(onPaymentHistoryPagination);
    scrollController.dispose();
    scrollController1.dispose();
    super.onClose();
  }
}

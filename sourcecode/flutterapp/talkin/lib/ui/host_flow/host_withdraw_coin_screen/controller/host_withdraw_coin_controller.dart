import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/api/payment_option_api.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/api/withdraw_coin_submit_api.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/model/payment_option_model.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/model/withdraw_coin_submit_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class HostWithdrawCoinController extends GetxController {
  bool isLoading = false;
  PaymentOptionModel? paymentOptionModel;
  final TextEditingController coinController = TextEditingController();
  bool isShowPaymentMethod = false;
  List<PaymentOption> withdrawMethods = []; // Fill this from your API
  int? selectedPaymentMethod;

  List<TextEditingController> withdrawPaymentDetails = [];
  WithdrawCoinSubmitModel? withdrawCoinSubmitModel;

  num _parseNumeric(Object? value, {num fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? fallback;
  }

  Future<num> _getFreshAvailableBalance() async {
    final cachedWalletBalance =
        _parseNumeric(Database.listenerCoin, fallback: 0);
    final cachedProfileBalance = _parseNumeric(
        Database.fetchListenerProfileModel?.data?.currentCoinBalance,
        fallback: 0);

    num localBalance = cachedWalletBalance > cachedProfileBalance
        ? cachedWalletBalance
        : cachedProfileBalance;

    try {
      final latestBalance = await HostCoinApi.callApi();

      if (latestBalance?.status == true && latestBalance?.coin != null) {
        final normalizedBalance =
            _parseNumeric(latestBalance?.coin, fallback: localBalance);

        Database.onSetListenerCoin(normalizedBalance.toString());
        if (Database.fetchListenerProfileModel?.data != null) {
          Database.fetchListenerProfileModel?.data?.currentCoinBalance =
              normalizedBalance;
        }

        return normalizedBalance;
      }
    } catch (_) {}

    return localBalance;
  }

  @override
  void onInit() {
    onGetWithdrawMethods();
    super.onInit();
  }

  /// get withdraw coin method
  onGetWithdrawMethods() async {
    isLoading = true;
    update([Constant.idPaymentOption]);
    paymentOptionModel =
        await PaymentOptionApi.callApi(endDate: "All", startDate: "All");

    if (paymentOptionModel?.data != null) {
      withdrawMethods.addAll(paymentOptionModel?.data ?? []);
      isLoading = false;
      update([Constant.idPaymentOption]);
    }
    // paymentOptions = paymentOptionModel?.data ?? [];
    //
    // isLoading = false;
    // update([Constant.idPaymentOption]);
  }

  Future<void> onSwitchWithdrawMethod() async {
    isShowPaymentMethod = !isShowPaymentMethod;
    update();
  }

  Future<void> onChangePaymentMethod(int index) async {
    selectedPaymentMethod = index;
    if (isShowPaymentMethod) {
      onSwitchWithdrawMethod();
    }
    withdrawPaymentDetails = List<TextEditingController>.generate(
        withdrawMethods[index].details?.length ?? 0,
        (counter) => TextEditingController());

    update();
  }

  /// validation withdraw coin
  Future<void> onClickWithdraw() async {
    final requestedCoins =
        _parseNumeric(coinController.text.trim(), fallback: 0);
    final minimumCoinsForPayout = _parseNumeric(
        Database.settingApiModel?.data?.minimumCoinsForPayout,
        fallback: 0);
    final availableBalance = await _getFreshAvailableBalance();

    final isWithdrawDetailsEmpty = withdrawPaymentDetails
        .any((controller) => controller.text.trim().isEmpty);

    if (coinController.text.trim().isEmpty) {
      Utils.showToast(
          Get.context!, EnumLocale.txtPleaseEnterWithdrawCoin.name.tr);
    } else if (requestedCoins < minimumCoinsForPayout) {
      Utils.showToast(
          Get.context!,
          EnumLocale
              .txtWithdrawalRequestedCoinMustBeGreaterThanSpecifiedByTheAdmin
              .name
              .tr);
    } else if (requestedCoins > availableBalance) {
      Utils.showToast(
          Get.context!,
          EnumLocale
              .txtTheUserDoesNotHaveSufficientFundsToMakeTheWithdrawal.name.tr);
    } else if (selectedPaymentMethod == null) {
      Utils.showToast(
          Get.context!, EnumLocale.txtPleaseSelectWithdrawMethod.name.tr);
    } else if (isWithdrawDetailsEmpty) {
      Utils.showToast(
          Get.context!, EnumLocale.txtPleaseEnterAllPaymentDetails.name.tr);
    } else {
      onWithdraw();
    }
  }

  /// withdraw coin api
  Future<void> onWithdraw() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Get.dialog(const LoadingWidget(),
        barrierDismissible: false); // Start Loading...
    Map<String, String> details = {};

    for (int i = 0;
        i < withdrawMethods[selectedPaymentMethod ?? 0].details!.length;
        i++) {
      final key = withdrawMethods[selectedPaymentMethod ?? 0].details![i];
      final value = withdrawPaymentDetails[i].text;
      details[key] = value;
    }

    await 1.seconds.delay();

    withdrawCoinSubmitModel = await WithdrawCoinSubmitApi.callApi(
      listenerId: Database.fetchListenerProfileModel?.data?.id ?? '',
      coin: coinController.text,
      paymentGateway: withdrawMethods[selectedPaymentMethod ?? 0].name ?? "",
      // paymentDetails: details,
      paymentDetails: details,
    );

    if (Get.isDialogOpen ?? false) {
      Get.back(); // Stop Loading / Close Dialog
    }

    if (withdrawCoinSubmitModel?.status == true) {
      log("withdrawCoinSubmitModel?.status  :: ${withdrawCoinSubmitModel?.status}");
      Utils.showToast(Get.context!, withdrawCoinSubmitModel?.message ?? "");
      if (Get.context != null) {
        Get.back(); // Close Withdraw Page only on success
      }
    } else {
      Utils.showToast(Get.context!, withdrawCoinSubmitModel?.message ?? "");
    }
  }
}

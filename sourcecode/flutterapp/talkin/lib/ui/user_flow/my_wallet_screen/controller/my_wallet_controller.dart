import 'dart:developer';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/payment/api/purchase_coin_plan_api.dart';
import 'package:notisboard/payment/in_app_purchase/iap_callback.dart';
import 'package:notisboard/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:notisboard/payment/razor_pay/razor_pay_service.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/api/fetch_coin_plan_api.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/model/purchase_coin_plan.dart';
import 'package:notisboard/utils/common_payment.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class MyWalletController extends GetxController implements IAPCallback {
  FetchCoinPlan? fetchCoinPlan;
  List<CoinPlan> coinPlan = [];
  bool isLoading = false;
  bool isPaymentProcessing = false;
  int selectedPaymentMethod = -1;
  PurchaseCoinPlan? purchaseCoinPlan;
  UserCoinModel? userCoinModel;
  // String productKey = '';
  Map<String, PurchaseDetails>? purchases;
  CoinPlan? selectedCoinPlan;

  @override
  void onInit() {
    fetchCoinPlanList();
    super.onInit();
  }

  void _showBlockingLoader() {
    if (Get.isDialogOpen != true) {
      Get.dialog(const LoadingWidget(), barrierDismissible: false);
    }
  }

  void _closeBlockingLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void _closePaymentSelectorIfOpen() {
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  void _setPaymentProcessing(bool value) {
    if (isPaymentProcessing == value) return;
    isPaymentProcessing = value;
    update([Constant.onChangePaymentMethod]);
  }

  Future<void> syncSessionCredits({bool refreshHome = true}) async {
    userCoinModel = await UserCoinApi.callApi();

    if (userCoinModel?.status == true) {
      final normalizedCredits = userCoinModel?.coin ?? 0;
      Database.onSetUserCoin(normalizedCredits.toString());
      fetchCoinPlan?.userCoin = normalizedCredits;

      if (refreshHome && Get.isRegistered<HomeScreenController>()) {
        Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
      }

      update([Constant.idGetCoinPlan]);

      log("Database.userCoin  ${Database.userCoin}");
    }
  }

  /// fetch coin plan
  Future<void> fetchCoinPlanList() async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";

    isLoading = true;
    update([Constant.idGetCoinPlan]);

    fetchCoinPlan = await FetchCoinPlanApi.callApi(
      uid: uid,
      token: token,
    );
    coinPlan.clear();
    coinPlan.addAll(fetchCoinPlan?.data ?? []);
    await syncSessionCredits(refreshHome: false);

    isLoading = false;
    update([Constant.idGetCoinPlan]);
  }

  /// change payment method
  void onChangePaymentMethod(int index) async {
    selectedPaymentMethod = index;
    update([Constant.onChangePaymentMethod]);
  }

  /// payment method condition
  Future<void> onClickPayNow(
      {required String id,
      required num amount,
      required String productKey,
      bool dismissSelector = false}) async {
    if (selectedPaymentMethod == -1) {
      Utils.showToast(Get.context, EnumLocale.txtSelectPaymentMethod.name.tr);
      return;
    }

    if (isPaymentProcessing) {
      return;
    }

    _setPaymentProcessing(true);
    try {
      if (dismissSelector) {
        _closePaymentSelectorIfOpen();
        await 250.milliseconds.delay();
      }

      if (selectedPaymentMethod == 0) {
        await onClickRazorPay(amount, id);
      } else if (selectedPaymentMethod == 1) {
        await onClickStripe(amount, id);
      } else if (selectedPaymentMethod == 2) {
        await onClickFlutterWave(amount, id);
      } else if (selectedPaymentMethod == 3) {
        await onClickInAppPurchase(amount, id, productKey);
      } else if (selectedPaymentMethod == 4) {
        await onClickCashFree(amount, id);
      } else if (selectedPaymentMethod == 5) {
        await onClickPayStack(amount, id);
      } else if (selectedPaymentMethod == 6) {
        await onClickPayPal(amount, id);
      }
    } finally {
      _setPaymentProcessing(false);
    }
  }

  /// flutter wave
  Future<void> onClickFlutterWave(num amount, String id) async {
    Utils.showLog("Flutter Wave Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      await flutterWave(
        // context: Get.context,
        amount: amount,
        onPaymentSuccess: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("Flutter Wave Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "Flutter Wave",
              token: token,
              uid: uid);

          _closeBlockingLoader();

          if (purchaseCoinPlan?.status == true) {
            await fetchCoinPlanList();
            await syncSessionCredits();

            Utils.showToast(Get.context, "Subscription activated successfully");
            _closePaymentSelectorIfOpen();
          } else {
            Utils.showToast(
                Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      _closeBlockingLoader();
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("Flutter Wave Payment Failed => $e");
    }
  }

  /// stripe
  Future<void> onClickStripe(num amount, String id) async {
    Utils.showLog("Stripe Payment Working...");

    if (amount <= 0) {
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
      return;
    }

    try {
      await stripe(
        amount: amount,
        onPaymentSuccess: () async {
          await _handleStripePaymentSuccess(id);
        },
      );
      Utils.showLog("Stripe Payment flow completed.");
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("Stripe Payment Failed !! => $e");
    }
  }

  Future<void> _handleStripePaymentSuccess(String coinPlanId) async {
    try {
      final token = await FirebaseAccessToken.onGet() ?? "";
      final uid = Database.loginUserFirebaseId;

      Utils.showLog("Stripe Payment Success Method Called....");

      _showBlockingLoader();

      purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
        coinPlanId: coinPlanId,
        paymentGateway: "Stripe",
        token: token,
        uid: uid,
      );
      _closeBlockingLoader();

      if (purchaseCoinPlan?.status == true) {
        await fetchCoinPlanList();
        await syncSessionCredits();
        Utils.showToast(Get.context, "Subscription activated successfully");
        _closePaymentSelectorIfOpen();
      } else {
        Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
      }
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("Stripe Success Callback Failed => $e");
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  /// razor pay
  Future<void> onClickRazorPay(num amount, String id) async {
    Utils.showLog("Razorpay Payment Working....");

    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      await razorPay(
        amount: amount,
        // razorKey: Database.settingApiModel?.data?.razorpayKeySecret ?? '',
        // razorKey: "rzp_test_SjZz9HC7RGCfCb",
        onPaymentSuccess: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("RazorPay Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "RazorPay",
              token: token,
              uid: uid);

          _closeBlockingLoader();

          if (purchaseCoinPlan?.status == true) {
            await fetchCoinPlanList();
            await syncSessionCredits();

            Utils.showToast(Get.context, "Subscription activated successfully");
            _closePaymentSelectorIfOpen();
            Get.toNamed(AppRoutes.coinPurchaseScreen, arguments: {
              "date": purchaseCoinPlan?.historyRecord?.date,
              "amount": purchaseCoinPlan?.historyRecord?.amountPaid,
              "paymentMode": purchaseCoinPlan?.historyRecord?.paymentMode,
              "transactionId": purchaseCoinPlan?.historyRecord?.transactionId,
            });
          } else {
            Utils.showToast(
                Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      await 1.seconds.delay();
      RazorPayService().razorPayCheckout((amount * 100).toInt());
      _closeBlockingLoader();
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("RazorPay Payment Failed => $e");
    }
  }

  ///in app purchase
  Future<void> onClickInAppPurchase(
      num amount, String id, String productKey) async {
    final normalizedProductKey = productKey.trim();
    Utils.showLog("Starting IAP with product: $normalizedProductKey");

    if (normalizedProductKey.isEmpty) {
      Utils.showToast(Get.context, "Product not configured");
      return;
    }

    final helper = InAppPurchaseHelper();
    helper.init(
      paymentType: "In App Purchase",
      userId: Database.loginUserFirebaseId,
      productKey: [normalizedProductKey],
      rupee: amount.toDouble(),
      callBack: () {
        Utils.showLog("In App Purchase callback completed");
      },
    );
    helper.setCallback(this);
    helper.ensurePurchaseListener();

    _showBlockingLoader();
    try {
      await helper.debugProductLoading();
      await helper.initStoreInfo();
      purchases = helper.getPurchases();

      final product = helper.getProductDetail(normalizedProductKey);
      _closeBlockingLoader();

      if (product != null) {
        Utils.showLog("Product found: ${product.title} - ${product.price}");
        await helper.buySubscription(product, purchases ?? {});
      } else {
        Utils.showToast(
            Get.context, "Product not found: $normalizedProductKey");
        Utils.showLog("Available products: ${helper.getAvailableProducts()}");
      }
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("In App Purchase Failed => $e");
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  ///cash free
  Future<void> onClickCashFree(num amount, String id) async {
    Utils.showLog("cash free Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      await cashFree(
        // context: Get.context,
        amount: amount,
        onPaymentSuccess: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("cash free Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "cash free",
              token: token,
              uid: uid);

          _closeBlockingLoader();

          if (purchaseCoinPlan?.status == true) {
            await fetchCoinPlanList();
            await syncSessionCredits();

            Utils.showToast(Get.context, "Subscription activated successfully");
            _closePaymentSelectorIfOpen();
          } else {
            Utils.showToast(
                Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      _closeBlockingLoader();
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("cash free Payment Failed => $e");
    }
  }

  ///pay pal
  Future<void> onClickPayPal(num amount, String id) async {
    Utils.showLog("pay pal Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      await payPal(
        // context: Get.context,
        amount: amount,
        onPaymentSuccess: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("pay pal Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "pay pal",
              token: token,
              uid: uid);

          _closeBlockingLoader();

          if (purchaseCoinPlan?.status == true) {
            await fetchCoinPlanList();
            await syncSessionCredits();

            Utils.showToast(Get.context, "Subscription activated successfully");
            _closePaymentSelectorIfOpen();
          } else {
            Utils.showToast(
                Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      _closeBlockingLoader();
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("pay pal Payment Failed => $e");
    }
  }

  ///pay stack
  Future<void> onClickPayStack(num amount, String id) async {
    Utils.showLog("pay stack Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      await payStack(
        // context: Get.context,
        amount: amount,
        onPaymentSuccess: () async {
          final token = await FirebaseAccessToken.onGet() ?? "";
          final uid = Database.loginUserFirebaseId;

          Utils.showLog("pay stack Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "pay stack",
              token: token,
              uid: uid);

          _closeBlockingLoader();

          if (purchaseCoinPlan?.status == true) {
            await fetchCoinPlanList();
            await syncSessionCredits();

            Utils.showToast(Get.context, "Subscription activated successfully");
            _closePaymentSelectorIfOpen();
          } else {
            Utils.showToast(
                Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      _closeBlockingLoader();
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("pay stack Payment Failed => $e");
    }
  }

  onRefresh() async {
    fetchCoinPlanList();
  }

  @override
  void onBillingError(error) {
    Utils.showLog("IAP Billing Error: $error");
    Utils.showToast(Get.context, "Payment failed: $error");
  }

  @override
  void onLoaded(bool initialized) {
    Utils.showLog("IAP Loaded: $initialized");
  }

  @override
  void onPending(PurchaseDetails product) {
    Utils.showLog("IAP Pending: ${product.productID}");
    Utils.showToast(Get.context, "Payment is pending...");
  }

  @override
  void onSuccessPurchase(PurchaseDetails product) async {
    Utils.showLog("IAP Success: ${product.productID}");

    try {
      // Show loading dialog
      Get.dialog(const LoadingWidget(), barrierDismissible: false);
      final token = await FirebaseAccessToken.onGet() ?? "";
      final uid = Database.loginUserFirebaseId;

      // Call the API to record the purchase
      // final isSuccess =
      //     await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "In App Purchase");

      final isSuccess = await PurchaseCoinPlanApi.callApi(
          coinPlanId: selectedCoinPlan?.id.toString() ?? '',
          paymentGateway: "In App Purchase",
          token: token,
          uid: uid);

      // Hide loading dialog
      Get.back();

      if (isSuccess?.status == true) {
        await fetchCoinPlanList();
        await syncSessionCredits();
        Utils.showToast(Get.context, "Subscription activated successfully");
        _closePaymentSelectorIfOpen();
      } else {
        Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
      }
    } catch (e) {
      // Hide loading dialog if there's an error
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Utils.showLog("API call failed: $e");
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }
}

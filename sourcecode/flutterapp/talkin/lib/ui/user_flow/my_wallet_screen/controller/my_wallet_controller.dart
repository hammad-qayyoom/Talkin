import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/payment/api/purchase_coin_plan_api.dart';
import 'package:notisboard/payment/in_app_purchase/iap_callback.dart';
import 'package:notisboard/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/app_review/app_review_service.dart';
import 'package:notisboard/ui/user_flow/all_listeners_screen/controller/all_listeners_controller.dart';
import 'package:notisboard/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:notisboard/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:notisboard/ui/user_flow/main_screen/api/get_firebase_custom_token_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:notisboard/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/api/fetch_coin_plan_api.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:notisboard/ui/user_flow/my_wallet_screen/model/purchase_coin_plan.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/ui/user_flow/top_listeners_view_all/controller/top_listeners_view_all_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/common_payment.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/guest_browsing_setup.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentMethodOption {
  PaymentMethodOption({
    required this.id,
    required this.title,
    required this.image,
    this.width,
    this.height,
  });

  final int id;
  final String title;
  final String image;
  final double? width;
  final double? height;
}

class MyWalletController extends GetxController
    with WidgetsBindingObserver
    implements IAPCallback {
  static const int paymentRazorpay = 0;
  static const int paymentStripe = 1;
  static const int paymentFlutterWave = 2;
  static const int paymentInAppPurchase = 3;
  static const int paymentCashFree = 4;
  static const int paymentPayStack = 5;
  static const int paymentPayPal = 6;

  FetchCoinPlan? fetchCoinPlan;
  List<CoinPlan> coinPlan = [];
  bool isLoading = false;
  bool isPaymentProcessing = false;
  bool isRestoreProcessing = false;
  int selectedPaymentMethod = -1;
  PurchaseCoinPlan? purchaseCoinPlan;
  UserCoinModel? userCoinModel;
  // String productKey = '';
  Map<String, PurchaseDetails>? purchases;
  CoinPlan? selectedCoinPlan;
  bool _isRestoringAppleSubscriptions = false;
  bool _didReceiveRestoredPurchase = false;
  bool _didReceiveAppleStoreError = false;
  bool _awaitingApplePurchaseResult = false;
  bool _refreshAfterExternalManage = false;
  bool _walletStateChanged = false;
  Timer? _pendingAppleStoreErrorTimer;
  Timer? _applePurchaseTimeoutTimer;
  final Set<String> _activeAppleVerificationKeys = <String>{};

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    fetchCoinPlanList();
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelPendingAppleStoreError();
    _cancelApplePurchaseTimeout();
    if (_walletStateChanged) {
      unawaited(_notifyAuthenticatedWalletStateChanged());
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_refreshAfterExternalManage) {
      return;
    }

    _refreshAfterExternalManage = false;
    unawaited(_refreshWalletAfterExternalManage());
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

  void _setRestoreProcessing(bool value) {
    if (isRestoreProcessing == value) return;
    isRestoreProcessing = value;
    update([Constant.onChangePaymentMethod]);
  }

  void _cancelPendingAppleStoreError() {
    _pendingAppleStoreErrorTimer?.cancel();
    _pendingAppleStoreErrorTimer = null;
  }

  void _cancelApplePurchaseTimeout() {
    _applePurchaseTimeoutTimer?.cancel();
    _applePurchaseTimeoutTimer = null;
  }

  void _markWalletStateChanged() {
    _walletStateChanged = true;
  }

  void _trackSubscriptionReviewPrompt() {
    unawaited(
      AppReviewService.trackPositiveAction(source: 'subscription_success'),
    );
  }

  void _startApplePurchaseWait() {
    _awaitingApplePurchaseResult = true;
    _setPaymentProcessing(true);
    _cancelApplePurchaseTimeout();
    _applePurchaseTimeoutTimer = Timer(const Duration(seconds: 75), () {
      _applePurchaseTimeoutTimer = null;
      if (!_awaitingApplePurchaseResult || hasActiveSubscription) return;

      _awaitingApplePurchaseResult = false;
      _closeBlockingLoader();
      _setPaymentProcessing(false);
      Utils.showToast(
        Get.context,
        'App Store is taking longer than expected. If Apple charged you, tap Restore.',
      );
    });
  }

  void _finishApplePurchaseWait() {
    if (!_awaitingApplePurchaseResult && !isPaymentProcessing) return;

    _awaitingApplePurchaseResult = false;
    _cancelApplePurchaseTimeout();
    _setPaymentProcessing(false);
  }

  bool _isTransientStoreKitError(dynamic error) {
    final text = error.toString().toLowerCase();
    return text.contains('storekit_no_response') ||
        text.contains('storekit_platform_no_response') ||
        text.contains('failed to get response from platform');
  }

  void _queueAppleStoreErrorToast(dynamic error) {
    final message = _friendlyIapError(error);

    if (!GetPlatform.isIOS) {
      Utils.showToast(Get.context, message);
      return;
    }

    _didReceiveAppleStoreError = true;
    _cancelPendingAppleStoreError();
    final delay = (_awaitingApplePurchaseResult || isRestoreProcessing)
        ? const Duration(seconds: 24)
        : const Duration(seconds: 8);

    _pendingAppleStoreErrorTimer = Timer(delay, () {
      _pendingAppleStoreErrorTimer = null;
      if (_didReceiveRestoredPurchase ||
          hasActiveSubscription ||
          _awaitingApplePurchaseResult ||
          isRestoreProcessing) {
        return;
      }
      Utils.showToast(Get.context, message);
    });
  }

  bool get _hasAuthenticatedWalletContext =>
      Database.isLogin && Database.loginUserFirebaseId.trim().isNotEmpty;

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
    isLoading = true;
    update([Constant.idGetCoinPlan]);

    try {
      final shouldUseUserContext = _hasAuthenticatedWalletContext;
      final uid = shouldUseUserContext ? Database.loginUserFirebaseId : "";
      final token =
          shouldUseUserContext ? await FirebaseAccessToken.onGet() ?? "" : "";

      final latestSettings = await SettingApi.callApi();
      if (latestSettings?.status == true) {
        Database.settingApiModel = latestSettings;
      }

      fetchCoinPlan = await FetchCoinPlanApi.callApi(
        uid: uid,
        token: token,
      );
      coinPlan.clear();
      coinPlan.addAll(fetchCoinPlan?.data ?? []);

      if (shouldUseUserContext) {
        await syncSessionCredits(refreshHome: false);
      } else {
        final normalizedCredits = fetchCoinPlan?.userCoin ?? 0;
        await Database.onSetUserCoin(normalizedCredits.toString());
      }
    } finally {
      isLoading = false;
      update([Constant.idGetCoinPlan]);
    }
  }

  Future<bool> _ensureAppleGuestAccountReady() async {
    if (!GetPlatform.isIOS) return true;

    if (!Database.isLogin || Database.loginUserFirebaseId.trim().isEmpty) {
      final ready = await GuestBrowsingSetup.ensureAuthenticatedGuestSession();
      if (!ready) return false;
    }

    final profileSynced = await GuestBrowsingSetup.refreshCurrentGuestProfile();
    if (!profileSynced &&
        (Database.isGuestMode ||
            Database.loginType == 2 ||
            Database.loginUserId.trim().isEmpty)) {
      await Database.onSetIsLogin(false);
      await Database.onSetGuestMode(true);
      final ready = await GuestBrowsingSetup.ensureAuthenticatedGuestSession();
      if (!ready) return false;
    }

    return Database.isLogin &&
        Database.loginUserFirebaseId.trim().isNotEmpty &&
        Database.loginUserId.trim().isNotEmpty;
  }

  ActiveSubscription? get activeSubscription =>
      fetchCoinPlan?.activeSubscription;

  bool get hasActiveSubscription {
    final sub = activeSubscription;
    if (sub == null) return false;

    final status = (sub.status ?? '').toLowerCase();
    final endsAt = sub.endsAt;
    return status == 'active' &&
        (endsAt == null || endsAt.isAfter(DateTime.now()));
  }

  bool isPlanActive(CoinPlan plan) {
    if (!hasActiveSubscription) return false;

    final active = activeSubscription;
    final planId = (plan.id ?? '').trim();
    final appleProductId = _appleProductKey(plan);
    final googleProductId = _googleProductKey(plan);

    return (active?.planId ?? '').trim() == planId ||
        (active?.appleProductId ?? '').trim() == appleProductId ||
        (active?.googleProductId ?? '').trim() == googleProductId;
  }

  String activeSubscriptionMessage() {
    final gateway = (activeSubscription?.paymentGateway ?? '').trim();
    final platform = (activeSubscription?.purchasePlatform ?? '').trim();
    final hasCancelledRenewal = activeSubscription?.autoRenew == false;
    final gatewayLower = gateway.toLowerCase();
    final hasKnownGateway = gateway.isNotEmpty;
    final gatewayPrefix = hasKnownGateway ? ' on $gateway' : '';
    final expiryText = _activeSubscriptionExpiryText();

    if (!GetPlatform.isIOS) {
      if (hasCancelledRenewal) {
        return 'Your active subscription$gatewayPrefix is already cancelled and remains available until $expiryText. After it expires, subscription purchase will be available again.';
      }

      return 'You already have an active subscription$gatewayPrefix. It expires on $expiryText. After expiry, subscription purchase will be available again.';
    }

    if (gatewayLower.contains('app store') || platform == 'ios') {
      if (hasCancelledRenewal) {
        return 'Your App Store subscription is cancelled and remains active until $expiryText.';
      }

      return GetPlatform.isIOS
          ? 'You already have an active App Store subscription. Use Manage or Restore instead of buying again.'
          : 'Your active subscription was purchased on App Store. Please manage it from an iPhone or App Store subscriptions.';
    }

    if (gateway.isNotEmpty) {
      return GetPlatform.isIOS
          ? 'Your active subscription was purchased on $gateway. Please manage it on that platform.'
          : 'You already have an active subscription. Please manage it on $gateway.';
    }

    return 'You already have an active subscription.';
  }

  bool _isAlreadySubscribedResponse(PurchaseCoinPlan? response) {
    if (response == null) return false;
    if (response.duplicate == true) return true;

    final message = (response.message ?? '').toLowerCase();
    if (message.isEmpty) return false;

    return message.contains('already active') ||
        message.contains('already subscribed') ||
        message.contains('already have an active subscription') ||
        message.contains('subscription already') ||
        message.contains('duplicate');
  }

  String _activeSubscriptionExpiryText() {
    final date = activeSubscription?.endsAt;
    if (date == null) {
      return 'the end of the current billing cycle';
    }

    return _formatSubscriptionDateTime(date);
  }

  String _formatSubscriptionDateTime(DateTime date) {
    final localDate = date.toLocal();
    final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
    final minute = localDate.minute.toString().padLeft(2, '0');
    final meridiem = localDate.hour >= 12 ? 'PM' : 'AM';

    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year} $hour:$minute $meridiem';
  }

  /// change payment method
  void onChangePaymentMethod(int index) async {
    selectedPaymentMethod = index;
    update([Constant.onChangePaymentMethod]);
  }

  bool _isEnabledForPlatform({
    bool? android,
    bool? ios,
    bool? fallback,
  }) {
    if (GetPlatform.isAndroid) return android ?? fallback ?? false;
    if (GetPlatform.isIOS) return ios ?? fallback ?? false;
    return false;
  }

  String _appleProductKey(CoinPlan? plan) {
    return (plan?.appleProductId?.trim().isNotEmpty == true)
        ? plan!.appleProductId!.trim()
        : (plan?.productId ?? '').trim();
  }

  String _googleProductKey(CoinPlan? plan) {
    return (plan?.googleProductId?.trim().isNotEmpty == true)
        ? plan!.googleProductId!.trim()
        : (plan?.productId ?? '').trim();
  }

  CoinPlan? _findPlanByProductId(String productId) {
    final normalizedProductId = productId.trim();
    if (normalizedProductId.isEmpty) return null;

    for (final plan in coinPlan) {
      if (_appleProductKey(plan) == normalizedProductId ||
          _googleProductKey(plan) == normalizedProductId ||
          (plan.productId ?? '').trim() == normalizedProductId) {
        return plan;
      }
    }

    return null;
  }

  String productKeyForSelectedPlan() {
    if (GetPlatform.isIOS) return _appleProductKey(selectedCoinPlan);
    return _googleProductKey(selectedCoinPlan);
  }

  List<PaymentMethodOption> get availablePaymentMethods {
    final settings = Database.settingApiModel?.data;

    if (GetPlatform.isIOS) {
      final isAppleIapEnabled =
          settings == null || settings.isAppleInAppPurchaseEnabled != false;

      return isAppleIapEnabled
          ? [
              PaymentMethodOption(
                id: paymentInAppPurchase,
                title: EnumLocale.txtAppStore.name.tr,
                image: AppAsset.appStoreImage,
                width: 50,
                height: 26,
              ),
            ]
          : [];
    }

    if (settings == null) {
      return GetPlatform.isAndroid
          ? [
              PaymentMethodOption(
                id: paymentInAppPurchase,
                title: EnumLocale.txtGooglePlay.name.tr,
                image: AppAsset.googleIcon,
                width: 50,
                height: 26,
              ),
            ]
          : [];
    }

    final methods = <PaymentMethodOption>[];

    if (_isEnabledForPlatform(
      android: settings.isStripeEnabled,
      ios: settings.isStripeIosEnabled,
      fallback: settings.isStripeEnabled,
    )) {
      methods.add(PaymentMethodOption(
        id: paymentStripe,
        title: EnumLocale.txtStripe.name.tr,
        image: AppAsset.stripe,
        width: 52,
        height: 26,
      ));
    }

    if (_isEnabledForPlatform(
      android: settings.isRazorpayEnabled,
      ios: settings.isRazorpayIosEnabled,
      fallback: settings.isRazorpayEnabled,
    )) {
      methods.add(PaymentMethodOption(
        id: paymentRazorpay,
        title: EnumLocale.txtRazorpay.name.tr,
        image: AppAsset.razorpay,
        width: 54,
        height: 28,
      ));
    }

    if (_isEnabledForPlatform(
      android: settings.isFlutterwaveEnabled,
      ios: settings.isFlutterwaveIosEnabled,
      fallback: settings.isFlutterwaveEnabled,
    )) {
      methods.add(PaymentMethodOption(
        id: paymentFlutterWave,
        title: EnumLocale.txtFlutterwave.name.tr,
        image: AppAsset.flutterWave,
        width: 54,
        height: 28,
      ));
    }

    if (_isEnabledForPlatform(
      android: settings.isPaystackAndroidEnabled,
      ios: settings.isPaystackIosEnabled,
    )) {
      methods.add(PaymentMethodOption(
        id: paymentPayStack,
        title: EnumLocale.txtPaystack.name.tr,
        image: AppAsset.payStackImage,
        width: 52,
        height: 28,
      ));
    }

    if (_isEnabledForPlatform(
      android: settings.isCashfreeAndroidEnabled,
      ios: settings.isCashfreeIosEnabled,
    )) {
      methods.add(PaymentMethodOption(
        id: paymentCashFree,
        title: EnumLocale.txtCashfree.name.tr,
        image: AppAsset.cashFreeImage,
        width: 54,
        height: 28,
      ));
    }

    if (_isEnabledForPlatform(
      android: settings.isPaypalAndroidEnabled,
      ios: settings.isPaypalIosEnabled,
    )) {
      methods.add(PaymentMethodOption(
        id: paymentPayPal,
        title: EnumLocale.txtPaypal.name.tr,
        image: AppAsset.payPalImage,
        width: 52,
        height: 28,
      ));
    }

    if (_isEnabledForPlatform(
      android: settings.isGooglePlayEnabled,
      ios: settings.isGooglePlayIosEnabled,
      fallback: settings.isGooglePlayEnabled,
    )) {
      methods.add(PaymentMethodOption(
        id: paymentInAppPurchase,
        title: EnumLocale.txtGooglePlay.name.tr,
        image: AppAsset.googleIcon,
        width: 50,
        height: 26,
      ));
    }

    return methods;
  }

  /// payment method condition
  Future<void> onClickPayNow(
      {required String id,
      required num amount,
      required String productKey,
      bool dismissSelector = false}) async {
    if (isPaymentProcessing || isRestoreProcessing) {
      return;
    }

    _setPaymentProcessing(true);
    try {
      if (GetPlatform.isIOS) {
        final ready = await _ensureAppleGuestAccountReady();
        if (!ready) {
          Utils.showToast(Get.context,
              "Unable to prepare App Store checkout. Please try again.");
          return;
        }
      }

      if (GetPlatform.isIOS && selectedPaymentMethod == -1) {
        selectedPaymentMethod = paymentInAppPurchase;
        update([Constant.onChangePaymentMethod]);
      }

      if (GetPlatform.isIOS && selectedPaymentMethod != paymentInAppPurchase) {
        Utils.showToast(Get.context, "iOS subscriptions use App Store only");
        return;
      }

      if (selectedPaymentMethod == -1) {
        Utils.showToast(Get.context, EnumLocale.txtSelectPaymentMethod.name.tr);
        return;
      }

      if (hasActiveSubscription) {
        Utils.showToast(Get.context, activeSubscriptionMessage());
        return;
      }

      if (dismissSelector) {
        _closePaymentSelectorIfOpen();
        await 250.milliseconds.delay();
      }

      if (selectedPaymentMethod == paymentRazorpay) {
        await onClickRazorPay(amount, id);
      } else if (selectedPaymentMethod == paymentStripe) {
        await onClickStripe(amount, id);
      } else if (selectedPaymentMethod == paymentFlutterWave) {
        await onClickFlutterWave(amount, id);
      } else if (selectedPaymentMethod == paymentInAppPurchase) {
        final checkoutProductKey = productKeyForSelectedPlan().isNotEmpty
            ? productKeyForSelectedPlan()
            : productKey;
        await onClickInAppPurchase(amount, id, checkoutProductKey);
      } else if (selectedPaymentMethod == paymentCashFree) {
        await onClickCashFree(amount, id);
      } else if (selectedPaymentMethod == paymentPayStack) {
        await onClickPayStack(amount, id);
      } else if (selectedPaymentMethod == paymentPayPal) {
        await onClickPayPal(amount, id);
      } else {
        Utils.showToast(Get.context, EnumLocale.txtSelectPaymentMethod.name.tr);
      }
    } finally {
      if (!_awaitingApplePurchaseResult) {
        _setPaymentProcessing(false);
      }
    }
  }

  /// flutter wave
  Future<void> onClickFlutterWave(num amount, String id) async {
    Utils.showLog("Flutter Wave Payment Working....");
    try {
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
            _trackSubscriptionReviewPrompt();
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
        final message = purchaseCoinPlan?.duplicate == true
            ? activeSubscriptionMessage()
            : "Subscription activated successfully";
        Utils.showToast(Get.context, message);
        if (purchaseCoinPlan?.duplicate != true) {
          _trackSubscriptionReviewPrompt();
        }
        _closePaymentSelectorIfOpen();
      } else if (_isAlreadySubscribedResponse(purchaseCoinPlan)) {
        await fetchCoinPlanList();
        await syncSessionCredits();
        update([Constant.onChangePaymentMethod]);
        Utils.showToast(Get.context, activeSubscriptionMessage());
      } else {
        final backendMessage = purchaseCoinPlan?.message?.trim();
        Utils.showToast(
          Get.context,
          (backendMessage?.isNotEmpty == true)
              ? backendMessage!
              : EnumLocale.txtSomeThingWentWrong.name.tr,
        );
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
            _trackSubscriptionReviewPrompt();
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
      _closeBlockingLoader();
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("RazorPay Payment Failed => $e");
    }
  }

  ///in app purchase
  Future<void> onClickInAppPurchase(
      num amount, String id, String productKey) async {
    if (GetPlatform.isIOS) {
      final ready = await _ensureAppleGuestAccountReady();
      if (!ready) {
        Utils.showToast(Get.context,
            "Unable to prepare App Store checkout. Please try again.");
        return;
      }
    }

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
      _didReceiveAppleStoreError = false;
      _cancelPendingAppleStoreError();
      final productsReady = await helper.initStoreInfo();
      if (!productsReady) return;
      purchases = helper.getPurchases();

      final product = helper.getProductDetail(normalizedProductKey);
      _closeBlockingLoader();

      if (product != null) {
        Utils.showLog("Product found: ${product.title} - ${product.price}");
        _startApplePurchaseWait();
        final started = await helper.buySubscription(product, purchases ?? {});
        if (!started) {
          Utils.showLog("IAP purchase sheet did not start.");
          _finishApplePurchaseWait();
        }
      } else {
        Utils.showToast(
          Get.context,
          _friendlyIapError("No products found"),
        );
        Utils.showLog("Available products: ${helper.getAvailableProducts()}");
      }
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("In App Purchase Failed => $e");
      _finishApplePurchaseWait();
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  ///cash free
  Future<void> onClickCashFree(num amount, String id) async {
    Utils.showLog("cash free Payment Working....");
    try {
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
            _trackSubscriptionReviewPrompt();
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
            _trackSubscriptionReviewPrompt();
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
            _trackSubscriptionReviewPrompt();
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
    await fetchCoinPlanList();
  }

  Future<void> restoreAppleSubscriptions() async {
    if (!GetPlatform.isIOS) return;

    if (isRestoreProcessing || isPaymentProcessing) {
      return;
    }

    _setRestoreProcessing(true);
    try {
      final ready = await _ensureAppleGuestAccountReady();
      if (!ready) {
        Utils.showToast(
            Get.context, "Unable to prepare restore. Please try again.");
        return;
      }

      final productKeys = coinPlan
          .map(_appleProductKey)
          .where((productId) => productId.trim().isNotEmpty)
          .toSet()
          .toList();

      if (productKeys.isEmpty) {
        Utils.showToast(Get.context, "No App Store product is configured");
        return;
      }

      final helper = InAppPurchaseHelper();
      helper.init(
        paymentType: "App Store",
        userId: Database.loginUserFirebaseId,
        productKey: productKeys,
        rupee: 0,
        callBack: () {},
      );
      helper.setCallback(this);

      _showBlockingLoader();
      _isRestoringAppleSubscriptions = true;
      _didReceiveRestoredPurchase = false;
      _didReceiveAppleStoreError = false;
      _cancelPendingAppleStoreError();
      await helper.restorePurchases(this);
      _closeBlockingLoader();
      await 10000.milliseconds.delay();
      if (!_didReceiveRestoredPurchase && !_didReceiveAppleStoreError) {
        Utils.showToast(
          Get.context,
          "No App Store subscription was found to restore.",
        );
      }
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("Restore Apple Subscription Failed => $e");
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
    } finally {
      _isRestoringAppleSubscriptions = false;
      _closeBlockingLoader();
      _setRestoreProcessing(false);
    }
  }

  Future<void> _openExternalUrl(String? url, String fallbackUrl) async {
    final value = (url?.trim().isNotEmpty == true) ? url!.trim() : fallbackUrl;
    final uri = Uri.tryParse(value);

    if (uri == null) {
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openAppleManageSubscriptions() async {
    _refreshAfterExternalManage = true;
    await _openExternalUrl(
      Database.settingApiModel?.data?.appleManageSubscriptionsUrl,
      "https://apps.apple.com/account/subscriptions",
    );
  }

  Future<void> _refreshWalletAfterExternalManage() async {
    await 1200.milliseconds.delay();
    await fetchCoinPlanList();
    await syncSessionCredits();
    await _notifyAuthenticatedWalletStateChanged();
  }

  Future<void> openAppleEula() async {
    await _openExternalUrl(
      null,
      "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
    );
  }

  Future<void> openPrivacyPolicy() async {
    await _openExternalUrl(
      null,
      "https://notisboard.com/privacy-policy",
    );
  }

  @override
  void onBillingError(error) {
    _closeBlockingLoader();
    Utils.showLog("IAP Billing Error: $error");
    final errorText = error.toString().toLowerCase();

    if (errorText.contains('cancel')) {
      _finishApplePurchaseWait();
      Utils.showToast(Get.context, _friendlyIapError(error));
      return;
    }

    if (GetPlatform.isIOS &&
        _awaitingApplePurchaseResult &&
        _isTransientStoreKitError(error)) {
      _queueAppleStoreErrorToast(error);
      return;
    }

    if (!_isTransientStoreKitError(error)) {
      _finishApplePurchaseWait();
    }

    _queueAppleStoreErrorToast(error);
  }

  String _friendlyIapError(dynamic error) {
    final raw = error?.toString() ?? '';
    final lower = raw.toLowerCase();
    final isRestore = _isRestoringAppleSubscriptions;

    if (lower.contains('purchase canceled') || lower.contains('cancel')) {
      return 'Purchase canceled';
    }

    if (lower.contains('store not available')) {
      return 'App Store is not available on this device. Please check App Store sign-in and try again.';
    }

    if (lower.contains('storekit_no_response') ||
        lower.contains('storekit_platform_no_response') ||
        lower.contains('failed to get response from platform')) {
      return isRestore
          ? 'Restore could not reach App Store. Please wait a few seconds and try Restore again.'
          : 'App Store did not return this subscription. Please confirm the Apple Product ID is active in App Store Connect.';
    }

    if (lower.contains('no products found') ||
        lower.contains('product not found')) {
      return 'App Store product is not available yet. Please confirm the Apple Product ID is active in App Store Connect.';
    }

    if (lower.trim().isEmpty || lower.contains('null')) {
      return isRestore
          ? 'Restore failed. Please try again.'
          : 'Payment failed. Please try again.';
    }

    return isRestore
        ? 'Restore failed. Please try again.'
        : 'Payment failed. Please try again.';
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
    final purchaseEventKey =
        '${product.productID}:${product.purchaseID ?? product.transactionDate ?? product.status.name}';

    if (!_activeAppleVerificationKeys.add(purchaseEventKey)) {
      Utils.showLog("IAP duplicate event ignored: $purchaseEventKey");
      return;
    }

    _cancelPendingAppleStoreError();
    final isRestoreEvent = _isRestoringAppleSubscriptions ||
        product.status == PurchaseStatus.restored;
    if (isRestoreEvent) {
      _didReceiveRestoredPurchase = true;
    }

    try {
      // Show loading dialog
      _showBlockingLoader();
      final token = (await FirebaseAccessToken.onGet() ?? '').trim();
      final uid = Database.loginUserFirebaseId.trim().isNotEmpty
          ? Database.loginUserFirebaseId.trim()
          : (firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '').trim();

      if (token.isEmpty || uid.isEmpty) {
        _closeBlockingLoader();
        Utils.showToast(
          Get.context,
          "Session expired. Please login again to continue purchase sync.",
        );
        return;
      }
      final resolvedPlan =
          selectedCoinPlan ?? _findPlanByProductId(product.productID);

      if (resolvedPlan == null) {
        _closeBlockingLoader();
        Utils.showToast(Get.context, "Subscription plan not configured");
        return;
      }

      final receiptData =
          product.verificationData.serverVerificationData.trim().isNotEmpty
              ? product.verificationData.serverVerificationData
              : product.verificationData.localVerificationData;

      final isSuccess = GetPlatform.isIOS
          ? await PurchaseCoinPlanApi.verifyAppleInAppPurchase(
              coinPlanId: resolvedPlan.id.toString(),
              productId: product.productID,
              receiptData: receiptData,
              transactionId: product.purchaseID ?? '',
              token: token,
              uid: uid,
            )
          : await PurchaseCoinPlanApi.callApi(
              coinPlanId: resolvedPlan.id.toString(),
              paymentGateway: "Google Play",
              token: token,
              uid: uid,
            );

      // Hide loading dialog
      _closeBlockingLoader();

      if (isSuccess?.status == true) {
        await _applyLinkedPurchaseAuth(isSuccess?.auth);
        await fetchCoinPlanList();
        await syncSessionCredits();
        _markWalletStateChanged();
        await _notifyAuthenticatedWalletStateChanged();
        Utils.showToast(
          Get.context,
          isRestoreEvent
              ? "Subscription restored successfully"
              : isSuccess?.duplicate == true
                  ? "Subscription already active"
                  : "Subscription activated successfully",
        );
        if (!isRestoreEvent && isSuccess?.duplicate != true) {
          _trackSubscriptionReviewPrompt();
        }
        _closePaymentSelectorIfOpen();
      } else {
        final message = isSuccess?.message?.trim();
        Utils.showToast(
          Get.context,
          message?.isNotEmpty == true
              ? message!
              : EnumLocale.txtSomeThingWentWrong.name.tr,
        );
      }
    } catch (e) {
      // Hide loading dialog if there's an error
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Utils.showLog("API call failed: $e");
      Utils.showToast(Get.context, EnumLocale.txtSomeThingWentWrong.name.tr);
    } finally {
      _activeAppleVerificationKeys.remove(purchaseEventKey);
      _finishApplePurchaseWait();
    }
  }

  Future<void> _applyLinkedPurchaseAuth(PurchaseAuth? auth) async {
    final firebaseId =
        (auth?.firebaseId ?? auth?.user?.firebaseId ?? '').trim();
    final customToken = (auth?.customToken ?? '').trim();

    if (firebaseId.isEmpty) return;

    var currentUid =
        (firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '').trim();
    if (currentUid != firebaseId) {
      var tokenForSignIn = customToken;

      if (tokenForSignIn.isEmpty) {
        final customTokenResponse = await GetFirebaseCustomTokenApi.callApi(
          firebaseUid: firebaseId,
        );
        tokenForSignIn = (customTokenResponse?.customToken ?? '').trim();
      }

      if (tokenForSignIn.isNotEmpty) {
        await firebase_auth.FirebaseAuth.instance
            .signInWithCustomToken(tokenForSignIn);
      } else {
        Utils.showLog(
            "Purchase auth link skipped: missing custom token for $firebaseId");
        return;
      }

      currentUid =
          (firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '').trim();
      if (currentUid != firebaseId) {
        Utils.showLog(
            "Purchase auth link skipped: uid mismatch after sign-in. currentUid=$currentUid targetUid=$firebaseId");
        return;
      }
    }

    final user = auth?.user;
    await Database.onSetIsLogin(true);
    await Database.onSetGuestMode(user?.isGuestAccount == true);
    await Database.onSetLoginUserFirebaseId(currentUid);

    if ((user?.id ?? '').trim().isNotEmpty) {
      await Database.onSetLoginUserId(user!.id!);
    }
    await Database.onSetLoginType(user?.loginType ?? Database.loginType);
    await Database.onSetFillProfile(true);
    await Database.onSetSeenOnboarding(true);
    await Database.onSetLoginUserName(user?.fullName ?? Database.loginUserName);
    await Database.onSetLoginUserNickName(
        user?.nickName ?? Database.loginUserNickName);
    await Database.onSetLoginUserEmail(user?.email ?? Database.loginUserEmail);
    await Database.onSetLoginUserProfilePic(
        user?.profilePic ?? Database.loginUserProfilePic);
    await Database.onSetLoginUserPhoneNumber(
        user?.phoneNumber ?? Database.loginUserPhoneNumber);
    await Database.onSetLoginUserBirthDate(
        user?.birthDate ?? Database.loginUserBirthDate);
    await Database.onSetLoginUserGender(
        user?.gender ?? Database.loginUserGender);
    await Database.onSetLoginUserCountry(user?.country ?? Database.country);
    await Database.onSetLoginUserCountryFlag(
        user?.countryFlag ?? Database.countryFlag);
    await GuestBrowsingSetup.refreshCurrentGuestProfile(
        firebaseUid: currentUid);
  }

  Future<void> _notifyAuthenticatedWalletStateChanged() async {
    update([Constant.idGetCoinPlan, Constant.onChangePaymentMethod]);

    if (_hasLiveController<BottomBarController>()) {
      Get.find<BottomBarController>().update([Constant.idBottomBar]);
    }

    if (_hasLiveController<HomeScreenController>()) {
      await Get.find<HomeScreenController>().onRefresh();
    }

    if (_hasLiveController<ListenersScreenController>()) {
      await Get.find<ListenersScreenController>().onRefresh();
    }

    if (_hasLiveController<AllListenersController>()) {
      await Get.find<AllListenersController>().onRefresh();
    }

    if (_hasLiveController<TopListenersViewAllController>()) {
      await Get.find<TopListenersViewAllController>().onRefresh();
    }

    if (_hasLiveController<EditProfileController>()) {
      Get.find<EditProfileController>().update([Constant.idProfile]);
    }
  }

  bool _hasLiveController<T>() => Get.isRegistered<T>() && !Get.isPrepared<T>();
}

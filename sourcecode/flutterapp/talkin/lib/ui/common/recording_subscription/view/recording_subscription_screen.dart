import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/payment/in_app_purchase/iap_callback.dart';
import 'package:notisboard/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:notisboard/ui/common/recording_subscription/api/recording_subscription_api.dart';
import 'package:notisboard/ui/common/recording_subscription/model/recording_subscription_model.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/common_payment.dart';

import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/guest_browsing_setup.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentMethodOption {
  final int id;
  final String title;
  final String image;
  final double? width;
  final double? height;

  PaymentMethodOption({
    required this.id,
    required this.title,
    required this.image,
    this.width,
    this.height,
  });
}

class RecordingSubscriptionScreen extends StatefulWidget {
  const RecordingSubscriptionScreen({super.key});

  @override
  State<RecordingSubscriptionScreen> createState() =>
      _RecordingSubscriptionScreenState();
}

class _RecordingSubscriptionScreenState
    extends State<RecordingSubscriptionScreen>
    with WidgetsBindingObserver
    implements IAPCallback {
  bool isLoading = true;
  bool isPurchasing = false;
  RecordingSubscriptionModel? subscription;
  List<RecordingStoragePlanModel> plans = [];
  RecordingStoragePlanModel? selectedPlan;
  String status = "none";
  bool hasActivePlan = false;

  int selectedPaymentMethod = -1;
  List<PaymentMethodOption> paymentMethods = [];

  // Apple IAP state
  Map<String, PurchaseDetails>? _iapPurchases;
  bool _awaitingApplePurchaseResult = false;
  Timer? _applePurchaseTimeoutTimer;
  Timer? _pendingAppleStoreErrorTimer;
  bool _didReceiveAppleStoreError = false;
  bool _isRestoringAppleSubscriptions = false;
  bool _didReceiveRestoredPurchase = false;
  final Set<String> _activeAppleVerificationKeys = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelApplePurchaseTimeout();
    _cancelPendingAppleStoreError();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No-op for now, could add refresh logic if needed
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchStatus(),
      _fetchPlans(),
    ]);
    _loadPaymentMethods();
    if (mounted) setState(() => isLoading = false);
  }

  /// Loads available payment methods based on platform and settings.
  /// iOS: ONLY Apple In-App Purchase (App Store) is allowed.
  /// Android: Google Play and third-party gateways (Stripe, RazorPay, etc.) based on settings.
  void _loadPaymentMethods() {
    paymentMethods.clear();
    selectedPaymentMethod = -1;
    final settings = Database.settingApiModel?.data;

    // iOS: Enforce Apple IAP only — no other payment methods allowed
    if (GetPlatform.isIOS) {
      final isEnabled =
          settings == null || settings.isAppleInAppPurchaseEnabled != false;
      if (isEnabled) {
        paymentMethods = [
          PaymentMethodOption(
              id: 3,
              title: EnumLocale.txtAppStore.name.tr,
              image: AppAsset.appStoreImage,
              width: 50,
              height: 26),
        ];
        selectedPaymentMethod = 3;
      }
      return; // Early return ensures no other methods are added on iOS
    }

    // Android: Load all enabled payment methods
    if (settings == null) {
      paymentMethods = [
        PaymentMethodOption(
            id: 3,
            title: EnumLocale.txtGooglePlay.name.tr,
            image: AppAsset.googleIcon,
            width: 50,
            height: 26),
      ];
      selectedPaymentMethod = 3;
      return;
    }

    _addIfEnabled(1, EnumLocale.txtStripe.name.tr, AppAsset.stripe, 52, 26,
        android: settings.isStripeEnabled);
    _addIfEnabled(0, EnumLocale.txtRazorpay.name.tr, AppAsset.razorpay, 54, 28,
        android: settings.isRazorpayEnabled);
    _addIfEnabled(
        2, EnumLocale.txtFlutterwave.name.tr, AppAsset.flutterWave, 54, 28,
        android: settings.isFlutterwaveEnabled);
    _addIfEnabled(
        5, EnumLocale.txtPaystack.name.tr, AppAsset.payStackImage, 52, 28,
        android: settings.isPaystackAndroidEnabled);
    _addIfEnabled(
        4, EnumLocale.txtCashfree.name.tr, AppAsset.cashFreeImage, 54, 28,
        android: settings.isCashfreeAndroidEnabled);
    _addIfEnabled(6, EnumLocale.txtPaypal.name.tr, AppAsset.payPalImage, 52, 28,
        android: settings.isPaypalAndroidEnabled);
    _addIfEnabled(
        3, EnumLocale.txtGooglePlay.name.tr, AppAsset.googleIcon, 50, 26,
        android: settings.isGooglePlayEnabled);

    if (paymentMethods.isNotEmpty && selectedPaymentMethod == -1) {
      selectedPaymentMethod = paymentMethods.first.id;
    }
  }

  void _addIfEnabled(int id, String title, String image, double? w, double? h,
      {bool? android, bool? ios}) {
    final enabled = GetPlatform.isAndroid ? (android ?? false) : (ios ?? false);
    if (enabled) {
      paymentMethods.add(PaymentMethodOption(
          id: id, title: title, image: image, width: w, height: h));
    }
  }

  // ── Apple IAP Helpers ──────────────────────────────────────────────

  String _appleProductKey(RecordingStoragePlanModel? plan) {
    return (plan?.appleProductId?.trim().isNotEmpty == true)
        ? plan!.appleProductId!.trim()
        : '';
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

  void _cancelApplePurchaseTimeout() {
    _applePurchaseTimeoutTimer?.cancel();
    _applePurchaseTimeoutTimer = null;
  }

  void _cancelPendingAppleStoreError() {
    _pendingAppleStoreErrorTimer?.cancel();
    _pendingAppleStoreErrorTimer = null;
  }

  void _startApplePurchaseWait() {
    _awaitingApplePurchaseResult = true;
    setState(() => isPurchasing = true);
    _cancelApplePurchaseTimeout();
    _applePurchaseTimeoutTimer = Timer(const Duration(seconds: 75), () {
      _applePurchaseTimeoutTimer = null;
      if (!_awaitingApplePurchaseResult) return;
      _awaitingApplePurchaseResult = false;
      _closeBlockingLoader();
      setState(() => isPurchasing = false);
      Utils.showToast(
        context,
        'App Store is taking longer than expected. If Apple charged you, tap Restore.',
      );
    });
  }

  void _finishApplePurchaseWait() {
    if (!_awaitingApplePurchaseResult && !isPurchasing) return;
    _awaitingApplePurchaseResult = false;
    _cancelApplePurchaseTimeout();
    _closeBlockingLoader();
    if (mounted) setState(() => isPurchasing = false);
  }

  bool _isTransientStoreKitError(dynamic error) {
    final text = error.toString().toLowerCase();
    return text.contains('storekit_no_response') ||
        text.contains('storekit_platform_no_response') ||
        text.contains('failed to get response from platform');
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

  void _queueAppleStoreErrorToast(dynamic error) {
    final message = _friendlyIapError(error);
    _didReceiveAppleStoreError = true;
    _cancelPendingAppleStoreError();
    final delay =
        (_awaitingApplePurchaseResult || _isRestoringAppleSubscriptions)
            ? const Duration(seconds: 24)
            : const Duration(seconds: 8);
    _pendingAppleStoreErrorTimer = Timer(delay, () {
      _pendingAppleStoreErrorTimer = null;
      if (_didReceiveRestoredPurchase ||
          _awaitingApplePurchaseResult ||
          _isRestoringAppleSubscriptions) {
        return;
      }
      if (mounted) Utils.showToast(context, message);
    });
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

  Future<void> _fetchStatus() async {
    final response = await RecordingSubscriptionApi.getSubscriptionStatus();
    if (response != null && response['status'] == true) {
      if (response['subscription'] != null) {
        subscription =
            RecordingSubscriptionModel.fromJson(response['subscription']);
      }
      status = response['subscriptionStatus'] ?? "none";
      hasActivePlan = response['hasSubscription'] ?? false;
    }
  }

  Future<void> _fetchPlans() async {
    final result = await RecordingSubscriptionApi.getPlans();
    if (result != null && result.isNotEmpty) {
      plans = result;
      selectedPlan =
          result.firstWhere((p) => p.isPopular, orElse: () => result.first);
    }
  }

  String _gatewayName(int methodId) {
    switch (methodId) {
      case 0:
        return "RazorPay";
      case 1:
        return "Stripe";
      case 2:
        return "Flutter Wave";
      case 3:
        return GetPlatform.isIOS ? "Apple" : "Google Play";
      case 4:
        return "cash free";
      case 5:
        return "pay stack";
      case 6:
        return "pay pal";
      default:
        return "system";
    }
  }

  Future<void> _purchasePlan() async {
    if (selectedPlan == null) {
      Utils.showToast(context, "No plan available.");
      return;
    }
    if (selectedPaymentMethod == -1) {
      Utils.showToast(context, "Please select a payment method.");
      return;
    }
    if (isPurchasing) return;

    // iOS enforcement: Only Apple IAP is allowed for recording subscriptions
    if (GetPlatform.isIOS && selectedPaymentMethod != 3) {
      Utils.showToast(context,
          "iOS requires Apple In-App Purchase. Please select App Store.");
      return;
    }

    setState(() => isPurchasing = true);

    try {
      final amount = (selectedPlan!.price ?? 0).toDouble();
      final planId = selectedPlan!.id ?? '';
      final gateway = _gatewayName(selectedPaymentMethod);

      // iOS In-App Purchase — use real App Store flow
      if (selectedPaymentMethod == 3 && GetPlatform.isIOS) {
        await _purchaseViaAppleIAP(planId);
        return;
      }

      // Android Google Play or third-party gateways — use existing flow
      if (selectedPaymentMethod == 3 && GetPlatform.isAndroid) {
        final res = await RecordingSubscriptionApi.purchasePlan(
          planId: planId,
          paymentGateway: gateway,
        );
        if (mounted) {
          if (res != null) {
            Utils.showToast(context, "Subscription Activated Successfully!");
            _fetchData();
          } else {
            Utils.showToast(context, "Failed to activate subscription.");
          }
        }
        setState(() => isPurchasing = false);
        return;
      }

      // Third-party gateways
      switch (selectedPaymentMethod) {
        case 0:
          await razorPay(
              amount: amount,
              onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 1:
          await stripe(
              amount: amount,
              onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 2:
          await flutterWave(
              amount: amount,
              onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 4:
          await cashFree(
              amount: amount,
              onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 5:
          await payStack(
              amount: amount,
              onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 6:
          await payPal(
              amount: amount,
              onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        default:
          Utils.showToast(context, "Invalid payment method.");
          setState(() => isPurchasing = false);
      }
    } catch (e) {
      Utils.showLog("Recording subscription payment error: $e");
      if (mounted) {
        Utils.showToast(context, "Payment failed. Please try again.");
      }
      if (mounted) setState(() => isPurchasing = false);
    }
  }

  Future<void> _purchaseViaAppleIAP(String planId) async {
    final ready = await _ensureAppleGuestAccountReady();
    if (!ready) {
      if (mounted) {
        Utils.showToast(
            context, "Unable to prepare App Store checkout. Please try again.");
      }
      setState(() => isPurchasing = false);
      return;
    }

    final productKey = _appleProductKey(selectedPlan);
    if (productKey.isEmpty) {
      if (mounted) {
        Utils.showToast(
            context, "App Store product is not configured for this plan.");
      }
      setState(() => isPurchasing = false);
      return;
    }

    final helper = InAppPurchaseHelper();
    helper.init(
      paymentType: "Recording Storage",
      userId: Database.loginUserFirebaseId,
      productKey: [productKey],
      rupee: (selectedPlan!.price ?? 0).toDouble(),
      callBack: () {},
    );
    helper.setCallback(this);
    helper.ensurePurchaseListener();

    _showBlockingLoader();
    try {
      _didReceiveAppleStoreError = false;
      _cancelPendingAppleStoreError();
      final productsReady = await helper.initStoreInfo();
      if (!productsReady) {
        _finishApplePurchaseWait();
        return;
      }
      _iapPurchases = helper.getPurchases();
      final product = helper.getProductDetail(productKey);
      _closeBlockingLoader();

      if (product != null) {
        Utils.showLog(
            "Recording IAP product found: ${product.title} - ${product.price}");
        _startApplePurchaseWait();
        final started =
            await helper.buySubscription(product, _iapPurchases ?? {});
        if (!started) {
          Utils.showLog("Recording IAP purchase sheet did not start.");
          _finishApplePurchaseWait();
        }
      } else {
        _finishApplePurchaseWait();
        if (mounted) {
          Utils.showToast(context, _friendlyIapError("No products found"));
          Utils.showLog(
              "Available recording IAP products: ${helper.getAvailableProducts()}");
        }
      }
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("Recording IAP Failed => $e");
      _finishApplePurchaseWait();
      if (mounted) {
        Utils.showToast(context, "Payment failed. Please try again.");
      }
    }
  }

  Future<void> _onPaymentSuccess(String gateway, String planId) async {
    final res = await RecordingSubscriptionApi.purchasePlan(
        planId: planId, paymentGateway: gateway);
    if (mounted) {
      setState(() => isPurchasing = false);
      if (res != null) {
        Utils.showToast(context, "Subscription Activated Successfully!");
        _fetchData();
      } else {
        Utils.showToast(
            context, "Failed to activate subscription after payment.");
      }
    }
  }

  // ── IAPCallback implementation ────────────────────────────────────

  @override
  void onLoaded(bool initialized) {
    Utils.showLog("Recording IAP Loaded: $initialized");
  }

  @override
  void onPending(PurchaseDetails product) {
    Utils.showLog("Recording IAP Pending: ${product.productID}");
    if (mounted) Utils.showToast(context, "Payment is pending...");
  }

  @override
  void onBillingError(error) {
    _closeBlockingLoader();
    Utils.showLog("Recording IAP Billing Error: $error");
    final errorText = error.toString().toLowerCase();

    if (errorText.contains('cancel')) {
      _finishApplePurchaseWait();
      if (mounted) Utils.showToast(context, _friendlyIapError(error));
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

  @override
  void onSuccessPurchase(PurchaseDetails product) async {
    Utils.showLog("Recording IAP Success: ${product.productID}");
    final purchaseEventKey =
        '${product.productID}:${product.purchaseID ?? product.transactionDate ?? product.status.name}';

    if (!_activeAppleVerificationKeys.add(purchaseEventKey)) {
      Utils.showLog("Recording IAP duplicate event ignored: $purchaseEventKey");
      return;
    }

    _cancelPendingAppleStoreError();
    final isRestoreEvent = _isRestoringAppleSubscriptions ||
        product.status == PurchaseStatus.restored;
    if (isRestoreEvent) {
      _didReceiveRestoredPurchase = true;
    }

    try {
      _showBlockingLoader();
      final token = (await FirebaseAccessToken.onGet() ?? '').trim();
      final uid = Database.loginUserFirebaseId.trim().isNotEmpty
          ? Database.loginUserFirebaseId.trim()
          : (firebase_auth.FirebaseAuth.instance.currentUser?.uid ?? '').trim();

      if (token.isEmpty || uid.isEmpty) {
        _closeBlockingLoader();
        if (mounted) {
          Utils.showToast(context,
              "Session expired. Please login again to continue purchase sync.");
        }
        return;
      }

      final receiptData =
          product.verificationData.serverVerificationData.trim().isNotEmpty
              ? product.verificationData.serverVerificationData
              : product.verificationData.localVerificationData;

      final result =
          await RecordingSubscriptionApi.verifyAppleRecordingSubscription(
        planId: selectedPlan?.id,
        productId: product.productID,
        receiptData: receiptData,
        transactionId: product.purchaseID ?? '',
      );

      _closeBlockingLoader();

      if (result != null && result['status'] == true) {
        if (mounted) {
          Utils.showToast(
            context,
            isRestoreEvent
                ? "Subscription restored successfully"
                : result['duplicate'] == true
                    ? "Subscription already active"
                    : "Subscription Activated Successfully!",
          );
          _fetchData();
        }
      } else {
        if (mounted) {
          final message = result?['message']?.toString().trim();
          Utils.showToast(
            context,
            (message?.isNotEmpty == true)
                ? message!
                : "Failed to activate subscription.",
          );
        }
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Utils.showLog("Recording IAP verify API failed: $e");
      if (mounted) {
        Utils.showToast(
            context, "Payment verification failed. Please try again.");
      }
    } finally {
      _activeAppleVerificationKeys.remove(purchaseEventKey);
      _finishApplePurchaseWait();
    }
  }

  // ── Restore & Manage (iOS) ────────────────────────────────────────

  Future<void> _restoreAppleSubscriptions() async {
    if (!GetPlatform.isIOS) return;
    if (_isRestoringAppleSubscriptions || isPurchasing) return;

    _isRestoringAppleSubscriptions = true;
    _didReceiveRestoredPurchase = false;
    _didReceiveAppleStoreError = false;
    _cancelPendingAppleStoreError();

    try {
      final ready = await _ensureAppleGuestAccountReady();
      if (!ready) {
        if (mounted) {
          Utils.showToast(
              context, "Unable to prepare restore. Please try again.");
        }
        return;
      }

      final productKeys = plans
          .map(_appleProductKey)
          .where((id) => id.trim().isNotEmpty)
          .toSet()
          .toList();

      if (productKeys.isEmpty) {
        if (mounted) {
          Utils.showToast(context, "No App Store product is configured");
        }
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
      await helper.restorePurchases(this);
      _closeBlockingLoader();
      await 10000.milliseconds.delay();
      if (!_didReceiveRestoredPurchase && !_didReceiveAppleStoreError) {
        if (mounted) {
          Utils.showToast(
              context, "No App Store subscription was found to restore.");
        }
      }
    } catch (e) {
      _closeBlockingLoader();
      Utils.showLog("Restore Recording Apple Subscription Failed => $e");
      if (mounted) {
        Utils.showToast(context, "Restore failed. Please try again.");
      }
    } finally {
      _isRestoringAppleSubscriptions = false;
      _closeBlockingLoader();
    }
  }

  Future<void> _openAppleManageSubscriptions() async {
    final uri = Uri.tryParse("https://apps.apple.com/account/subscriptions");
    if (uri != null && mounted) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.redesignScreenBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.redesignBrandDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Recording Storage",
          style: AppFontStyle.fontStyleW700(
              fontSize: 18, fontColor: AppColors.redesignBrandDark),
        ),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: AppColors.redesignBrandRed))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          if (plans.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPlanSelector(),
          ],
          if (paymentMethods.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              "Payment Method",
              style: AppFontStyle.fontStyleW700(
                  fontSize: 18, fontColor: AppColors.redesignBrandDark),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodSelector(),
          ],
          const SizedBox(height: 24),
          Text(
            "Plan Benefits",
            style: AppFontStyle.fontStyleW700(
                fontSize: 18, fontColor: AppColors.redesignBrandDark),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(Icons.cloud_done_rounded,
              "Secure Cloud Storage for all recordings"),
          _buildBenefitItem(Icons.history_rounded,
              "${selectedPlan?.storageDays ?? 30}-day access to replay consultation sessions"),
          _buildBenefitItem(
              Icons.privacy_tip_rounded, "Mutual consent enforced for privacy"),
          const SizedBox(height: 40),
          if (GetPlatform.isIOS) ...[
            _buildAppleActionButtons(),
          ],
          _buildPurchaseAction(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color cardColor = AppColors.white;
    Color iconColor = AppColors.redesignBrandDark;
    IconData icon = Icons.cloud_off_rounded;
    String title = "No Active Plan";
    String subtitle = "Get a storage plan to enable consultation recording.";

    if (hasActivePlan && status == "active") {
      cardColor = AppColors.redesignStatusSuccessBg;
      iconColor = AppColors.redesignStatusSuccessDark;
      icon = Icons.cloud_done_rounded;
      title = "Active Subscription";

      final days = subscription?.endsAt?.difference(DateTime.now()).inDays ?? 0;
      subtitle = "Valid for $days more days.";
    } else if (status == "grace_period") {
      cardColor = AppColors.redesignAccentSoftBg;
      iconColor = AppColors.redesignBrandRed;
      icon = Icons.lock_clock_rounded;
      title = "Grace Period Active";

      final days =
          subscription?.gracePeriodEndsAt?.difference(DateTime.now()).inDays ??
              0;
      subtitle =
          "Your recordings are locked. Renew within $days days to prevent deletion.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFontStyle.fontStyleW700(
                          fontSize: 16, fontColor: AppColors.redesignBrandDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppFontStyle.fontStyleW500(
                          fontSize: 14, fontColor: AppColors.redesignMutedText),
                    ),
                  ],
                ),
              )
            ],
          ),
          // Apple manage buttons moved to bottom
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Plan",
          style: AppFontStyle.fontStyleW700(
              fontSize: 18, fontColor: AppColors.redesignBrandDark),
        ),
        const SizedBox(height: 12),
        ...plans.map((plan) {
          final isSelected = selectedPlan?.id == plan.id;
          return GestureDetector(
            onTap: () => setState(() => selectedPlan = plan),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.redesignBrandRed.withValues(alpha: 0.08)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.redesignBrandRed
                      : AppColors.redesignSoftBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name ?? "Recording Storage",
                          style: AppFontStyle.fontStyleW700(
                              fontSize: 16,
                              fontColor: AppColors.redesignBrandDark),
                        ),
                        if (plan.description != null &&
                            plan.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            plan.description!,
                            style: AppFontStyle.fontStyleW500(
                                fontSize: 13,
                                fontColor: AppColors.redesignMutedText),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          "${plan.storageDays ?? 30} days storage",
                          style: AppFontStyle.fontStyleW500(
                              fontSize: 13,
                              fontColor: AppColors.redesignMutedText),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${(plan.price ?? 0).toStringAsFixed(2)}",
                        style: AppFontStyle.fontStyleW700(
                            fontSize: 20,
                            fontColor: AppColors.redesignBrandRed),
                      ),
                      Text(
                        "/${plan.billingCycle ?? "month"}",
                        style: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.redesignMutedText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        children: paymentMethods.map((method) {
          final isSelected = selectedPaymentMethod == method.id;
          return InkWell(
            onTap: () => setState(() => selectedPaymentMethod = method.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.redesignSoftBorder,
                    width: method != paymentMethods.last ? 1 : 0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: method.width ?? 50,
                    height: method.height ?? 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.redesignSoftBorder),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(method.image, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method.title,
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 14, fontColor: AppColors.redesignBrandDark),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? AppColors.redesignBrandRed
                        : AppColors.redesignMutedText,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.redesignBrandRed, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppFontStyle.fontStyleW500(
                  fontSize: 15, fontColor: AppColors.redesignBrandDark),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPurchaseAction() {
    final price = selectedPlan?.price;
    final cycle = selectedPlan?.billingCycle ?? "mo";
    final bool isRenewal = status == "grace_period" || status == "expired";
    final priceStr = price != null ? "\$${price.toStringAsFixed(2)}" : "—";
    final String btnText = hasActivePlan
        ? "Extend Plan ($priceStr/$cycle)"
        : isRenewal
            ? "Renew Subscription ($priceStr/$cycle)"
            : "Subscribe Now ($priceStr/$cycle)";

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redesignBrandRed,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: isPurchasing ? null : _purchasePlan,
        child: isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                btnText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildAppleActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AppleCheckoutActionButton(
                icon: Icons.restore_rounded,
                label: _isRestoringAppleSubscriptions ? 'Restoring' : 'Restore',
                showTrailingIcon: false,
                onTap: isPurchasing || _isRestoringAppleSubscriptions
                    ? null
                    : _restoreAppleSubscriptions,
                leading: _isRestoringAppleSubscriptions
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
              child: _AppleCheckoutActionButton(
                icon: Icons.tune_rounded,
                label: 'Manage',
                onTap: isPurchasing || _isRestoringAppleSubscriptions
                    ? null
                    : _openAppleManageSubscriptions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _AppleCheckoutActionButton(
          icon: Icons.description_outlined,
          label: 'Terms of Use (EULA)',
          onTap: isPurchasing || _isRestoringAppleSubscriptions
              ? null
              : () => launchUrl(
                  Uri.parse(
                      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                  mode: LaunchMode.externalApplication),
        ),
        const SizedBox(height: 8),
        _AppleCheckoutActionButton(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          onTap: isPurchasing || _isRestoringAppleSubscriptions
              ? null
              : () => launchUrl(
                  Uri.parse('https://notisboard.com/privacy-policy'),
                  mode: LaunchMode.externalApplication),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _AppleCheckoutActionButton extends StatelessWidget {
  const _AppleCheckoutActionButton({
    required this.icon,
    required this.label,
    this.onTap,
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

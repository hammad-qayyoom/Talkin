import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/common/recording_subscription/api/recording_subscription_api.dart';
import 'package:notisboard/ui/common/recording_subscription/model/recording_subscription_model.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/common_payment.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

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
  State<RecordingSubscriptionScreen> createState() => _RecordingSubscriptionScreenState();
}

class _RecordingSubscriptionScreenState extends State<RecordingSubscriptionScreen> {
  bool isLoading = true;
  bool isPurchasing = false;
  RecordingSubscriptionModel? subscription;
  List<RecordingStoragePlanModel> plans = [];
  RecordingStoragePlanModel? selectedPlan;
  String status = "none";
  bool hasActivePlan = false;

  int selectedPaymentMethod = -1;
  List<PaymentMethodOption> paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
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

  void _loadPaymentMethods() {
    paymentMethods.clear();
    selectedPaymentMethod = -1;
    final settings = Database.settingApiModel?.data;

    if (GetPlatform.isIOS) {
      final isEnabled = settings == null || settings.isAppleInAppPurchaseEnabled != false;
      if (isEnabled) {
        paymentMethods = [
          PaymentMethodOption(id: 3, title: EnumLocale.txtAppStore.name.tr, image: AppAsset.appStoreImage, width: 50, height: 26),
        ];
        selectedPaymentMethod = 3;
      }
      return;
    }

    if (settings == null) {
      paymentMethods = [
        PaymentMethodOption(id: 3, title: EnumLocale.txtGooglePlay.name.tr, image: AppAsset.googleIcon, width: 50, height: 26),
      ];
      selectedPaymentMethod = 3;
      return;
    }

    _addIfEnabled(1, EnumLocale.txtStripe.name.tr, AppAsset.stripe, 52, 26, android: settings.isStripeEnabled);
    _addIfEnabled(0, EnumLocale.txtRazorpay.name.tr, AppAsset.razorpay, 54, 28, android: settings.isRazorpayEnabled);
    _addIfEnabled(2, EnumLocale.txtFlutterwave.name.tr, AppAsset.flutterWave, 54, 28, android: settings.isFlutterwaveEnabled);
    _addIfEnabled(5, EnumLocale.txtPaystack.name.tr, AppAsset.payStackImage, 52, 28, android: settings.isPaystackAndroidEnabled);
    _addIfEnabled(4, EnumLocale.txtCashfree.name.tr, AppAsset.cashFreeImage, 54, 28, android: settings.isCashfreeAndroidEnabled);
    _addIfEnabled(6, EnumLocale.txtPaypal.name.tr, AppAsset.payPalImage, 52, 28, android: settings.isPaypalAndroidEnabled);
    _addIfEnabled(3, EnumLocale.txtGooglePlay.name.tr, AppAsset.googleIcon, 50, 26, android: settings.isGooglePlayEnabled);

    if (paymentMethods.isNotEmpty && selectedPaymentMethod == -1) {
      selectedPaymentMethod = paymentMethods.first.id;
    }
  }

  void _addIfEnabled(int id, String title, String image, double? w, double? h, {bool? android, bool? ios}) {
    final enabled = GetPlatform.isAndroid ? (android ?? false) : (ios ?? false);
    if (enabled) {
      paymentMethods.add(PaymentMethodOption(id: id, title: title, image: image, width: w, height: h));
    }
  }

  Future<void> _fetchStatus() async {
    final response = await RecordingSubscriptionApi.getSubscriptionStatus();
    if (response != null && response['status'] == true) {
      if (response['subscription'] != null) {
        subscription = RecordingSubscriptionModel.fromJson(response['subscription']);
      }
      status = response['subscriptionStatus'] ?? "none";
      hasActivePlan = response['hasSubscription'] ?? false;
    }
  }

  Future<void> _fetchPlans() async {
    final result = await RecordingSubscriptionApi.getPlans();
    if (result != null && result.isNotEmpty) {
      plans = result;
      selectedPlan = result.firstWhere((p) => p.isPopular, orElse: () => result.first);
    }
  }

  String _gatewayName(int methodId) {
    switch (methodId) {
      case 0: return "RazorPay";
      case 1: return "Stripe";
      case 2: return "Flutter Wave";
      case 3: return GetPlatform.isIOS ? "Apple" : "Google Play";
      case 4: return "cash free";
      case 5: return "pay stack";
      case 6: return "pay pal";
      default: return "system";
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

    setState(() => isPurchasing = true);

    try {
      final amount = (selectedPlan!.price ?? 0).toDouble();
      final planId = selectedPlan!.id ?? '';
      final gateway = _gatewayName(selectedPaymentMethod);

      // For In-App Purchase (Apple/Google Play), call API directly with product IDs
      if (selectedPaymentMethod == 3) {
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

      // For third-party gateways, process payment first
      switch (selectedPaymentMethod) {
        case 0:
          await razorPay(amount: amount, onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 1:
          await stripe(amount: amount, onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 2:
          await flutterWave(amount: amount, onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 4:
          await cashFree(amount: amount, onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 5:
          await payStack(amount: amount, onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        case 6:
          await payPal(amount: amount, onPaymentSuccess: () => _onPaymentSuccess(gateway, planId));
          break;
        default:
          Utils.showToast(context, "Invalid payment method.");
          setState(() => isPurchasing = false);
      }
    } catch (e) {
      Utils.showLog("Recording subscription payment error: $e");
      if (mounted) Utils.showToast(context, "Payment failed. Please try again.");
      if (mounted) setState(() => isPurchasing = false);
    }
  }

  Future<void> _onPaymentSuccess(String gateway, String planId) async {
    final res = await RecordingSubscriptionApi.purchasePlan(planId: planId, paymentGateway: gateway);
    if (mounted) {
      setState(() => isPurchasing = false);
      if (res != null) {
        Utils.showToast(context, "Subscription Activated Successfully!");
        _fetchData();
      } else {
        Utils.showToast(context, "Failed to activate subscription after payment.");
      }
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
          style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
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
              style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodSelector(),
          ],
          const SizedBox(height: 24),
          Text(
            "Plan Benefits",
            style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(Icons.cloud_done_rounded, "Secure Cloud Storage for all recordings"),
          _buildBenefitItem(Icons.history_rounded, "${selectedPlan?.storageDays ?? 30}-day access to replay consultation sessions"),
          _buildBenefitItem(Icons.privacy_tip_rounded, "Mutual consent enforced for privacy"),
          const SizedBox(height: 40),
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

      final days = subscription?.gracePeriodEndsAt?.difference(DateTime.now()).inDays ?? 0;
      subtitle = "Your recordings are locked. Renew within $days days to prevent deletion.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
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
                  style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.redesignBrandDark),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.redesignMutedText),
                ),
              ],
            ),
          )
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
          style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.redesignBrandDark),
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
                color: isSelected ? AppColors.redesignBrandRed.withValues(alpha: 0.08) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.redesignBrandRed : AppColors.redesignSoftBorder,
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
                          style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.redesignBrandDark),
                        ),
                        if (plan.description != null && plan.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            plan.description!,
                            style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignMutedText),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          "${plan.storageDays ?? 30} days storage",
                          style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.redesignMutedText),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${(plan.price ?? 0).toStringAsFixed(2)}",
                        style: AppFontStyle.fontStyleW700(fontSize: 20, fontColor: AppColors.redesignBrandRed),
                      ),
                      Text(
                        "/${plan.billingCycle ?? "month"}",
                        style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.redesignMutedText),
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
                      style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.redesignBrandDark),
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppColors.redesignBrandRed : AppColors.redesignMutedText,
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
              style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.redesignBrandDark),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: isPurchasing ? null : _purchasePlan,
        child: isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                btnText,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

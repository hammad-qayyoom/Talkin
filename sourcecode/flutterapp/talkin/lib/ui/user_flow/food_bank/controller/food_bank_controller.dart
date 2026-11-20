import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank/api/food_bank_api.dart';
import 'package:notisboard/ui/user_flow/food_bank/model/food_bank_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/utils/common_payment.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class PaymentMethodOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  PaymentMethodOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class FoodBankController extends GetxController {
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final config = Rxn<FoodBankConfig>();

  final selectedAmount = 25.0.obs;
  final isCustomAmount = false.obs;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final customAmountController = TextEditingController();
  final messageController = TextEditingController();

  // Payment gateways
  final availableGateways = <PaymentMethodOption>[].obs;
  final selectedGatewayId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _prefillDonorInfo();
    _refreshSettingsAndGateways();
    loadConfig();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    customAmountController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void _prefillDonorInfo() {
    final user = Database.fetchLoginUserProfileModel?.user;
    if (user != null) {
      nameController.text = (user.fullName ?? user.nickName)?.trim() ?? '';
      emailController.text = user.email?.trim() ?? '';
      phoneController.text = user.phoneNumber?.trim() ?? '';
    } else {
      final cachedEmail = Database.localStorage.read('last_food_bank_donor_email') ??
          Database.localStorage.read('last_donor_email') ??
          Database.localStorage.read('last_ticket_email');
      if (cachedEmail is String) {
        emailController.text = cachedEmail;
      }
    }
  }

  Future<void> _refreshSettingsAndGateways() async {
    try {
      final fresh = await SettingApi.callApi();
      if (fresh?.data != null) {
        Database.settingApiModel = fresh;
      }
    } catch (e) {
      Utils.showLog('FoodBankController: refresh settings failed: $e');
    }
    _loadAvailableGateways();
  }

  bool _isGatewayEnabled({bool? android, bool? ios, bool? fallback}) {
    if (Platform.isAndroid && android != null) return android;
    if (Platform.isIOS && ios != null) return ios;
    return fallback ?? false;
  }

  void _loadAvailableGateways() {
    final s = Database.settingApiModel?.data;
    final list = <PaymentMethodOption>[];

    // PayPal
    if (_isGatewayEnabled(
      android: s?.isPaypalAndroidEnabled,
      ios: s?.isPaypalIosEnabled,
    )) {
      list.add(PaymentMethodOption(
        id: 'paypal',
        title: 'PayPal Checkout',
        subtitle: 'Secure international giving via PayPal',
        icon: Icons.payment_rounded,
      ));
    }

    // Stripe
    if (_isGatewayEnabled(
      android: s?.isStripeEnabled,
      ios: s?.isStripeIosEnabled,
      fallback: s?.isStripeEnabled,
    )) {
      list.add(PaymentMethodOption(
        id: 'stripe',
        title: 'Credit / Debit Card',
        subtitle: 'Encrypted payment via Stripe (Visa, MC, Amex)',
        icon: Icons.credit_card_rounded,
      ));
    }

    // Razorpay
    if (_isGatewayEnabled(
      android: s?.isRazorpayEnabled,
      ios: s?.isRazorpayIosEnabled,
      fallback: s?.isRazorpayEnabled,
    )) {
      list.add(PaymentMethodOption(
        id: 'razorpay',
        title: 'Razorpay',
        subtitle: 'UPI, Net Banking, Cards & Wallets',
        icon: Icons.account_balance_wallet_outlined,
      ));
    }

    // Flutterwave
    if (_isGatewayEnabled(
      android: s?.isFlutterwaveEnabled,
      ios: s?.isFlutterwaveIosEnabled,
      fallback: s?.isFlutterwaveEnabled,
    )) {
      list.add(PaymentMethodOption(
        id: 'flutterwave',
        title: 'Flutterwave',
        subtitle: 'Pay via African & International Rail',
        icon: Icons.account_balance_rounded,
      ));
    }

    // Paystack
    if (_isGatewayEnabled(
      android: s?.isPaystackAndroidEnabled,
      ios: s?.isPaystackIosEnabled,
    )) {
      list.add(PaymentMethodOption(
        id: 'paystack',
        title: 'Paystack',
        subtitle: 'Modern African and International Gateway',
        icon: Icons.payments_outlined,
      ));
    }

    // Cashfree
    if (_isGatewayEnabled(
      android: s?.isCashfreeAndroidEnabled,
      ios: s?.isCashfreeIosEnabled,
    )) {
      list.add(PaymentMethodOption(
        id: 'cashfree',
        title: 'Cashfree',
        subtitle: 'Cards, Netbanking & Wallets via Cashfree',
        icon: Icons.payment_rounded,
      ));
    }

    // Star Coin Wallet (Always available as extra internal option)
    final coins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
    list.add(PaymentMethodOption(
      id: 'wallet',
      title: 'Star Coin Wallet',
      subtitle: 'Available: $coins Coins (1 Coin = CA\$1.00)',
      icon: Icons.stars_rounded,
    ));

    availableGateways.assignAll(list);
    if (list.isNotEmpty) {
      if (!list.any((g) => g.id == selectedGatewayId.value)) {
        selectedGatewayId.value = list.first.id;
      }
    }
  }

  Future<void> loadConfig() async {
    isLoading.value = true;
    final cfg = await FoodBankApi.fetchConfig();
    config.value = cfg;

    if (cfg != null && cfg.amounts.isNotEmpty) {
      final def = cfg.amounts.firstWhere(
        (a) => a.amount == 25,
        orElse: () => cfg.amounts.first,
      );
      selectedAmount.value = def.amount;
    }

    isLoading.value = false;
  }

  void selectPredefinedAmount(double amt) {
    isCustomAmount.value = false;
    selectedAmount.value = amt;
    customAmountController.clear();
  }

  void enableCustomAmountMode() {
    isCustomAmount.value = true;
    final parsed = double.tryParse(customAmountController.text.trim());
    if (parsed != null && parsed > 0) {
      selectedAmount.value = parsed;
    }
  }

  void onCustomAmountChanged(String val) {
    final parsed = double.tryParse(val.trim());
    if (parsed != null && parsed > 0) {
      selectedAmount.value = parsed;
    }
  }

  Future<void> processDonation() async {
    final cfg = config.value;
    if (cfg == null) {
      Utils.showToast(Get.context!, 'Failed to load configuration. Please try again.');
      return;
    }

    if (!cfg.isEnabled) {
      Utils.showToast(Get.context!, 'Food Bank donations are currently paused by the administrator.');
      return;
    }

    if (!cfg.enableMobileApp) {
      Utils.showToast(Get.context!, 'Food Bank donations via mobile app are currently disabled.');
      return;
    }

    final donorName = nameController.text.trim();
    final donorEmail = emailController.text.trim();

    if (donorName.isEmpty) {
      Utils.showToast(Get.context!, 'Please enter your full name');
      return;
    }

    if (donorEmail.isEmpty || !donorEmail.contains('@')) {
      Utils.showToast(Get.context!, 'Please enter a valid email address');
      return;
    }

    final amt = selectedAmount.value;
    if (amt < cfg.minAmount) {
      Utils.showToast(Get.context!, 'Minimum donation amount is CA\$${cfg.minAmount.toStringAsFixed(2)}');
      return;
    }

    if (amt > cfg.maxAmount) {
      Utils.showToast(Get.context!, 'Maximum donation amount is CA\$${cfg.maxAmount.toStringAsFixed(2)}');
      return;
    }

    if (selectedGatewayId.value.isEmpty) {
      Utils.showToast(Get.context!, 'Please choose a payment method');
      return;
    }

    final gateway = selectedGatewayId.value;

    try {
      if (gateway == 'paypal') {
        isSubmitting.value = true;
        await payPal(
          amount: amt,
          onPaymentSuccess: () async {
            await _recordCompletedDonation(
              paymentMethod: 'PayPal Checkout',
              paymentId: 'paypal_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
        isSubmitting.value = false;
      } else if (gateway == 'stripe') {
        isSubmitting.value = true;
        await stripe(
          amount: amt,
          onPaymentSuccess: () async {
            await _recordCompletedDonation(
              paymentMethod: 'Credit / Debit Card (Stripe)',
              paymentId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
        isSubmitting.value = false;
      } else if (gateway == 'razorpay') {
        isSubmitting.value = true;
        await razorPay(
          amount: amt,
          onPaymentSuccess: () async {
            await _recordCompletedDonation(
              paymentMethod: 'Razorpay',
              paymentId: 'rzp_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
        isSubmitting.value = false;
      } else if (gateway == 'flutterwave') {
        isSubmitting.value = true;
        await flutterWave(
          amount: amt,
          onPaymentSuccess: () async {
            await _recordCompletedDonation(
              paymentMethod: 'Flutterwave',
              paymentId: 'flw_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
        isSubmitting.value = false;
      } else if (gateway == 'paystack') {
        isSubmitting.value = true;
        await payStack(
          amount: amt,
          onPaymentSuccess: () async {
            await _recordCompletedDonation(
              paymentMethod: 'Paystack',
              paymentId: 'pstk_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
        isSubmitting.value = false;
      } else if (gateway == 'cashfree') {
        isSubmitting.value = true;
        await cashFree(
          amount: amt,
          onPaymentSuccess: () async {
            await _recordCompletedDonation(
              paymentMethod: 'Cashfree',
              paymentId: 'cf_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
        isSubmitting.value = false;
      } else if (gateway == 'wallet') {
        final userCoins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
        if (userCoins < amt) {
          Utils.showToast(
            Get.context!,
            'Insufficient Star Coins ($userCoins available, ${amt.toStringAsFixed(0)} required). Please top-up or select another payment gateway.',
          );
          return;
        }

        isSubmitting.value = true;
        await _recordCompletedDonation(
          paymentMethod: 'Star Coin Wallet',
          paymentId: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        );
        isSubmitting.value = false;
      } else {
        Utils.showToast(Get.context!, 'Unsupported payment method selected');
      }
    } catch (e) {
      isSubmitting.value = false;
      Utils.showLog('processDonation error: $e');
      Utils.showToast(Get.context!, 'Payment processing failed. Please try again.');
    }
  }

  Future<void> _recordCompletedDonation({
    required String paymentMethod,
    required String paymentId,
  }) async {
    final cfg = config.value;
    final donorName = nameController.text.trim();
    final donorEmail = emailController.text.trim();
    final amt = selectedAmount.value;

    final result = await FoodBankApi.submitDonation(
      donorName: donorName,
      donorEmail: donorEmail,
      donorPhone: phoneController.text.trim(),
      amount: amt,
      currency: cfg?.currency ?? 'CAD',
      paymentGateway: paymentMethod,
      paymentTransactionId: paymentId,
      message: messageController.text.trim(),
    );

    if (result != null) {
      Database.localStorage.write('last_food_bank_donor_email', donorEmail);

      // Decrement star coins locally if wallet was used
      if (selectedGatewayId.value == 'wallet') {
        final user = Database.fetchLoginUserProfileModel?.user;
        if (user != null) {
          final currentCoins = user.coins ?? 0;
          user.coins = (currentCoins - amt.toInt()).clamp(0, 9999999);
        }
      }

      Get.offNamed(AppRoutes.foodBankSuccessScreen, arguments: result);
    } else {
      Utils.showToast(Get.context!, 'Donation confirmation failed. Please contact support.');
    }
  }
}

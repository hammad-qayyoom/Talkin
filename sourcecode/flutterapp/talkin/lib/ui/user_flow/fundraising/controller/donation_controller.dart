import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/api/fundraising_api.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/utils/common_payment.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class DonationPaymentMethod {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  DonationPaymentMethod({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class DonationController extends GetxController {
  // Destination
  final donationType = 'GENERAL_FOUNDATION'.obs; // 'GENERAL_FOUNDATION', 'CAMPAIGN', 'PROGRAM'
  final selectedCampaign = Rxn<FundraisingCampaign>();
  final selectedProgram = Rxn<FoundationProgram>();

  // Frequency: 'one-time' or 'monthly'
  final frequency = 'one-time'.obs;

  // Preset amounts in CAD
  final presetAmounts = [25.0, 50.0, 100.0, 250.0, 500.0, 1000.0];
  final selectedAmount = 50.0.obs;
  final isCustomAmount = false.obs;
  final customAmountController = TextEditingController();

  // Anonymous Giving
  final isAnonymous = false.obs;

  // Donor Details
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final messageController = TextEditingController();

  // Gateways
  final availableGateways = <DonationPaymentMethod>[].obs;
  final selectedGatewayKey = ''.obs;

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _handleIncomingArguments();
    _prefillUserInfo();
    _loadLiveSettingsAndConfigureGateways();
  }

  @override
  void onClose() {
    customAmountController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void _handleIncomingArguments() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['campaign'] is FundraisingCampaign) {
        selectedCampaign.value = args['campaign'] as FundraisingCampaign;
        donationType.value = 'CAMPAIGN';
        if (args['initialAmount'] != null) {
          final amt = (args['initialAmount'] as num).toDouble();
          setAmount(amt);
        }
      } else if (args['program'] is FoundationProgram) {
        selectedProgram.value = args['program'] as FoundationProgram;
        donationType.value = 'PROGRAM';
        if (args['initialAmount'] != null) {
          final amt = (args['initialAmount'] as num).toDouble();
          setAmount(amt);
        }
      }
    } else if (args is FundraisingCampaign) {
      selectedCampaign.value = args;
      donationType.value = 'CAMPAIGN';
    } else if (args is FoundationProgram) {
      selectedProgram.value = args;
      donationType.value = 'PROGRAM';
    }
  }

  void _prefillUserInfo() {
    final user = Database.fetchLoginUserProfileModel?.user;
    if (user != null) {
      final parts = (user.fullName ?? '').trim().split(' ');
      if (parts.isNotEmpty) {
        firstNameController.text = parts.first;
        if (parts.length > 1) {
          lastNameController.text = parts.sublist(1).join(' ');
        }
      }
      if (user.email != null && user.email!.isNotEmpty) {
        emailController.text = user.email!;
      }
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        phoneController.text = user.phoneNumber!;
      }
    }
  }

  Future<void> _loadLiveSettingsAndConfigureGateways() async {
    _configureGateways();
    try {
      final fresh = await SettingApi.callApi();
      if (fresh != null) {
        Database.settingApiModel = fresh;
        _configureGateways();
      }
    } catch (e) {
      Utils.showLog('DonationController: settings refresh failed: $e');
    }
  }

  bool _isGatewayEnabled({bool? android, bool? ios, bool? fallback}) {
    if (Platform.isAndroid && android != null) return android;
    if (Platform.isIOS && ios != null) return ios;
    return fallback ?? false;
  }

  void _configureGateways() {
    final s = Database.settingApiModel?.data;
    final list = <DonationPaymentMethod>[];

    // 1. PayPal
    if (_isGatewayEnabled(
      android: s?.isPaypalAndroidEnabled,
      ios: s?.isPaypalIosEnabled,
    )) {
      list.add(DonationPaymentMethod(
        key: 'paypal',
        title: 'PayPal',
        subtitle: 'Donate safely via PayPal balance or debit/credit card',
        icon: Icons.account_balance_wallet_rounded,
      ));
    }

    // 2. Stripe (Cards)
    if (_isGatewayEnabled(
      android: s?.isStripeEnabled,
      ios: s?.isStripeIosEnabled,
      fallback: s?.isStripeEnabled,
    )) {
      list.add(DonationPaymentMethod(
        key: 'stripe',
        title: 'Credit / Debit Card',
        subtitle: 'Direct secure card payment via Stripe',
        icon: Icons.credit_card_rounded,
      ));
    }

    // 3. Razorpay
    if (_isGatewayEnabled(
      android: s?.isRazorpayEnabled,
      ios: s?.isRazorpayIosEnabled,
      fallback: s?.isRazorpayEnabled,
    )) {
      list.add(DonationPaymentMethod(
        key: 'razorpay',
        title: 'Razorpay',
        subtitle: 'UPI, Net Banking, Cards & Wallets',
        icon: Icons.account_balance_wallet_rounded,
      ));
    }

    // 4. Flutterwave
    if (_isGatewayEnabled(
      android: s?.isFlutterwaveEnabled,
      ios: s?.isFlutterwaveIosEnabled,
      fallback: s?.isFlutterwaveEnabled,
    )) {
      list.add(DonationPaymentMethod(
        key: 'flutterwave',
        title: 'Flutterwave',
        subtitle: 'Cards, Bank Transfer & Mobile Money',
        icon: Icons.payments_rounded,
      ));
    }

    // 5. Paystack
    if (_isGatewayEnabled(
      android: s?.isPaystackAndroidEnabled,
      ios: s?.isPaystackIosEnabled,
    )) {
      list.add(DonationPaymentMethod(
        key: 'paystack',
        title: 'Paystack',
        subtitle: 'Fast and secure African payment channels',
        icon: Icons.account_balance_rounded,
      ));
    }

    // 6. Cashfree
    if (_isGatewayEnabled(
      android: s?.isCashfreeAndroidEnabled,
      ios: s?.isCashfreeIosEnabled,
    )) {
      list.add(DonationPaymentMethod(
        key: 'cashfree',
        title: 'Cashfree',
        subtitle: 'Cards, Netbanking & Wallets via Cashfree',
        icon: Icons.payment_rounded,
      ));
    }

    // 7. Star Coin Wallet (App Internal Coin Currency)
    final userCoins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
    list.add(DonationPaymentMethod(
      key: 'wallet',
      title: 'Star Coin Wallet',
      subtitle: 'Available: $userCoins Coins (1 Coin = CA\$1.00)',
      icon: Icons.stars_rounded,
    ));

    availableGateways.assignAll(list);

    if (list.isNotEmpty && !list.any((g) => g.key == selectedGatewayKey.value)) {
      selectedGatewayKey.value = list.first.key;
    }
  }

  void setAmount(double amount) {
    selectedAmount.value = amount;
    isCustomAmount.value = false;
    customAmountController.clear();
  }

  void setCustomAmount(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed != null && parsed > 0) {
      selectedAmount.value = parsed;
      isCustomAmount.value = true;
    }
  }

  void selectGateway(String key) {
    selectedGatewayKey.value = key;
  }

  bool _validate() {
    final ctx = Get.context;
    if (selectedAmount.value <= 0) {
      if (ctx != null) Utils.showToast(ctx, 'Please select or enter a valid donation amount.');
      return false;
    }
    if (firstNameController.text.trim().isEmpty) {
      if (ctx != null) Utils.showToast(ctx, 'Please enter your first name.');
      return false;
    }
    if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
      if (ctx != null) Utils.showToast(ctx, 'Please enter a valid email address.');
      return false;
    }
    if (selectedGatewayKey.value.isEmpty) {
      if (ctx != null) Utils.showToast(ctx, 'Please select a payment method.');
      return false;
    }
    return true;
  }

  Future<void> submitDonation() async {
    if (!_validate()) return;

    final amt = selectedAmount.value;
    final gateway = selectedGatewayKey.value;

    isSubmitting.value = true;

    try {
      if (gateway == 'paypal') {
        await payPal(
          amount: amt,
          onPaymentSuccess: () async {
            await _finalizeDonationRecord(
              paymentMethod: 'PAYPAL',
              paymentId: 'paypal_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'stripe') {
        await stripe(
          amount: amt,
          onPaymentSuccess: () async {
            await _finalizeDonationRecord(
              paymentMethod: 'STRIPE',
              paymentId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'razorpay') {
        await razorPay(
          amount: amt,
          onPaymentSuccess: () async {
            await _finalizeDonationRecord(
              paymentMethod: 'RAZORPAY',
              paymentId: 'rzp_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'flutterwave') {
        await flutterWave(
          amount: amt,
          onPaymentSuccess: () async {
            await _finalizeDonationRecord(
              paymentMethod: 'FLUTTERWAVE',
              paymentId: 'flw_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'paystack') {
        await payStack(
          amount: amt,
          onPaymentSuccess: () async {
            await _finalizeDonationRecord(
              paymentMethod: 'PAYSTACK',
              paymentId: 'pstk_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'cashfree') {
        await cashFree(
          amount: amt,
          onPaymentSuccess: () async {
            await _finalizeDonationRecord(
              paymentMethod: 'CASHFREE',
              paymentId: 'cf_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'wallet') {
        final currentCoins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
        if (currentCoins < amt) {
          final ctx = Get.context;
          if (ctx != null) {
            Utils.showToast(
              ctx,
              'Insufficient Star Coins balance. You have $currentCoins Coins, required $amt Coins.',
            );
          }
          isSubmitting.value = false;
          return;
        }

        // Deduct local coins
        final updatedUser = Database.fetchLoginUserProfileModel?.user;
        if (updatedUser != null) {
          updatedUser.coins = (currentCoins - amt.toInt());
        }

        await _finalizeDonationRecord(
          paymentMethod: 'STAR_COIN_WALLET',
          paymentId: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } catch (e) {
      Utils.showLog('Donation payment error: $e');
      Utils.showToast(Get.context, 'Payment failed: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _finalizeDonationRecord({
    required String paymentMethod,
    required String paymentId,
  }) async {
    final isMonthly = frequency.value == 'monthly';
    final donorEmail = emailController.text.trim();
    if (donorEmail.isNotEmpty) {
      Database.localStorage.write('last_donor_email', donorEmail);
    }

    final payload = <String, dynamic>{
      'amount': selectedAmount.value,
      'currency': selectedCampaign.value?.currency ?? 'CAD',
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
      'message': messageController.text.trim().isNotEmpty ? messageController.text.trim() : null,
      'isAnonymous': isAnonymous.value,
      'isRecurring': isMonthly,
      'recurringInterval': isMonthly ? 'monthly' : null,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'donationType': donationType.value,
    };

    if (donationType.value == 'CAMPAIGN' && selectedCampaign.value != null) {
      payload['campaignId'] = selectedCampaign.value!.id;
    } else if (donationType.value == 'PROGRAM' && selectedProgram.value != null) {
      payload['programId'] = selectedProgram.value!.id;
    }

    final record = await FundraisingApi.createDonation(payload);

    final resolvedRecord = record ??
        DonationRecord(
          id: 'don_${DateTime.now().millisecondsSinceEpoch}',
          receiptNumber: 'DON-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          amount: selectedAmount.value,
          currency: selectedCampaign.value?.currency ?? 'CAD',
          paymentMethod: paymentMethod,
          status: 'COMPLETED',
          isAnonymous: isAnonymous.value,
          isRecurring: isMonthly,
          message: messageController.text.trim(),
          donationType: donationType.value,
          causeTitle: donationType.value == 'CAMPAIGN'
              ? selectedCampaign.value?.title
              : donationType.value == 'PROGRAM'
                  ? selectedProgram.value?.title
                  : 'General Foundation Fund',
          createdAt: DateTime.now().toIso8601String(),
        );

    Get.offNamed(
      AppRoutes.donationSuccessScreen,
      arguments: resolvedRecord,
    );
  }
}

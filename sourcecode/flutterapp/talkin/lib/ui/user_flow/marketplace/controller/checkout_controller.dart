import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/api/marketplace_api.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/utils/common_payment.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class PaymentMethodOption {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  PaymentMethodOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class CheckoutController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final apartmentController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController(text: 'Canada');
  final notesController = TextEditingController();

  final selectedPaymentMethod = ''.obs;
  final isSubmitting = false.obs;

  final RxList<PaymentMethodOption> paymentMethods = <PaymentMethodOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    _populateUserInfo();
    _loadLiveSettingsAndConfigureGateways();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    streetController.dispose();
    apartmentController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _populateUserInfo() {
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
    // 1. Initial configuration from cached settings
    _configurePaymentGateways();

    // 2. Fetch fresh live settings from App Admin Panel
    try {
      final fresh = await SettingApi.callApi();
      if (fresh != null) {
        Database.settingApiModel = fresh;
        _configurePaymentGateways();
      }
    } catch (e) {
      Utils.showLog('Error refreshing live settings in checkout: $e');
    }
  }

  bool _isGatewayEnabled({
    bool? android,
    bool? ios,
    bool? fallback,
  }) {
    if (Platform.isAndroid && android != null) {
      return android;
    }
    if (Platform.isIOS && ios != null) {
      return ios;
    }
    return fallback ?? false;
  }

  void _configurePaymentGateways() {
    final s = Database.settingApiModel?.data;
    final list = <PaymentMethodOption>[];

    // 1. PayPal (Active in App Admin Panel)
    if (_isGatewayEnabled(
      android: s?.isPaypalAndroidEnabled,
      ios: s?.isPaypalIosEnabled,
    )) {
      list.add(PaymentMethodOption(
        key: 'paypal',
        title: 'PayPal',
        subtitle: 'Pay safely with your PayPal account or Card',
        icon: Icons.account_balance_wallet_rounded,
      ));
    }

    // 2. Stripe (Credit / Debit Card)
    if (_isGatewayEnabled(
      android: s?.isStripeEnabled,
      ios: s?.isStripeIosEnabled,
      fallback: s?.isStripeEnabled,
    )) {
      list.add(PaymentMethodOption(
        key: 'stripe',
        title: 'Credit / Debit Card',
        subtitle: 'Secure payment via Stripe (Visa, MC, Amex)',
        icon: Icons.credit_card_rounded,
      ));
    }

    // 3. Razorpay
    if (_isGatewayEnabled(
      android: s?.isRazorpayEnabled,
      ios: s?.isRazorpayIosEnabled,
      fallback: s?.isRazorpayEnabled,
    )) {
      list.add(PaymentMethodOption(
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
      list.add(PaymentMethodOption(
        key: 'flutterwave',
        title: 'Flutterwave',
        subtitle: 'Pay via Cards, Bank Transfer & Mobile Money',
        icon: Icons.payments_rounded,
      ));
    }

    // 5. Paystack
    if (_isGatewayEnabled(
      android: s?.isPaystackAndroidEnabled,
      ios: s?.isPaystackIosEnabled,
    )) {
      list.add(PaymentMethodOption(
        key: 'paystack',
        title: 'Paystack',
        subtitle: 'Modern African & International Payments',
        icon: Icons.account_balance_rounded,
      ));
    }

    // 6. Cashfree
    if (_isGatewayEnabled(
      android: s?.isCashfreeAndroidEnabled,
      ios: s?.isCashfreeIosEnabled,
    )) {
      list.add(PaymentMethodOption(
        key: 'cashfree',
        title: 'Cashfree',
        subtitle: 'Cards, Netbanking & Wallets via Cashfree',
        icon: Icons.payment_rounded,
      ));
    }

    // 7. Star Coin Wallet (App Coin Wallet)
    final userCoins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
    list.add(PaymentMethodOption(
      key: 'wallet',
      title: 'Star Coin Wallet',
      subtitle: 'Available: $userCoins Coins (1 Coin = CA\$1.00)',
      icon: Icons.stars_rounded,
    ));

    paymentMethods.assignAll(list);
    if (list.isNotEmpty) {
      if (!list.any((m) => m.key == selectedPaymentMethod.value)) {
        selectedPaymentMethod.value = list.first.key;
      }
    }
  }

  bool _validateInputs() {
    final ctx = Get.context;
    if (firstNameController.text.trim().isEmpty) {
      if (ctx != null) Utils.showToast(ctx, 'Please enter your first name.');
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      if (ctx != null) Utils.showToast(ctx, 'Please enter your last name.');
      return false;
    }
    final email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      if (ctx != null) Utils.showToast(ctx, 'Please enter a valid delivery email.');
      return false;
    }
    if (streetController.text.trim().isEmpty) {
      if (ctx != null) Utils.showToast(ctx, 'Please enter your shipping street address.');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      if (ctx != null) Utils.showToast(ctx, 'Please enter your city.');
      return false;
    }
    return true;
  }

  Future<void> submitOrder() async {
    if (!_validateInputs()) return;

    final cart = Get.find<MarketplaceCartController>();
    if (cart.cartItems.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) Utils.showToast(ctx, 'Your shopping cart is empty.');
      return;
    }

    final total = cart.totalAmount;
    final method = selectedPaymentMethod.value;

    isSubmitting.value = true;

    try {
      if (method == 'paypal') {
        await payPal(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeOrderPlacement(
              paymentMethod: 'PayPal',
              paymentStatus: 'PAID',
              paymentId: 'paypal_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (method == 'stripe') {
        await stripe(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeOrderPlacement(
              paymentMethod: 'Credit / Debit Card (Stripe)',
              paymentStatus: 'PAID',
              paymentId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (method == 'razorpay') {
        await razorPay(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeOrderPlacement(
              paymentMethod: 'Razorpay',
              paymentStatus: 'PAID',
              paymentId: 'rzp_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (method == 'flutterwave') {
        await flutterWave(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeOrderPlacement(
              paymentMethod: 'Flutterwave',
              paymentStatus: 'PAID',
              paymentId: 'flw_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (method == 'paystack') {
        await payStack(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeOrderPlacement(
              paymentMethod: 'Paystack',
              paymentStatus: 'PAID',
              paymentId: 'pstk_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (method == 'cashfree') {
        await cashFree(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeOrderPlacement(
              paymentMethod: 'Cashfree',
              paymentStatus: 'PAID',
              paymentId: 'cf_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (method == 'wallet') {
        final userCoins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
        if (userCoins < total) {
          final ctx = Get.context;
          if (ctx != null) {
            Utils.showToast(
              ctx,
              'Insufficient coin balance ($userCoins available, ${total.toStringAsFixed(2)} required).',
            );
          }
          isSubmitting.value = false;
          return;
        }
        await _finalizeOrderPlacement(
          paymentMethod: 'wallet',
          paymentStatus: 'PAID',
          paymentId: 'coin_wallet_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        // Fallback
        await _finalizeOrderPlacement(
          paymentMethod: method.isNotEmpty ? method : 'online',
          paymentStatus: 'PAID',
          paymentId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } catch (e) {
      Utils.showLog('Order placement error: $e');
      final ctx = Get.context;
      if (ctx != null) {
        // ignore: use_build_context_synchronously
        Utils.showToast(ctx, 'Payment / order creation failed: $e');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _finalizeOrderPlacement({
    required String paymentMethod,
    required String paymentStatus,
    required String paymentId,
  }) async {
    final cart = Get.find<MarketplaceCartController>();

    final payload = <String, dynamic>{
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim().toLowerCase(),
      'phone': phoneController.text.trim(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'paymentGateway': selectedPaymentMethod.value,
      'source': 'NOTISBOARD_MOBILE_APP',
      'notes': notesController.text.trim(),
      'shippingAddress': {
        'street': streetController.text.trim(),
        'apartment': apartmentController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'postalCode': postalCodeController.text.trim(),
        'country': countryController.text.trim(),
      },
      'billingAddress': {
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'country': countryController.text.trim(),
      },
      'items': cart.cartItems.map((item) => item.toOrderItemPayload()).toList(),
    };

    final result = await MarketplaceApi.createOrder(payload);

    if (result['success'] == true) {
      final emailStr = emailController.text.trim();
      if (emailStr.isNotEmpty) {
        Database.localStorage.write('last_order_email', emailStr);
      }
      final MarketplaceOrder? placedOrder = result['order'] is MarketplaceOrder
          ? result['order'] as MarketplaceOrder
          : null;

      cart.clearCart();

      Get.offNamed(
        AppRoutes.marketplaceOrderSuccessScreen,
        arguments: {
          'order': placedOrder,
          'orderNumber': placedOrder?.orderNumber ??
              result['raw']?['orderNumber'] ??
              'ORD-${DateTime.now().millisecondsSinceEpoch}',
          'total': cart.totalAmount,
          'email': emailController.text.trim(),
          'paymentMethod': paymentMethod,
        },
      );
    } else {
      final error = result['error'] ?? 'Failed to synchronize order with foundation.';
      final ctx = Get.context;
      if (ctx != null) {
        // ignore: use_build_context_synchronously
        Utils.showToast(ctx, error.toString());
      }
    }
  }
}

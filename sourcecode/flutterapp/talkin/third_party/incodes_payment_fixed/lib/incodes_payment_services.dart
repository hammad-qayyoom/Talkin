import 'package:flutter/material.dart';
import 'package:incodes_payment/methods/cash_free_payment/cash_free_service.dart';
import 'package:incodes_payment/methods/flutter_wave/flutter_wave_service.dart';
import 'package:incodes_payment/methods/in_app_purchase/in_app_purchase_helper.dart';
import 'package:incodes_payment/methods/in_app_purchase/purchase_request.dart';
import 'package:incodes_payment/methods/pay_stack/pay_stack_payment.dart';
import 'package:incodes_payment/methods/paypal/paypal_service.dart';
import 'package:incodes_payment/methods/razor_pay/razorpay_service.dart';
import 'package:incodes_payment/methods/stripe/stripe_service.dart';

class IncodesPaymentServices {
  /// Razorpay Payment
  static razorPayPayment({
    required String contactNumber,
    required String emailId,
    required String razorpayKey,
    required double amount,
    required String appName,
    String? description,
    String? colorCode,
    required String currency,
    String paymentGatewayName = "Razorpay",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
    Function()? onExternalWallet,
  }) {
    return RazorpayServices().openRazorpay(
      contactNumber: contactNumber,
      emailId: emailId,
      razorpayKey: razorpayKey,
      amount: amount,
      appName: appName,
      currency: currency,
      colorCode: colorCode,
      description: description,
      paymentGatewayName: paymentGatewayName,
      onShowToast: onShowToast,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: onPaymentFailure,
      onExternalWallet: onExternalWallet,
    );
  }

  /// Stripe Payment
  static Future<void> stripePayment({
    required int amount,
    required String currency,
    required String secretKey,
    required String publishableKey,
    required String merchantCountryCode,
    required String merchantDisplayName,
    String paymentGatewayName = "Stripe",
    String? description,
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
    bool isTest = true,
  }) async {
    final stripe = StripeService();
    await stripe.init(isTest: isTest, publishableKey: publishableKey);

    return stripe.stripePay(
      amount: amount,
      currency: currency,
      description: description,
      paymentGatewayName: paymentGatewayName,
      onShowToast: onShowToast,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: onPaymentFailure,
      secretKey: secretKey,
      merchantDisplayName: merchantDisplayName,
      merchantCountryCode: merchantCountryCode,
    );
  }

  /// PayPal Payment
  static Future<void> paypalPayment({
    required BuildContext context,
    required String clientId,
    required String secretKey,
    required List<Map<String, dynamic>> transactions,
    bool sandboxMode = true,
    String? note,
    String paymentGatewayName = "PayPal",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
    Function()? onPaymentCancel,
  }) async {
    return PaypalService().openPaypal(
      context: context,
      clientId: clientId,
      secretKey: secretKey,
      transactions: transactions,
      sandboxMode: sandboxMode,
      note: note,
      paymentGatewayName: paymentGatewayName,
      onShowToast: onShowToast,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: onPaymentFailure,
      onPaymentCancel: onPaymentCancel,
    );
  }

  /// PayStack Payment
  static Future<void> payStackPayment({
    required BuildContext context,
    required String secretKey,
    required String customerEmail,
    required int amount,
    String currency = "NGN",
    String? callbackUrl,
    String paymentGatewayName = "Paystack",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) {
    return PaystackService.openPaystack(
      context: context,
      secretKey: secretKey,
      customerEmail: customerEmail,
      amount: amount,
      currency: currency,
      callbackUrl: callbackUrl,
      paymentGatewayName: paymentGatewayName,
      onShowToast: onShowToast,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: onPaymentFailure,
    );
  }

  /// FlutterWave Payment
  static Future<void> flutterWavePayment({
    required BuildContext context,
    required String publicKey,
    required String customerName,
    required String customerEmail,
    required String amount,
    String currency = "NGN",
    String? callbackUrl,
    String paymentGatewayName = "Flutterwave",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) {
    return FlutterWaveService.openFlutterWave(
      context: context,
      publicKey: publicKey,
      currency: currency,
      amount: amount,
      customerName: customerName,
      customerEmail: customerEmail,
    );
  }

  /// CashFree Payment
  static Future<void> cashFreePayment({
    required BuildContext context,
    required String clientId,
    required String clientSecret,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String currency = "INR",
    String paymentGatewayName = "Cashfree",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) {
    return CashfreeService.openCashfree(
      context: context,
      clientId: clientId,
      clientSecret: clientSecret,
      amount: amount,
      currency: currency,
      paymentGatewayName: paymentGatewayName,
      onShowToast: onShowToast,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: onPaymentFailure,
      customerEmail: customerEmail,
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }

  /// In-App Purchase Payment
  static Future<void> inAppPurchasePayment({
    required String userId,
    required List<String> productIds,
    required double amount,
    String paymentType = "In App Purchase",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) async {
    final request = PurchaseRequest(
      userId: userId,
      productIds: productIds,
      amount: amount,
      paymentType: paymentType,
    );

    InAppPurchaseHelper().init(request);
    await InAppPurchaseHelper().debugProductLoading();
    InAppPurchaseHelper().initStoreInfo();
    final helper = InAppPurchaseHelper();
    await helper.initStoreInfo();

    if (helper.getAvailableProducts().isNotEmpty) {
      final productDetail = helper.getProductDetail(productIds.first);
      if (productDetail != null) {
        await helper.buySubscription(productDetail, {});
      }
    }
  }
}

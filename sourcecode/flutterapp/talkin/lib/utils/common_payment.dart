// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incodes_payment/incodes_payment_services.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/utils.dart';

import '../custom/progress_indicator/progress_dialog.dart';

BuildContext? _currentContext() => Get.context ?? Get.overlayContext;

void _showPaymentFailedToast() {
  Utils.showToast(
    _currentContext(),
    EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr,
  );
}

/// razor pay payment
Future<void> razorPay({
  required num amount,
  required Function() onPaymentSuccess,
}) async {
  Utils.showLog("Razorpay Payment (Incodes) starting...");
  Utils.showLog("Razorpay Payment (Incodes) starting...$amount");

  try {
    final razorKey = Database.settingApiModel?.data?.razorpayKeySecret ?? '';
    final email = Database.fetchLoginUserProfileModel?.user?.email;

    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ?? "INR";
    // Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("email>>>>>>>>>>>>>>>>>>>>>>$email");
    Utils.showLog("Database.email>>>>>>>>>>>>>>>>>>>>>>$email");

    // final contact = (Database.getUserProfileResponseModel?.user?.phoneNumber ??
    //     Database.getUserProfileResponseModel?.user?.phoneNumber ??
    //     "+91-0000000000");

    String toHex6(int argb) {
      final hex8 = argb.toRadixString(16).padLeft(8, '0');
      return '#${hex8.substring(2)}';
    }

    Utils.showLog("amount.toDouble()$amount");
    final appName = EnumLocale.txtAppName.name.tr;
    final hexColor = toHex6(AppColors.primary.hashCode);

    await IncodesPaymentServices.razorPayPayment(
      currency: currency,
      razorpayKey: razorKey.isNotEmpty ? razorKey : "",
      contactNumber: "+91-0000000000",
      emailId: email.toString(),
      amount: amount.toDouble(),
      appName: appName,
      colorCode: hexColor,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: _showPaymentFailedToast,
      onExternalWallet: () {
        Utils.showLog("RazorPay External Wallet selected");
      },
    );
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("RazorPay Payment Failed => $e");
  }
}

/// stripe payment
Future<void> stripe({
  required num amount,
  required Future<void> Function()? onPaymentSuccess,
}) async {
  try {
    Utils.showLog("Stripe Payment (Incodes) starting...");

    final publishableKey =
        (Database.settingApiModel?.data?.stripePublicKey ?? "").trim();

    final secretKey =
        (Database.settingApiModel?.data?.stripeSecretKey ?? "").trim();

    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ?? "INR";

    final merchantDisplayName = EnumLocale.txtAppName.name.tr;

    if (publishableKey.isEmpty || secretKey.isEmpty) {
      Utils.showLog("Stripe keys are missing, aborting payment flow.");
      _showPaymentFailedToast();
      return;
    }

    final configuredCountryCode =
        (Database.settingApiModel?.data?.currency?.countryCode ?? "")
            .trim()
            .toUpperCase();
    final merchantCountryCode =
        configuredCountryCode.length == 2 ? configuredCountryCode : "IN";

    final int minorAmount = (amount * 100).toInt();
    if (minorAmount <= 0) {
      Utils.showLog("Stripe payment skipped due to invalid amount: $amount");
      _showPaymentFailedToast();
      return;
    }

    final isTestMode =
        publishableKey.startsWith("pk_test") || secretKey.startsWith("sk_test");

    Utils.showLog(
      "Stripe config => testMode: $isTestMode, country: $merchantCountryCode, currency: $currency",
    );

    await IncodesPaymentServices.stripePayment(
      amount: minorAmount,
      currency: currency,
      isTest: isTestMode,
      merchantCountryCode: merchantCountryCode,
      merchantDisplayName: merchantDisplayName,
      publishableKey: publishableKey,
      secretKey: secretKey,
      onPaymentSuccess: onPaymentSuccess == null
          ? null
          : () async {
              await onPaymentSuccess();
            },
      onPaymentFailure: _showPaymentFailedToast,
    );

    Utils.showLog("Stripe payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Stripe Payment Failed !! => $e");
    _showPaymentFailedToast();
  }
}

/// flutter wave payment
Future<void> flutterWave({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Flutterwave Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final settingsKey = Database.settingApiModel?.data?.flutterwavePublicKey;
    final publicKey =
        (settingsKey != null && settingsKey.isNotEmpty) ? settingsKey : "";

    // final currency =  "NGN";
    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ?? "NGN";
    final customerName =
        Database.fetchLoginUserProfileModel?.user?.fullName ?? "User";
    final customerEmail =
        Database.fetchLoginUserProfileModel?.user?.email ?? "email";

    Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("customerEmail>>>>>>>>>>>>>>>>>>>>>>$customerEmail");
    Utils.showLog("currency>>>>>>>>>>>>>>>>>>>>>>$currency");
    Utils.showLog("publicKey>>>>>>>>>>>>>>>>>>>>>>$publicKey");

    final context = _currentContext();
    if (context == null) {
      Utils.showLog("Flutterwave payment skipped: context unavailable.");
      _showPaymentFailedToast();
      return;
    }

    await IncodesPaymentServices.flutterWavePayment(
      context: context,
      publicKey: publicKey,
      currency: currency,
      amount: amount.toString(),
      customerName: customerName,
      customerEmail: customerEmail.toString(),
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: _showPaymentFailedToast,
    );

    Utils.showLog("Flutterwave payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Flutterwave Payment Failed => $e");
  }
}

///pay stack payment
Future<void> payStack({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Paystack Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    // final settingsSecret =
    //     GetSettingApi.getSettingModel?.data?.flutterwaveId;
    // final secretKey = (settingsSecret != null && settingsSecret.isNotEmpty)
    //     ? settingsSecret
    //     : "";
    final settingsSecret = Database.settingApiModel?.data?.paystackSecretKey;

    final customerEmail =
        Database.fetchLoginUserProfileModel?.user?.email ?? "test@gmail.com";

    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ?? "NGN";

    // final currency =
    //      "NGN";

    final int majorAmount = amount.toInt();
    final context = _currentContext();
    if (context == null) {
      Utils.showLog("Paystack payment skipped: context unavailable.");
      _showPaymentFailedToast();
      return;
    }

    await IncodesPaymentServices.payStackPayment(
      context: context,
      secretKey: settingsSecret.toString(),
      customerEmail: customerEmail.toString(),
      amount: majorAmount,
      currency: currency,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: _showPaymentFailedToast,
    );

    Utils.showLog("Paystack payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Paystack Payment Failed => $e");
  }
}

///pay pal payment
Future<void> payPal({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("PayPal Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ?? "USD";
    // final currency = "USD";

    final paypalClientId = Database.settingApiModel?.data?.paypalClientId;
    final secretKey = Database.settingApiModel?.data?.paypalSecretKey;
    final context = _currentContext();
    if (context == null) {
      Utils.showLog("PayPal payment skipped: context unavailable.");
      _showPaymentFailedToast();
      return;
    }

    await IncodesPaymentServices.paypalPayment(
      context: context,
      clientId: paypalClientId.toString(),
      secretKey: secretKey.toString(),
      transactions: [
        {
          "amount": {
            "total": amount.toString(),
            "currency": currency,
            "details": {
              "subtotal": amount.toString(),
              "shipping": '0',
              "shipping_discount": 0
            },
          },
          "description": "Subscription purchase via PayPal",
          "item_list": {
            "items": [
              {
                "name": "Subscription Plan",
                "quantity": 1,
                "price": amount.toString(),
                "currency": currency,
              },
            ],
          },
        },
      ],
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: _showPaymentFailedToast,
    );

    Utils.showLog("PayPal payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("PayPal Payment Failed => $e");
  }
}

///in app purchase payment
Future<void> inAppPurchase({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("InAppPurchase Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final productId = "com.android.coin100";
    final userId =
        Database.fetchLoginUserProfileModel?.user?.id.toString() ?? "123456";

    await IncodesPaymentServices.inAppPurchasePayment(
      userId: userId,
      productIds: [productId],
      amount: amount.toDouble(),
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: _showPaymentFailedToast,
    );

    Utils.showLog("InAppPurchase payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("InAppPurchase Payment Failed => $e");
  }
}

///cash free payment
Future<void> cashFree({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("CashFree Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final customerName =
        Database.fetchLoginUserProfileModel?.user?.fullName ?? "John";
    final customerEmail =
        Database.fetchLoginUserProfileModel?.user?.email ?? "test@gmail.com";
    // final customerPhone =
    //     Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? "9876543210";

    Utils.showLog(
        "Database.getUserProfileResponseModel?.user?.phoneNumber${9876543210}");

    final cashfreeClientId = Database.settingApiModel?.data?.cashfreeClientId;
    final cashfreeSecretKey =
        Database.settingApiModel?.data?.cashfreeClientSecret;

// final currency ="INR";
    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ?? "INR";
    final context = _currentContext();
    if (context == null) {
      Utils.showLog("Cashfree payment skipped: context unavailable.");
      _showPaymentFailedToast();
      return;
    }

    await IncodesPaymentServices.cashFreePayment(
      context: context,
      clientId: cashfreeClientId.toString(),
      clientSecret: cashfreeSecretKey.toString(),
      amount: amount.toDouble(),
      currency: currency,
      customerName: customerName,
      customerEmail: customerEmail.toString(),
      customerPhone: "9876543210",
      paymentGatewayName: "Cashfree",
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: _showPaymentFailedToast,
    );

    Utils.showLog("CashFree payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("CashFree Payment Failed => $e");
  }
}

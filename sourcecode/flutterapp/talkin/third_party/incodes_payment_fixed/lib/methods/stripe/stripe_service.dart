import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:incodes_payment/methods/stripe/stripe_pay_model.dart';
import 'package:incodes_payment/model/incodes_payment_response.dart';
import 'package:incodes_payment/utils/listener.dart';

/// A service class to handle Stripe payment integration
///
/// Features:
/// - Initializes Stripe with test/live mode
/// - Creates PaymentIntent on Stripe server
/// - Opens Stripe PaymentSheet
/// - Handles success/failure events
/// - Supports custom or default toast (like Razorpay service)
/// - Exposes callbacks for API calls after payment events
class StripeService {
  bool isTest = false;

  /// Initialize Stripe SDK
  ///
  /// Parameters:
  /// - [isTest]: true for test mode, false for live mode
  Future<void> init(
      {required bool isTest, required String publishableKey}) async {
    Stripe.publishableKey = publishableKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';

    await Stripe.instance.applySettings().catchError((e) {
      log("Stripe Apply Settings => $e");
      throw e.toString();
    });

    this.isTest = isTest;
  }

  /// Opens Stripe Payment flow
  ///
  /// Parameters:
  /// - [amount]: Payment amount in smallest currency unit (e.g. cents for USD)
  /// - [currency]: Currency code (e.g. "USD", "INR")
  /// - [description]: Payment description
  /// - [paymentGatewayName]: Gateway name for default toast/log (default: `"Stripe"`)
  ///
  /// Callbacks:
  /// - [onShowToast]: Optional custom toast/snackbar/dialog
  /// - [onPaymentSuccess]: Called when payment succeeds
  /// - [onPaymentFailure]: Called when payment fails
  Future<void> stripePay({
    required int amount,
    required String currency,
    required String secretKey,
    required String merchantCountryCode,
    required String merchantDisplayName,
    String paymentGatewayName = "Stripe",
    String? description,
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) async {
    try {
      // Step 1: Create PaymentIntent via Stripe API
      Map<String, dynamic> body = {
        'amount': amount.toString(), // in cents (e.g. 500 = $5.00)
        'currency': currency,
        'description': description ?? '',
      };

      log("Start Payment Intent Http Request...");

      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": 'application/x-www-form-urlencoded'
        },
      );

      log("Payment Intent Http Response => ${response.body}");

      if (response.statusCode == 200) {
        StripePayModel result =
            StripePayModel.fromJson(jsonDecode(response.body));

        // Step 2: Init Payment Sheet
        SetupPaymentSheetParameters setupPaymentSheetParameters =
            SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.blue),
          ),
          googlePay: PaymentSheetGooglePay(
              merchantCountryCode: merchantCountryCode, testEnv: isTest),
          applePay:
              PaymentSheetApplePay(merchantCountryCode: merchantCountryCode),
          merchantDisplayName: merchantDisplayName,
        );

        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: setupPaymentSheetParameters);

        // Step 3: Present Payment Sheet
        await Stripe.instance.presentPaymentSheet().then((_) {
          final successResponse = IncodesPaymentResponse(
            "Payment Successful",
            true,
            result.id ?? "", // PaymentIntent ID
          );

          if (onShowToast != null) {
            onShowToast();
          } else {
            IncodesListener().onSuccess(
              response: successResponse,
              paymentGatewayName: paymentGatewayName,
              isShowToast: true,
            );
          }

          onPaymentSuccess?.call();
        }).catchError((e) {
          final failureResponse = IncodesPaymentResponse(
            "Payment Cancelled or Failed",
            false,
            result.id ?? "",
          );

          if (onShowToast != null) {
            onShowToast();
          } else {
            IncodesListener().onFailure(
              response: failureResponse,
              paymentGatewayName: paymentGatewayName,
              isShowToast: true,
            );
          }

          onPaymentFailure?.call();
        });
      } else {
        final failureResponse = IncodesPaymentResponse(
          "Stripe Payment Error",
          false,
          "",
        );

        if (onShowToast != null) {
          onShowToast();
        } else {
          IncodesListener().onFailure(
            response: failureResponse,
            paymentGatewayName: paymentGatewayName,
            isShowToast: true,
          );
        }

        onPaymentFailure?.call();
      }
    } catch (e) {
      log('Error in Stripe Payment: ${e.toString()}');

      final failureResponse = IncodesPaymentResponse(
        e.toString(),
        false,
        "",
      );

      if (onShowToast != null) {
        onShowToast();
      } else {
        IncodesListener().onFailure(
          response: failureResponse,
          paymentGatewayName: paymentGatewayName,
          isShowToast: true,
        );
      }

      onPaymentFailure?.call();
    }
  }
}

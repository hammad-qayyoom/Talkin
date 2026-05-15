import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:incodes_payment/model/incodes_payment_response.dart';
import 'package:incodes_payment/utils/listener.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';

/// A service class to handle Pay stack payment integration
class PaystackService {
  /// Opens Pay stack checkout screen with provided details
  ///
  /// Parameters:
  /// - [context]: BuildContext required for checkout
  /// - [secretKey]: Pay stack Secret Key
  /// - [customerEmail]: Customer email
  /// - [amount]: Amount in kobo (₦200 = 20000)
  /// - [currency]: Default NGN
  /// - [callbackUrl]: Optional callback URL
  /// - [paymentGatewayName]: (Optional) Gateway name for default toast/log
  /// - [onShowToast]: (Optional) User can override default toast
  /// - [onPaymentSuccess]: Callback when payment succeeds
  /// - [onPaymentFailure]: Callback when payment fails
  static Future<void> openPaystack({
    required BuildContext context,
    required String secretKey,
    required String customerEmail,
    required num amount,
    String currency = "NGN",
    String? callbackUrl,
    String paymentGatewayName = "Pay stack",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) async {
    try {
      final uniqueTransRef = PayWithPayStack().generateUuidV4();

      await PayWithPayStack().now(
        context: context,
        secretKey: secretKey,
        customerEmail: customerEmail,
        reference: uniqueTransRef,
        currency: currency,
        amount: double.parse(amount.toString()),
        callbackUrl: callbackUrl ?? "https://google.com",
        transactionCompleted: (paymentData) {
          final successResponse = IncodesPaymentResponse(
            "Payment Successful",
            true,
            paymentData.reference ?? uniqueTransRef,
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
          log("Pay stack Payment Successful: ${paymentData.toString()}");
        },
        transactionNotCompleted: (reason) {
          final failureResponse = IncodesPaymentResponse(
            "Payment Failed: $reason",
            false,
            uniqueTransRef,
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
          log("Pay stack Payment Failed: $reason");
        },
      );
    } catch (e) {
      log("Pay stack Exception => $e");
    }
    return;
  }
}

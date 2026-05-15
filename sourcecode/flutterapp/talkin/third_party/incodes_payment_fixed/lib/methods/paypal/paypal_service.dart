import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:incodes_payment/model/incodes_payment_response.dart';
import 'package:incodes_payment/utils/listener.dart';

/// A service class to handle PayPal payment integration
class PaypalService {
  /// Opens PayPal checkout screen with provided details
  ///
  /// Parameters:
  /// - [context]: BuildContext required for navigation
  /// - [clientId]: PayPal clientId
  /// - [secretKey]: PayPal secretKey
  /// - [sandboxMode]: Whether to use sandbox mode or live
  /// - [transactions]: List of transactions to be paid
  /// - [note]: Optional note
  /// - [paymentGatewayName]: (Optional) Gateway name for default toast/log
  /// - [onShowToast]: (Optional) User can override default toast
  /// - [onPaymentSuccess]: Callback when payment succeeds
  /// - [onPaymentFailure]: Callback when payment fails
  /// - [onPaymentCancel]: Callback when payment is cancelled
  Future<void> openPaypal({
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
    try {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (ctx) => PaypalCheckoutView(
            sandboxMode: sandboxMode,
            clientId: clientId,
            secretKey: secretKey,
            transactions: transactions,
            note: note ?? "Contact us for any questions on your order.",
            onSuccess: (params) async {
              final successResponse = IncodesPaymentResponse(
                "Payment Successful",
                true,
                params['id']?.toString() ?? "",
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
              Navigator.of(ctx, rootNavigator: true).pop();
            },
            onError: (error) {
              final failureResponse = IncodesPaymentResponse(
                "Payment Failed: $error",
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
              Navigator.of(ctx, rootNavigator: true).pop();
            },
            onCancel: () {
              final cancelResponse = IncodesPaymentResponse(
                "Payment Cancelled",
                false,
                "",
              );

              if (onShowToast != null) {
                onShowToast();
              } else {
                IncodesListener().onFailure(
                  response: cancelResponse,
                  paymentGatewayName: paymentGatewayName,
                  isShowToast: true,
                );
              }

              onPaymentCancel?.call();
              Navigator.of(ctx, rootNavigator: true).pop();
            },
          ),
        ),
      );
    } catch (e) {
      log("PayPal Exception => $e");
    }
  }
}

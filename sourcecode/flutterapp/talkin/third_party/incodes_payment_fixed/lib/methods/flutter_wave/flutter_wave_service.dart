import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:incodes_payment/model/incodes_payment_response.dart';
import 'package:incodes_payment/utils/listener.dart';

/// Flutter wave Payment Service
class FlutterWaveService {
  static Future<void> openFlutterWave({
    required BuildContext context,
    required String publicKey,
    required String currency,
    required String amount,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    String redirectUrl = "https://www.google.com/",
    String paymentOptions = "ussd, card, barter, pay attitude",
    String title = "Payment SDK",
    String paymentGatewayName = "Flutter wave",
    bool isTestMode = true,
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) async {
    try {
      final Customer customer = Customer(
        name: customerName,
        email: customerEmail,
        phoneNumber: customerPhone ?? '',
      );

      final Flutterwave flutterWave = Flutterwave(
        publicKey: publicKey,
        currency: currency,
        redirectUrl: redirectUrl,
        txRef: "TX-${DateTime.now().millisecondsSinceEpoch}",
        amount: amount,
        customer: customer,
        paymentOptions: paymentOptions,
        customization: Customization(title: title),
        isTestMode: isTestMode,
      );

      log("Flutter wave Payment Starting...");

      final ChargeResponse response = await flutterWave.charge(context);

      if (response.status?.toLowerCase() == "successful") {
        final successResponse = IncodesPaymentResponse(
          "Payment Successful",
          true,
          response.transactionId ?? "",
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
        log("Flutter wave Payment Successful: ${response.toString()}");
      } else {
        final failureResponse = IncodesPaymentResponse(
          "Payment Failed",
          false,
          response.transactionId ?? "",
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
        log("Flutter wave Payment Failed: ${response.toString()}");
      }
    } catch (e) {
      log("Flutter wave Exception => $e");

      final failureResponse = IncodesPaymentResponse(
        "Payment Error: $e",
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

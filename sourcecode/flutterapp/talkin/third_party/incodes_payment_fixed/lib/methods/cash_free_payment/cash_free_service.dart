import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:http/http.dart' as http;
import 'package:incodes_payment/model/incodes_payment_response.dart';
import 'package:incodes_payment/utils/listener.dart';

/// Cashfree Payment Service
class CashfreeService {
  static final CFPaymentGatewayService _cfPaymentGatewayService =
      CFPaymentGatewayService();

  /// Open Cashfree Checkout
  static Future<void> openCashfree({
    required BuildContext context,
    required String clientId,
    required String clientSecret,
    required double amount,
    required String currency,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? returnUrl =
        "https://www.cashfree.com/devstudio/preview/pg/web/checkout?order_id={order_id}",
    String paymentGatewayName = "Cashfree",
    bool? isSandbox = true,
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
  }) async {
    try {
      // Create payment session
      final session = await _createPaymentSession(
        clientId: clientId,
        clientSecret: clientSecret,
        amount: amount,
        currency: currency,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        returnUrl: returnUrl ?? "",
        isSandbox: isSandbox ?? false,
      );

      if (session == null) {
        final failureResponse = IncodesPaymentResponse(
          "Failed to create Cashfree order session",
          false,
          "",
        );
        _handleFailure(
          failureResponse,
          paymentGatewayName,
          onShowToast,
          onPaymentFailure,
        );
        return;
      }

      // Theme (optional - you can customize or remove)
      final theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#5E35B1")
          .setPrimaryFont("Menlo")
          .setSecondaryFont("Futura")
          .build();

      // Web Checkout Payment (replaces Drop Checkout)
      final cfWebCheckoutPayment = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme) // Optional
          .build();

      _cfPaymentGatewayService.setCallback(
        (orderId) {
          final successResponse = IncodesPaymentResponse(
            "Payment Successful",
            true,
            orderId,
          );
          _handleSuccess(
            successResponse,
            paymentGatewayName,
            onShowToast,
            onPaymentSuccess,
          );
        },
        (errorResponse, orderId) {
          final failureResponse = IncodesPaymentResponse(
            "Payment Failed: ${errorResponse.getMessage()}",
            false,
            orderId,
          );
          _handleFailure(
            failureResponse,
            paymentGatewayName,
            onShowToast,
            onPaymentFailure,
          );
        },
      );

      // Start Payment
      _cfPaymentGatewayService.doPayment(cfWebCheckoutPayment);
    } catch (e) {
      log("Cashfree Exception => $e");
      final failureResponse = IncodesPaymentResponse(
        "Payment Error: $e",
        false,
        "",
      );
      _handleFailure(
        failureResponse,
        paymentGatewayName,
        onShowToast,
        onPaymentFailure,
      );
    }
  }

  /// Create Cashfree Payment Session
  static Future<CFSession?> _createPaymentSession({
    required String clientId,
    required String clientSecret,
    required double amount,
    required String currency,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String returnUrl,
    required bool isSandbox,
  }) async {
    final url = Uri.parse(isSandbox
        ? "https://sandbox.cashfree.com/pg/orders"
        : "https://api.cashfree.com/pg/orders");

    final headers = {
      'accept': 'application/json',
      'content-type': 'application/json',
      'x-api-version': '2025-01-01',
      'x-client-id': clientId,
      'x-client-secret': clientSecret,
    };

    final body = jsonEncode({
      "order_amount": amount,
      "order_currency": currency,
      "customer_details": {
        "customer_id": "cust_${DateTime.now().millisecondsSinceEpoch}",
        "customer_name": customerName,
        "customer_email": customerEmail,
        "customer_phone": customerPhone,
      },
      "order_meta": {"return_url": returnUrl},
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final paymentSessionId = data['payment_session_id'];
        final orderId = data['order_id'];
        return CFSessionBuilder()
            .setEnvironment(
                isSandbox ? CFEnvironment.sandbox : CFEnvironment.production)
            .setOrderId(orderId)
            .setPaymentSessionId(paymentSessionId)
            .build();
      } else {
        log("Cashfree Failed to create order: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      log("Cashfree Exception during session creation: $e");
    }
    return null;
  }

  /// Handle Success
  static void _handleSuccess(
    IncodesPaymentResponse response,
    String paymentGatewayName,
    Function()? onShowToast,
    Function()? onPaymentSuccess,
  ) {
    if (onShowToast != null) {
      onShowToast();
    } else {
      IncodesListener().onSuccess(
        response: response,
        paymentGatewayName: paymentGatewayName,
        isShowToast: true,
      );
    }
    onPaymentSuccess?.call();
  }

  /// Handle Failure
  static void _handleFailure(
    IncodesPaymentResponse response,
    String paymentGatewayName,
    Function()? onShowToast,
    Function()? onPaymentFailure,
  ) {
    if (onShowToast != null) {
      onShowToast();
    } else {
      IncodesListener().onFailure(
        response: response,
        paymentGatewayName: paymentGatewayName,
        isShowToast: true,
      );
    }
    onPaymentFailure?.call();
  }
}

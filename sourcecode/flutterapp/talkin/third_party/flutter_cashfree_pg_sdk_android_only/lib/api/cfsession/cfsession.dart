import 'package:flutter_cashfree_pg_sdk/utils/cfexceptionconstants.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class CFSessionBuilder {
  CFEnvironment? _environment;
  String? _orderId;
  String? _paymentSessionId;
  String? _orderToken;

  CFSessionBuilder();

  CFSessionBuilder setEnvironment(CFEnvironment environment) {
    _environment = environment;
    return this;
  }

  CFSessionBuilder setOrderId(String orderId) {
    _orderId = orderId;
    return this;
  }

  @Deprecated(
      "order_token will no longer be used in the integration steps. Please switch to payment_session_id using setPaymentSessionId() method")
  CFSessionBuilder setOrderToken(String orderToken) {
    _orderToken = orderToken;
    return this;
  }

  CFSessionBuilder setPaymentSessionId(String paymentSessionId) {
    _paymentSessionId = paymentSessionId;
    return this;
  }

  String getOrderId() {
    return _orderId!;
  }

  String getOrderToken() {
    return _orderToken ?? "";
  }

  String getPaymentSessionId() {
    return _paymentSessionId!;
  }

  CFEnvironment getEnvironment() {
    return _environment!;
  }

  CFSession build() {
    if (_environment == null) {
      throw CFException(CFExceptionConstants.environmentNotPresent);
    }
    if (_orderId == null || _orderId!.isEmpty) {
      throw CFException(CFExceptionConstants.orderIdNotPresent);
    }
    if (_paymentSessionId == null || _paymentSessionId!.isEmpty) {
      throw CFException(CFExceptionConstants.paymentSessionIdNotPresent);
    }
    return CFSession(this);
  }
}

class CFSession {
  late CFEnvironment _environment;
  late String _orderId;
  late String _orderToken;
  late String _paymentSessionId;

  CFSession(CFSessionBuilder sessionBuilder) {
    _environment = sessionBuilder.getEnvironment();
    _paymentSessionId = sessionBuilder.getPaymentSessionId();
    _orderId = sessionBuilder.getOrderId();
  }

  String getOrderId() {
    return _orderId;
  }

  String getOrderToken() {
    return _orderToken;
  }

  String getPaymentSessionId() {
    return _paymentSessionId;
  }

  String getEnvironment() {
    return _environment == CFEnvironment.sandbox ? "SANDBOX" : "PRODUCTION";
  }

  CFEnvironment getEnvironmentEnum() {
    return _environment;
  }
}

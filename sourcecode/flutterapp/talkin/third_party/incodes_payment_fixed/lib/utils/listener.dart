import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:incodes_payment/model/incodes_payment_response.dart';

class IncodesListener {
  void onSuccess({
    required IncodesPaymentResponse response,
    String? paymentGatewayName,
    String? toastMsg,
    Function()? onPaymentSuccess,
    bool? isShowToast,
  }) {
    bool isSuccessPayment = response.paymentStatus;
    if (isSuccessPayment) {
      onPaymentSuccess?.call();

      isShowToast == true
          ? showToast(
              msg: toastMsg ??
                  (paymentGatewayName != null
                      ? "$paymentGatewayName Payment Successful"
                      : "Payment Successful"),
            )
          : null;
    }
  }

  void onFailure({
    required IncodesPaymentResponse response,
    String? paymentGatewayName,
    String? toastMsg,
    Function()? onPaymentFailure,
    bool? isShowToast,
  }) {
    bool isSuccessPayment = response.paymentStatus;
    if (isSuccessPayment) {
      onPaymentFailure?.call();

      isShowToast == true
          ? showToast(
              msg: toastMsg ??
                  (paymentGatewayName != null
                      ? "$paymentGatewayName Payment Failed"
                      : "Payment Failed"),
            )
          : null;
    }
  }

  void showToast(
      {required String msg,
      Color? bgColor,
      Color? textColor,
      double? fontSize}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor ?? Colors.blue,
      textColor: textColor ?? Colors.white,
      fontSize: fontSize ?? 16,
    );
  }
}

import 'package:incodes_payment/model/incodes_payment_response.dart';
import 'package:incodes_payment/utils/listener.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// A service class to handle Razorpay payment integration
///
/// This class manages:
/// - Opening Razorpay checkout with required options
/// - Handling events like **payment success**, **payment failure**, and **external wallet selection**
/// - Triggering either **default toast via IncodesListener** or a **custom user-provided toast**
/// - Exposing optional callbacks for API calls after payment
class RazorpayServices {
  /// Instance of Razorpay SDK
  Razorpay? razorpay = Razorpay();

  /// Opens Razorpay checkout screen with provided details.
  ///
  /// Parameters:
  /// - [contactNumber]: Customer phone number (used for Razorpay prefill)
  /// - [emailId]: Customer email address (used for Razorpay prefill)
  /// - [razorpayKey]: Your Razorpay public key
  /// - [amount]: Payment amount in INR (automatically converted to paisa internally)
  /// - [appName]: The display name shown in Razorpay checkout
  /// - [description]: Optional payment description (order details, etc.)
  /// - [colorCode]: Optional checkout theme color in hex (default: green `#0CA72F`)
  /// - [paymentGatewayName]: Name used for default toast/logs (default: `"Razorpay"`)
  ///
  /// Callbacks:
  /// - [onShowToast]: Optional → User can provide their own toast/snackbar/dialog handler.
  ///                  If not provided, default `IncodesListener` toast will be used.
  /// - [onPaymentSuccess]: Optional → Called after successful payment (for API calls, etc.)
  /// - [onPaymentFailure]: Optional → Called after failed payment
  /// - [onExternalWallet]: Optional → Called when user selects an external wallet
  void openRazorpay({
    required String contactNumber,
    required String emailId,
    required String razorpayKey,
    required double amount,
    required String appName,
    required String currency,
    String? description,
    String? colorCode,
    String paymentGatewayName = "Razorpay",
    Function()? onShowToast,
    Function()? onPaymentSuccess,
    Function()? onPaymentFailure,
    Function()? onExternalWallet,
  }) {
    // Razorpay checkout options (amount converted to paisa)
    Map<String, Object> options = {
      'key': razorpayKey,
      'amount': amount * 100, // amount in paisa
      'name': appName,
      'currency': currency,
      'prefill': {'contact': contactNumber, 'email': emailId},
      'description': description ?? '',
      'theme': {'color': colorCode ?? '#0CA72F'},
      'send_sms_hash': true,
      'external': {
        'wallets': ['paytm', 'phonepe', 'mobikwik', 'freecharge', 'airtelmoney']
      }
    };

    try {
      /// EVENT: Payment Success
      /// Triggered when the payment is successful
      razorpay!.on(
        Razorpay.eventPaymentSuccess,
        (PaymentSuccessResponse res) {
          final successResponse = IncodesPaymentResponse(
            "Payment Successful",
            true,
            res.paymentId ?? "",
          );

          // Use custom toast OR fallback to default listener
          if (onShowToast != null) {
            onShowToast();
          } else {
            IncodesListener().onSuccess(
              response: successResponse,
              paymentGatewayName: paymentGatewayName,
              isShowToast: true,
              onPaymentSuccess: onPaymentSuccess?.call(),
            );
          }
        },
      );

      /// EVENT: Payment Failure
      /// Triggered when the payment fails (network issue, cancellation, etc.)
      razorpay!.on(
        Razorpay.eventPaymentError,
        (PaymentFailureResponse res) {
          final failureResponse = IncodesPaymentResponse(
            res.message ?? "Payment Failed",
            false,
            res.code.toString(),
          );

          if (onShowToast != null) {
            onShowToast();
          } else {
            IncodesListener().onFailure(
              response: failureResponse,
              paymentGatewayName: paymentGatewayName,
              isShowToast: true,
              onPaymentFailure: onPaymentFailure?.call(),
            );
          }
        },
      );

      /// EVENT: External Wallet
      /// Triggered when user selects an external wallet (Paytm, PhonePe, etc.)
      razorpay!.on(
        Razorpay.eventExternalWallet,
        (ExternalWalletResponse res) {
          final walletResponse = IncodesPaymentResponse(
            "External Wallet Selected: ${res.walletName}",
            true,
            res.walletName ?? "",
          );

          if (onShowToast != null) {
            onShowToast();
          } else {
            IncodesListener().onSuccess(
              response: walletResponse,
              paymentGatewayName: paymentGatewayName,
            );
          }

          // Trigger user external wallet callback
          onExternalWallet?.call();
        },
      );

      // Finally open Razorpay checkout
      razorpay!.open(options);
    } catch (e) {
      // Handle exceptions while opening Razorpay checkout
    }
  }

  /// Dispose Razorpay listeners
  ///
  /// Should be called when the screen is disposed
  /// to avoid memory leaks.
  void dispose() {
    razorpay?.clear();
  }
}

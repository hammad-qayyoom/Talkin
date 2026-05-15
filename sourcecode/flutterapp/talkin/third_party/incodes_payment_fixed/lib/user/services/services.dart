import 'package:flutter/cupertino.dart';
import 'package:incodes_payment/incodes_payment_services.dart';

class Services {
  Future callRazorPayService() async {
    await IncodesPaymentServices.razorPayPayment(
      razorpayKey: "enter your razorpayKey",
      contactNumber: "+91-1234567890",
      emailId: "test@gmail.com",
      amount: 2500,
      currency: "USD",
      appName: "Incodes Payments",
      colorCode: '#fcba03',
      description: 'Add the description for the order or payment.',
    );
  }

  Future callStripeService() async {
    await IncodesPaymentServices.stripePayment(
      amount: 500,
      currency: "USD",
      description: "Test Order Payment",
      isTest: true,
      merchantCountryCode: "IN",
      merchantDisplayName: "Incodes Payments",
      publishableKey: "enter your publishableKey",
      secretKey: "enter your secretKey",
    );
  }

  Future callPaypalService(BuildContext context) async {
    await IncodesPaymentServices.paypalPayment(
      context: context,
      clientId: "enter your clientId",
      secretKey: "enter your secretKey",
      transactions: const [
        {
          "amount": {
            "total": '70',
            "currency": "USD",
            "details": {
              "subtotal": '70',
              "shipping": '0',
              "shipping_discount": 0
            }
          },
          "description": "The payment transaction description.",
          "item_list": {
            "items": [
              {"name": "Apple", "quantity": 4, "price": '5', "currency": "USD"},
              {
                "name": "Pineapple",
                "quantity": 5,
                "price": '10',
                "currency": "USD"
              }
            ],
          }
        }
      ],
    );
  }

  Future callPayStackService(BuildContext context) async {
    await IncodesPaymentServices.payStackPayment(
      context: context,
      secretKey: "enter your secretKey",
      customerEmail: "testuser@gmail.com",
      amount: 20000, // ₦200
      currency: "NGN",
    );
  }

  Future callFlutterwaveService(BuildContext context) async {
    await IncodesPaymentServices.flutterWavePayment(
      context: context,
      publicKey: "enter your publicKey",
      currency: "USD",
      amount: "1000",
      customerName: "Test User",
      customerEmail: "testUser@gmail.com",
    );
  }

  Future callCashFressService(BuildContext context) async {
    await IncodesPaymentServices.cashFreePayment(
      context: context,
      clientId: "enter your clientId",
      clientSecret: "enter your clientSecret",
      amount: 1.0,
      currency: "INR",
      customerName: "John",
      customerEmail: "john@example.com",
      customerPhone: "9876543210",
      paymentGatewayName: "Cashfree",
    );
  }

  Future callInAppPurchaseService(BuildContext context) async {
    await IncodesPaymentServices.inAppPurchasePayment(
      userId: "123456",
      productIds: ["com.android.coin.100"],
      amount: 100,
    );
  }
}

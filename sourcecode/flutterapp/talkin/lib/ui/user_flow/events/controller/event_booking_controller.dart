import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/events/api/event_api.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/utils/common_payment.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class EventPaymentMethodOption {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  EventPaymentMethodOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class EventBookingController extends GetxController {
  final event = Rxn<FoundationEvent>();
  final selectedTickets = <String, int>{}.obs;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();

  final availableGateways = <EventPaymentMethodOption>[].obs;
  final selectedGatewayKey = ''.obs;

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _handleIncomingArguments();
    _prefillUserInfo();
    _loadLiveSettingsAndConfigureGateways();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _handleIncomingArguments() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['event'] is FoundationEvent) {
        event.value = args['event'] as FoundationEvent;
      }
      if (args['selectedTickets'] is Map<String, int>) {
        selectedTickets.assignAll(args['selectedTickets'] as Map<String, int>);
      }
    }
  }

  void _prefillUserInfo() {
    final user = Database.fetchLoginUserProfileModel?.user;
    if (user != null) {
      final parts = (user.fullName ?? '').trim().split(' ');
      if (parts.isNotEmpty) {
        firstNameController.text = parts.first;
        if (parts.length > 1) {
          lastNameController.text = parts.sublist(1).join(' ');
        }
      }
      if (user.email != null && user.email!.isNotEmpty) {
        emailController.text = user.email!;
      } else {
        final cached = Database.localStorage.read('last_ticket_email') ?? Database.localStorage.read('last_donor_email');
        if (cached is String && cached.isNotEmpty) {
          emailController.text = cached;
        }
      }
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        phoneController.text = user.phoneNumber!;
      }
    }
  }

  Future<void> _loadLiveSettingsAndConfigureGateways() async {
    _configureGateways();
    try {
      final fresh = await SettingApi.callApi();
      if (fresh != null) {
        Database.settingApiModel = fresh;
        _configureGateways();
      }
    } catch (_) {}
  }

  bool _isGatewayEnabled({bool? android, bool? ios, bool? fallback}) {
    if (Platform.isAndroid && android != null) return android;
    if (Platform.isIOS && ios != null) return ios;
    return fallback ?? false;
  }

  void _configureGateways() {
    final s = Database.settingApiModel?.data;
    final list = <EventPaymentMethodOption>[];

    // 1. PayPal
    if (_isGatewayEnabled(
      android: s?.isPaypalAndroidEnabled,
      ios: s?.isPaypalIosEnabled,
    )) {
      list.add(EventPaymentMethodOption(
        key: 'paypal',
        title: 'PayPal',
        subtitle: 'Pay safely with PayPal or Card',
        icon: Icons.account_balance_wallet_rounded,
      ));
    }

    // 2. Stripe
    if (_isGatewayEnabled(
      android: s?.isStripeEnabled,
      ios: s?.isStripeIosEnabled,
      fallback: s?.isStripeEnabled,
    )) {
      list.add(EventPaymentMethodOption(
        key: 'stripe',
        title: 'Credit / Debit Card',
        subtitle: 'Secure payment via Stripe',
        icon: Icons.credit_card_rounded,
      ));
    }

    // 3. Razorpay
    if (_isGatewayEnabled(
      android: s?.isRazorpayEnabled,
      ios: s?.isRazorpayIosEnabled,
      fallback: s?.isRazorpayEnabled,
    )) {
      list.add(EventPaymentMethodOption(
        key: 'razorpay',
        title: 'Razorpay',
        subtitle: 'UPI, Net Banking, Cards & Wallets',
        icon: Icons.account_balance_wallet_rounded,
      ));
    }

    // 4. Flutterwave
    if (_isGatewayEnabled(
      android: s?.isFlutterwaveEnabled,
      ios: s?.isFlutterwaveIosEnabled,
      fallback: s?.isFlutterwaveEnabled,
    )) {
      list.add(EventPaymentMethodOption(
        key: 'flutterwave',
        title: 'Flutterwave',
        subtitle: 'Cards, Bank Transfer & Mobile Money',
        icon: Icons.payments_rounded,
      ));
    }

    // 5. Paystack
    if (_isGatewayEnabled(
      android: s?.isPaystackAndroidEnabled,
      ios: s?.isPaystackIosEnabled,
    )) {
      list.add(EventPaymentMethodOption(
        key: 'paystack',
        title: 'Paystack',
        subtitle: 'Fast and secure African payment channels',
        icon: Icons.account_balance_rounded,
      ));
    }

    // 6. Cashfree
    if (_isGatewayEnabled(
      android: s?.isCashfreeAndroidEnabled,
      ios: s?.isCashfreeIosEnabled,
    )) {
      list.add(EventPaymentMethodOption(
        key: 'cashfree',
        title: 'Cashfree',
        subtitle: 'Cards, Netbanking & Wallets via Cashfree',
        icon: Icons.payment_rounded,
      ));
    }

    // 7. Star Coin Wallet
    final userCoins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
    list.add(EventPaymentMethodOption(
      key: 'wallet',
      title: 'Star Coin Wallet',
      subtitle: 'Available: $userCoins Coins (1 Coin = CA\$1.00)',
      icon: Icons.stars_rounded,
    ));

    availableGateways.assignAll(list);
    if (list.isNotEmpty && !list.any((g) => g.key == selectedGatewayKey.value)) {
      selectedGatewayKey.value = list.first.key;
    }
  }

  int get totalTicketsCount => selectedTickets.values.fold(0, (sum, q) => sum + q);

  double get subtotal {
    double total = 0.0;
    final ev = event.value;
    if (ev == null) return 0.0;
    for (final entry in selectedTickets.entries) {
      final t = ev.tickets.firstWhereOrNull((ticket) => ticket.id == entry.key);
      if (t != null) {
        total += t.price * entry.value;
      }
    }
    return total;
  }

  double get platformCommission => (subtotal * 0.04 * 100).round() / 100.0;

  double get grandTotal => subtotal + platformCommission;

  void selectGateway(String key) {
    selectedGatewayKey.value = key;
  }

  bool _validate() {
    final ctx = Get.context;
    if (totalTicketsCount <= 0) {
      Utils.showToast(ctx, 'Please select at least one ticket.');
      return false;
    }
    if (firstNameController.text.trim().isEmpty) {
      Utils.showToast(ctx, 'Please enter your first name.');
      return false;
    }
    if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
      Utils.showToast(ctx, 'Please enter a valid email address.');
      return false;
    }
    if (grandTotal > 0 && selectedGatewayKey.value.isEmpty) {
      Utils.showToast(ctx, 'Please select a payment gateway.');
      return false;
    }
    return true;
  }

  Future<void> submitBooking() async {
    if (!_validate()) return;

    final ev = event.value;
    if (ev == null) return;

    final total = grandTotal;
    final gateway = selectedGatewayKey.value;

    isSubmitting.value = true;

    try {
      if (total <= 0) {
        // Free event registration
        await _finalizeBookingRecord(paymentMethod: 'FREE', paymentId: 'free_${DateTime.now().millisecondsSinceEpoch}');
      } else if (gateway == 'paypal') {
        await payPal(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeBookingRecord(
              paymentMethod: 'PAYPAL',
              paymentId: 'paypal_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'stripe') {
        await stripe(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeBookingRecord(
              paymentMethod: 'STRIPE',
              paymentId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'razorpay') {
        await razorPay(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeBookingRecord(
              paymentMethod: 'RAZORPAY',
              paymentId: 'rzp_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'flutterwave') {
        await flutterWave(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeBookingRecord(
              paymentMethod: 'FLUTTERWAVE',
              paymentId: 'flw_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'paystack') {
        await payStack(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeBookingRecord(
              paymentMethod: 'PAYSTACK',
              paymentId: 'pstk_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'cashfree') {
        await cashFree(
          amount: total,
          onPaymentSuccess: () async {
            await _finalizeBookingRecord(
              paymentMethod: 'CASHFREE',
              paymentId: 'cf_${DateTime.now().millisecondsSinceEpoch}',
            );
          },
        );
      } else if (gateway == 'wallet') {
        final currentCoins = Database.fetchLoginUserProfileModel?.user?.coins ?? 0;
        if (currentCoins < total) {
          Utils.showToast(
            Get.context,
            'Insufficient Star Coins. You have $currentCoins Coins, required $total Coins.',
          );
          isSubmitting.value = false;
          return;
        }

        // Deduct user coins
        final u = Database.fetchLoginUserProfileModel?.user;
        if (u != null) {
          u.coins = (currentCoins - total.toInt());
        }

        await _finalizeBookingRecord(
          paymentMethod: 'STAR_COIN_WALLET',
          paymentId: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } catch (e) {
      Utils.showLog('Event booking error: $e');
      Utils.showToast(Get.context, 'Booking failed: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _finalizeBookingRecord({
    required String paymentMethod,
    required String paymentId,
  }) async {
    final ev = event.value!;
    final email = emailController.text.trim();
    if (email.isNotEmpty) {
      Database.localStorage.write('last_ticket_email', email);
    }

    final ticketsPayload = selectedTickets.entries.map((e) {
      return {
        'ticketId': e.key,
        'quantity': e.value,
      };
    }).toList();

    final payload = <String, dynamic>{
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': email,
      'phone': phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
      'notes': notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
      'tickets': ticketsPayload,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'paymentStatus': 'PAID',
      'source': 'NOTISBOARD_MOBILE_APP',
    };

    final record = await EventApi.bookTickets(eventId: ev.id, payload: payload);

    final resolvedRecord = record ??
        EventRegistrationRecord(
          id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
          bookingReference: 'NTB-TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          eventId: ev.id,
          eventTitle: ev.title,
          eventImage: ev.featuredImage,
          eventDate: ev.startDateTime,
          venue: ev.locationDisplay,
          isOnline: ev.isOnline,
          attendeeName: '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim(),
          email: email,
          quantity: totalTicketsCount,
          totalAmount: grandTotal,
          currency: ev.currency,
          paymentMethod: paymentMethod,
          status: 'CONFIRMED',
          createdAt: DateTime.now().toIso8601String(),
        );

    Get.offNamed(
      AppRoutes.ticketPassScreen,
      arguments: resolvedRecord,
    );
  }
}


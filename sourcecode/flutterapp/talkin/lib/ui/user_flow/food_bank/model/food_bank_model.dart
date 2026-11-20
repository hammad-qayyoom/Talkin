double _toDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

int _toInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

class FoodBankAmount {
  final String id;
  final double amount;
  final String? label;
  final String currency;
  final int sortOrder;

  FoodBankAmount({
    required this.id,
    required this.amount,
    this.label,
    this.currency = 'CAD',
    this.sortOrder = 0,
  });

  factory FoodBankAmount.fromJson(Map<String, dynamic> json) {
    return FoodBankAmount(
      id: json['id']?.toString() ?? '',
      amount: _toDouble(json['amount'], 25.0),
      label: json['label']?.toString(),
      currency: json['currency']?.toString() ?? 'CAD',
      sortOrder: _toInt(json['sortOrder'], 0),
    );
  }
}

class FoodBankConfig {
  final bool isEnabled;
  final String title;
  final String description;
  final String currency;
  final bool enableCustomAmount;
  final double minAmount;
  final double maxAmount;
  final bool enablePredefinedAmounts;
  final bool enableWebsiteCheckout;
  final bool enableMobileApp;
  final String confirmationMessage;
  final List<FoodBankAmount> amounts;

  FoodBankConfig({
    required this.isEnabled,
    required this.title,
    required this.description,
    required this.currency,
    required this.enableCustomAmount,
    required this.minAmount,
    required this.maxAmount,
    required this.enablePredefinedAmounts,
    required this.enableWebsiteCheckout,
    required this.enableMobileApp,
    required this.confirmationMessage,
    required this.amounts,
  });

  factory FoodBankConfig.fromJson(Map<String, dynamic> json) {
    final amountsList = <FoodBankAmount>[];
    if (json['amounts'] is List) {
      for (final a in json['amounts']) {
        if (a is Map<String, dynamic>) {
          amountsList.add(FoodBankAmount.fromJson(a));
        }
      }
    }

    return FoodBankConfig(
      isEnabled: json['isEnabled'] ?? true,
      title: json['title']?.toString() ?? 'Support Our Food Bank',
      description: json['description']?.toString() ??
          'Help provide vital food assistance, nourishing hot meals, and emergency grocery relief to vulnerable families in need.',
      currency: json['currency']?.toString() ?? 'CAD',
      enableCustomAmount: json['enableCustomAmount'] ?? true,
      minAmount: _toDouble(json['minAmount'], 1.0),
      maxAmount: _toDouble(json['maxAmount'], 5000.0),
      enablePredefinedAmounts: json['enablePredefinedAmounts'] ?? true,
      enableWebsiteCheckout: json['enableWebsiteCheckout'] ?? true,
      enableMobileApp: json['enableMobileApp'] ?? true,
      confirmationMessage: json['confirmationMessage']?.toString() ??
          'Thank you for supporting our Food Bank! Your generous gift brings hope and nourishment to families.',
      amounts: amountsList,
    );
  }
}

class FoodBankDonationRecord {
  final String id;
  final String donationRef;
  final String donorName;
  final String donorEmail;
  final String? donorPhone;
  final double amount;
  final String currency;
  final String paymentGateway;
  final String? paymentTransactionId;
  final String? relatedOrderId;
  final String status;
  final String source;
  final String? message;
  final String? donatedAt;

  FoodBankDonationRecord({
    required this.id,
    required this.donationRef,
    required this.donorName,
    required this.donorEmail,
    this.donorPhone,
    required this.amount,
    required this.currency,
    required this.paymentGateway,
    this.paymentTransactionId,
    this.relatedOrderId,
    required this.status,
    required this.source,
    this.message,
    this.donatedAt,
  });

  factory FoodBankDonationRecord.fromJson(Map<String, dynamic> json) {
    return FoodBankDonationRecord(
      id: json['id']?.toString() ?? '',
      donationRef: json['donationRef']?.toString() ??
          (json['paymentTransactionId']?.toString() ?? 'FBD-RECORD'),
      donorName: json['donorName']?.toString() ?? 'Anonymous Donor',
      donorEmail: json['donorEmail']?.toString() ?? '',
      donorPhone: json['donorPhone']?.toString(),
      amount: _toDouble(json['amount'], 0.0),
      currency: json['currency']?.toString() ?? 'CAD',
      paymentGateway: json['paymentGateway']?.toString() ?? 'Online Gateway',
      paymentTransactionId: json['paymentTransactionId']?.toString(),
      relatedOrderId: json['relatedOrderId']?.toString(),
      status: json['status']?.toString() ?? 'COMPLETED',
      source: json['source']?.toString() ?? 'MOBILE_APP',
      message: json['message']?.toString(),
      donatedAt: json['donatedAt']?.toString() ?? json['createdAt']?.toString(),
    );
  }
}


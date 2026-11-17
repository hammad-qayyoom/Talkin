import 'dart:convert';

class PlatformCurrency {
  final String code;
  final String name;
  final String symbol;
  final int decimals;
  final String symbolPosition;

  PlatformCurrency({
    this.code = "CAD",
    this.name = "Canadian Dollar",
    this.symbol = "CA\$",
    this.decimals = 2,
    this.symbolPosition = "before",
  });

  factory PlatformCurrency.fromJson(Map<String, dynamic> json) {
    return PlatformCurrency(
      code: json['code']?.toString().toUpperCase() ?? "CAD",
      name: json['name']?.toString() ?? "Canadian Dollar",
      symbol: json['symbol']?.toString() ?? (json['code'] == "USD" ? "\$" : "CA\$"),
      decimals: (json['decimals'] != null) ? int.tryParse(json['decimals'].toString()) ?? 2 : 2,
      symbolPosition: json['symbolPosition']?.toString() ?? "before",
    );
  }

  String format(num amount) {
    final formatted = amount.toStringAsFixed(decimals);
    if (symbolPosition == "after") {
      return "$formatted $symbol";
    }
    return "$symbol$formatted";
  }
}

class EcosystemProduct {
  String id;
  String title;
  double price;
  double? compareAtPrice;
  double? costPrice;
  String? description;
  String? featuredImage;
  int inventory;
  int lowStockThreshold;
  bool trackInventory;
  String currency;
  String status;
  String? sku;
  String? brand;
  String? categoryId;
  String? categoryName;
  String? badge;
  String? impact;
  String? returnPolicy;
  String? shippingInfo;
  String? productType;
  double? weight;
  List<String> tags;
  List<String> features;
  Map<String, String> specifications;
  List<Map<String, dynamic>> variants;
  List<String> images;
  bool isActive;

  EcosystemProduct({
    required this.id,
    required this.title,
    required this.price,
    this.compareAtPrice,
    this.costPrice,
    this.description,
    this.featuredImage,
    required this.inventory,
    this.lowStockThreshold = 5,
    this.trackInventory = true,
    required this.currency,
    required this.status,
    this.sku,
    this.brand,
    this.categoryId,
    this.categoryName,
    this.badge,
    this.impact,
    this.returnPolicy,
    this.shippingInfo,
    this.productType = "PHYSICAL",
    this.weight,
    this.tags = const [],
    this.features = const [],
    this.specifications = const {},
    this.variants = const [],
    this.images = const [],
    this.isActive = true,
  });

  factory EcosystemProduct.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic raw) {
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw is String && raw.isNotEmpty) return raw.split(',').map((e) => e.trim()).toList();
      return [];
    }

    Map<String, String> parseStringMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      return {};
    }

    List<Map<String, dynamic>> parseVariantList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
      }
      return [];
    }

    final catObj = json['category'] as Map<String, dynamic>?;

    return EcosystemProduct(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      compareAtPrice: (json['compareAtPrice'] != null) ? double.tryParse(json['compareAtPrice'].toString()) : null,
      costPrice: (json['costPrice'] != null) ? double.tryParse(json['costPrice'].toString()) : null,
      description: json['description']?.toString(),
      featuredImage: json['featuredImage']?.toString(),
      inventory: (json['inventory'] != null) ? int.tryParse(json['inventory'].toString()) ?? 0 : 0,
      lowStockThreshold: (json['lowStockThreshold'] != null) ? int.tryParse(json['lowStockThreshold'].toString()) ?? 5 : 5,
      trackInventory: json['trackInventory'] != false,
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'PENDING_REVIEW',
      sku: json['sku']?.toString(),
      brand: json['brand']?.toString(),
      categoryId: catObj?['id']?.toString() ?? json['categoryId']?.toString(),
      categoryName: catObj?['name']?.toString() ?? json['categoryName']?.toString(),
      badge: json['badge']?.toString(),
      impact: json['impact']?.toString(),
      returnPolicy: json['returnPolicy']?.toString(),
      shippingInfo: (json['shippingInfo'] is Map) ? jsonEncode(json['shippingInfo']) : json['shippingInfo']?.toString(),
      productType: json['productType']?.toString() ?? 'PHYSICAL',
      weight: (json['weight'] != null) ? double.tryParse(json['weight'].toString()) : null,
      tags: parseStringList(json['tags']),
      features: parseStringList(json['features']),
      specifications: parseStringMap(json['specifications']),
      variants: parseVariantList(json['variants']),
      images: (json['images'] is List) ? (json['images'] as List).map((i) => (i is Map ? i['url']?.toString() ?? '' : i.toString())).where((s) => s.isNotEmpty).toList() : [],
      isActive: (json['isActive'] == true || json['is_active'] == true) && (json['status'] == 'ACTIVE' || json['status'] == 'APPROVED'),
    );
  }
}

class EcosystemVendorOrderItem {
  String id;
  String productName;
  int quantity;
  double price;
  double total;

  EcosystemVendorOrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory EcosystemVendorOrderItem.fromJson(Map<String, dynamic> json) {
    return EcosystemVendorOrderItem(
      id: json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      quantity: (json['quantity'] != null) ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      total: (json['total'] != null) ? double.tryParse(json['total'].toString()) ?? 0.0 : 0.0,
    );
  }
}

class EcosystemVendorOrder {
  String id;
  String orderNumber;
  String customerName;
  String customerEmail;
  String? shippingAddress;
  double total;
  double vendorEarnings;
  double commissionAmount;
  double commissionRate;
  String status;
  String? trackingNumber;
  String? trackingCarrier;
  String? createdAt;
  String? shippedAt;
  String? deliveredAt;
  bool isCleared;
  String? clearsAt;
  int daysRemaining;
  String clearanceStatus;
  List<EcosystemVendorOrderItem> items;

  EcosystemVendorOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    this.shippingAddress,
    required this.total,
    this.vendorEarnings = 0.0,
    this.commissionAmount = 0.0,
    this.commissionRate = 10.0,
    required this.status,
    this.trackingNumber,
    this.trackingCarrier,
    this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    this.isCleared = false,
    this.clearsAt,
    this.daysRemaining = 0,
    this.clearanceStatus = '',
    this.items = const [],
  });

  factory EcosystemVendorOrder.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<EcosystemVendorOrderItem> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems.map((i) => EcosystemVendorOrderItem.fromJson(i)).toList();
    }

    final rawOrder = (json['order'] is Map<String, dynamic>)
        ? json['order'] as Map<String, dynamic>
        : <String, dynamic>{};

    String custName = json['customerName']?.toString() ?? '';
    if (custName.isEmpty || custName == 'Customer') {
      custName = rawOrder['customerName']?.toString() ?? '';
    }
    if (custName.isEmpty || custName == 'Customer') {
      final fName = rawOrder['firstName']?.toString() ?? '';
      final lName = rawOrder['lastName']?.toString() ?? '';
      final combined = '$fName $lName'.trim();
      if (combined.isNotEmpty) custName = combined;
    }
    if (custName.isEmpty) custName = 'Customer';

    String? shipAddr = json['shippingAddress']?.toString();
    if (shipAddr == null || shipAddr.isEmpty) {
      final rawShip = rawOrder['shippingAddress'];
      if (rawShip is Map) {
        shipAddr = [
          rawShip['address']?.toString(),
          rawShip['city']?.toString(),
          rawShip['state']?.toString(),
          rawShip['country']?.toString(),
        ].where((s) => s != null && s.isNotEmpty).join(', ');
      } else if (rawShip != null) {
        shipAddr = rawShip.toString();
      }
    }

    return EcosystemVendorOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? json['subOrderNumber']?.toString() ?? rawOrder['orderNumber']?.toString() ?? '',
      customerName: custName,
      customerEmail: json['customerEmail']?.toString() ?? rawOrder['email']?.toString() ?? '',
      shippingAddress: shipAddr,
      total: (json['total'] != null)
          ? double.tryParse(json['total'].toString()) ?? 0.0
          : ((json['totalAmount'] != null)
              ? double.tryParse(json['totalAmount'].toString()) ?? 0.0
              : ((json['subtotal'] != null) ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0)),
      vendorEarnings: (json['vendorEarnings'] != null) ? double.tryParse(json['vendorEarnings'].toString()) ?? 0.0 : 0.0,
      commissionAmount: (json['commissionAmount'] != null) ? double.tryParse(json['commissionAmount'].toString()) ?? 0.0 : 0.0,
      commissionRate: (json['commissionRate'] != null) ? double.tryParse(json['commissionRate'].toString()) ?? 10.0 : 10.0,
      status: json['status']?.toString() ?? 'PENDING',
      trackingNumber: json['trackingNumber']?.toString(),
      trackingCarrier: json['trackingCarrier']?.toString() ?? json['shippingCarrier']?.toString(),
      createdAt: json['createdAt']?.toString() ?? rawOrder['createdAt']?.toString(),
      shippedAt: json['shippedAt']?.toString(),
      deliveredAt: json['deliveredAt']?.toString(),
      isCleared: json['isCleared'] == true,
      clearsAt: json['clearsAt']?.toString(),
      daysRemaining: (json['daysRemaining'] != null) ? int.tryParse(json['daysRemaining'].toString()) ?? 0 : 0,
      clearanceStatus: json['clearanceStatus']?.toString() ?? '',
      items: parsedItems,
    );
  }
}

class EcosystemWithdrawal {
  String id;
  double amount;
  String currency;
  String? method;
  String status;
  String? createdAt;
  String? reference;
  String? source;
  String? campaignId;
  String? campaignTitle;

  EcosystemWithdrawal({
    required this.id,
    required this.amount,
    required this.currency,
    this.method,
    required this.status,
    this.createdAt,
    this.reference,
    this.source,
    this.campaignId,
    this.campaignTitle,
  });

  factory EcosystemWithdrawal.fromJson(Map<String, dynamic> json) {
    return EcosystemWithdrawal(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] != null) ? double.tryParse(json['amount'].toString()) ?? 0.0 : 0.0,
      currency: json['currency']?.toString() ?? 'CAD',
      method: json['method']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt']?.toString(),
      reference: json['reference']?.toString(),
      source: json['source']?.toString(),
      campaignId: json['campaignId']?.toString(),
      campaignTitle: json['campaignTitle']?.toString(),
    );
  }
}

class VendorStoreProfile {
  String storeName;
  String? description;
  String? logo;
  String? banner;
  String? website;
  String? storeEmail;
  String? storePhone;
  String? storeAddress;
  String? shippingPolicy;
  String? refundPolicy;
  String? supportInfo;
  String? taxId;
  double commissionRate;
  double rating;
  int reviewCount;
  Map<String, dynamic> socialLinks;

  VendorStoreProfile({
    required this.storeName,
    this.description,
    this.logo,
    this.banner,
    this.website,
    this.storeEmail,
    this.storePhone,
    this.storeAddress,
    this.shippingPolicy,
    this.refundPolicy,
    this.supportInfo,
    this.taxId,
    this.commissionRate = 10.0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.socialLinks = const {},
  });

  factory VendorStoreProfile.fromJson(Map<String, dynamic> json) {
    return VendorStoreProfile(
      storeName: json['storeName']?.toString() ?? json['businessName']?.toString() ?? 'Official Store',
      description: json['description']?.toString(),
      logo: json['logo']?.toString(),
      banner: json['banner']?.toString(),
      website: json['website']?.toString(),
      storeEmail: json['storeEmail']?.toString(),
      storePhone: json['storePhone']?.toString(),
      storeAddress: json['storeAddress']?.toString(),
      shippingPolicy: json['shippingPolicy']?.toString(),
      refundPolicy: json['refundPolicy']?.toString(),
      supportInfo: json['supportInfo']?.toString(),
      taxId: json['taxId']?.toString(),
      commissionRate: (json['commissionRate'] != null) ? double.tryParse(json['commissionRate'].toString()) ?? 10.0 : 10.0,
      rating: (json['rating'] != null) ? double.tryParse(json['rating'].toString()) ?? 0.0 : 0.0,
      reviewCount: (json['reviewCount'] != null) ? int.tryParse(json['reviewCount'].toString()) ?? 0 : 0,
      socialLinks: (json['socialLinks'] is Map) ? Map<String, dynamic>.from(json['socialLinks']) : {},
    );
  }
}

class VendorKycDossier {
  String applicantType;
  String firstName;
  String middleName;
  String lastName;
  String email;
  String phone;
  String citizenship;
  String dateOfBirth;
  String placeOfBirth;
  String residentialAddress;
  String registeredBusinessName;
  String businessType;
  String taxId;
  String governmentIdType;
  String proofOfAddressType;
  String idExpirationDate;
  bool isVerified;
  String status;

  VendorKycDossier({
    required this.applicantType,
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    required this.email,
    this.phone = '',
    this.citizenship = '',
    this.dateOfBirth = '',
    this.placeOfBirth = '',
    this.residentialAddress = '',
    this.registeredBusinessName = '',
    this.businessType = '',
    this.taxId = '',
    this.governmentIdType = "Driver's License",
    this.proofOfAddressType = "Bank Statement",
    this.idExpirationDate = '',
    this.isVerified = false,
    this.status = 'PENDING',
  });

  factory VendorKycDossier.fromJson(Map<String, dynamic> json) {
    return VendorKycDossier(
      applicantType: json['applicantType']?.toString() ?? 'individual',
      firstName: json['firstName']?.toString() ?? '',
      middleName: json['middleName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      citizenship: json['citizenship']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      placeOfBirth: json['placeOfBirth']?.toString() ?? '',
      residentialAddress: json['residentialAddress']?.toString() ?? '',
      registeredBusinessName: json['registeredBusinessName']?.toString() ?? '',
      businessType: json['businessType']?.toString() ?? '',
      taxId: json['taxId']?.toString() ?? '',
      governmentIdType: json['governmentIdType']?.toString() ?? "Driver's License",
      proofOfAddressType: json['proofOfAddressType']?.toString() ?? "Bank Statement",
      idExpirationDate: json['idExpirationDate']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      status: json['status']?.toString() ?? 'VERIFIED & UNLOCKED',
    );
  }
}

class VendorSettings {
  String payoutMethod;
  String bankName;
  String accountHolder;
  String accountNumber;
  String routingNumber;
  int handlingDays;
  bool notifyOrderAlert;
  bool notifyPayoutAlert;
  bool notifyStockAlert;

  VendorSettings({
    this.payoutMethod = 'Bank Transfer',
    this.bankName = '',
    this.accountHolder = '',
    this.accountNumber = '',
    this.routingNumber = '',
    this.handlingDays = 2,
    this.notifyOrderAlert = true,
    this.notifyPayoutAlert = true,
    this.notifyStockAlert = true,
  });

  factory VendorSettings.fromJson(Map<String, dynamic> json) {
    final payout = json['payoutPreferences'] as Map<String, dynamic>? ?? {};
    final store = json['storePreferences'] as Map<String, dynamic>? ?? {};
    final notifs = json['notifications'] as Map<String, dynamic>? ?? {};

    return VendorSettings(
      payoutMethod: payout['method']?.toString() ?? json['payoutMethod']?.toString() ?? 'Bank Transfer',
      bankName: payout['bankName']?.toString() ?? json['bankName']?.toString() ?? '',
      accountHolder: payout['accountHolder']?.toString() ?? json['accountHolder']?.toString() ?? '',
      accountNumber: payout['accountNumber']?.toString() ?? json['accountNumber']?.toString() ?? '',
      routingNumber: payout['routingNumber']?.toString() ?? json['routingNumber']?.toString() ?? '',
      handlingDays: (store['fulfillmentHandlingDays'] != null)
          ? int.tryParse(store['fulfillmentHandlingDays'].toString()) ?? 2
          : (json['handlingDays'] != null ? int.tryParse(json['handlingDays'].toString()) ?? 2 : 2),
      notifyOrderAlert: notifs['newOrderEmail'] != false && json['notifyOrderAlert'] != false,
      notifyPayoutAlert: notifs['payoutProcessed'] != false && json['notifyPayoutAlert'] != false,
      notifyStockAlert: notifs['lowInventoryAlert'] != false && json['notifyStockAlert'] != false,
    );
  }
}

class EcosystemNotificationItem {
  String id;
  String title;
  String message;
  String type;
  bool isRead;
  String createdAt;

  EcosystemNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory EcosystemNotificationItem.fromJson(Map<String, dynamic> json) {
    return EcosystemNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      isRead: json['isRead'] == true || json['read'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class VendorPortalData {
  String storeName;
  String businessType;
  bool isApproved;
  bool isVerified;
  String status;
  double balance;
  double totalRevenue;
  double grossSales;
  double netEarnings;
  double platformCommission;
  double clearedEarnings;
  double pendingEscrowEarnings;
  double escrowPending;
  double pendingPayout;
  double commissionRate;
  int payoutHoldDays;
  double minWithdrawalAmount;
  double totalWithdrawn;
  double pendingWithdrawals;
  int activeProducts;
  int draftProducts;
  int underReviewProducts;
  int totalOrders;
  int pendingOrders;
  int shippedOrders;
  int deliveredOrders;
  int totalCustomers;
  double escrowHolding;
  bool checklistProfileCompleted;
  bool checklistProductAdded;
  bool checklistPayoutConnected;
  int checklistPolicyViolations;
  List<String> categories;
  PlatformCurrency currency;
  VendorStoreProfile? profile;
  VendorKycDossier? dossier;
  VendorSettings? settings;
  List<EcosystemProduct> products;
  List<EcosystemVendorOrder> orders;
  List<EcosystemWithdrawal> withdrawals;
  List<EcosystemNotificationItem> notifications;

  VendorPortalData({
    required this.storeName,
    required this.businessType,
    required this.isApproved,
    this.isVerified = true,
    this.status = 'APPROVED',
    required this.balance,
    required this.totalRevenue,
    this.grossSales = 0.0,
    this.netEarnings = 0.0,
    this.platformCommission = 0.0,
    this.clearedEarnings = 0.0,
    this.pendingEscrowEarnings = 0.0,
    this.escrowPending = 0.0,
    required this.pendingPayout,
    this.commissionRate = 10.0,
    this.payoutHoldDays = 7,
    this.minWithdrawalAmount = 20.0,
    this.totalWithdrawn = 0.0,
    this.pendingWithdrawals = 0.0,
    required this.activeProducts,
    this.draftProducts = 0,
    this.underReviewProducts = 0,
    required this.totalOrders,
    this.pendingOrders = 0,
    this.shippedOrders = 0,
    this.deliveredOrders = 0,
    this.totalCustomers = 0,
    this.escrowHolding = 0.0,
    this.checklistProfileCompleted = false,
    this.checklistProductAdded = false,
    this.checklistPayoutConnected = false,
    this.checklistPolicyViolations = 0,
    this.categories = const [],
    PlatformCurrency? currency,
    this.profile,
    this.dossier,
    this.settings,
    this.products = const [],
    this.orders = const [],
    this.withdrawals = const [],
    this.notifications = const [],
  }) : currency = currency ?? PlatformCurrency();

  factory VendorPortalData.fromJson(Map<String, dynamic> json) {
    final rawCurrency = json['currency'];
    final parsedCurrency = (rawCurrency is Map<String, dynamic>)
        ? PlatformCurrency.fromJson(rawCurrency)
        : PlatformCurrency();

    final rawProfile = json['profile'] as Map<String, dynamic>? ?? {};
    final rawFinancials = json['financials'] as Map<String, dynamic>? ?? {};
    final rawMetrics = (json['metrics'] is Map) ? json['metrics'] as Map<String, dynamic> : rawFinancials;
    final rawChecklist = (json['checklist'] is Map) ? json['checklist'] as Map<String, dynamic> : <String, dynamic>{};
    final rawStats = json['stats'] as Map<String, dynamic>? ?? {};
    final rawDossier = json['dossier'] as Map<String, dynamic>? ?? {};
    final rawSettings = json['settings'] as Map<String, dynamic>? ?? {};

    final rawProducts = json['products'] as List? ?? [];
    final rawOrders = json['orders'] as List? ?? [];
    final rawWithdrawals = json['withdrawals'] as List? ?? [];
    final rawNotifs = json['notifications'] as List? ?? [];
    final rawCategories = (json['categories'] is List)
        ? (json['categories'] as List).map((c) => (c is Map ? c['name']?.toString() ?? '' : c.toString())).where((s) => s.isNotEmpty).toList()
        : <String>[];

    final gross = (rawMetrics['grossSales'] != null)
        ? double.tryParse(rawMetrics['grossSales'].toString()) ?? 0.0
        : (json['totalRevenue'] != null ? double.tryParse(json['totalRevenue'].toString()) ?? 0.0 : 0.0);

    final net = (rawMetrics['netEarnings'] != null)
        ? double.tryParse(rawMetrics['netEarnings'].toString()) ?? 0.0
        : gross;

    final comm = (rawMetrics['platformCommission'] != null)
        ? double.tryParse(rawMetrics['platformCommission'].toString()) ?? 0.0
        : 0.0;

    final avail = (rawMetrics['availableBalance'] != null)
        ? double.tryParse(rawMetrics['availableBalance'].toString()) ?? 0.0
        : (json['balance'] != null ? double.tryParse(json['balance'].toString()) ?? 0.0 : 0.0);

    final escrow = (rawMetrics['escrowHolding'] != null)
        ? double.tryParse(rawMetrics['escrowHolding'].toString()) ?? 0.0
        : ((rawFinancials['escrowPending'] != null) ? double.tryParse(rawFinancials['escrowPending'].toString()) ?? 0.0 : 0.0);

    final cleared = (rawMetrics['clearedEarnings'] != null)
        ? double.tryParse(rawMetrics['clearedEarnings'].toString()) ?? 0.0
        : (json['clearedEarnings'] != null ? double.tryParse(json['clearedEarnings'].toString()) ?? 0.0 : 0.0);

    final pendingEscrow = (rawMetrics['pendingEscrowEarnings'] != null)
        ? double.tryParse(rawMetrics['pendingEscrowEarnings'].toString()) ?? escrow
        : escrow;

    final holdDays = (rawMetrics['payoutHoldDays'] != null)
        ? int.tryParse(rawMetrics['payoutHoldDays'].toString()) ?? 7
        : (json['payoutHoldDays'] != null ? int.tryParse(json['payoutHoldDays'].toString()) ?? 7 : 7);

    final minWithdrawal = (rawMetrics['minWithdrawalAmount'] != null)
        ? double.tryParse(rawMetrics['minWithdrawalAmount'].toString()) ?? 20.0
        : (json['minWithdrawalAmount'] != null ? double.tryParse(json['minWithdrawalAmount'].toString()) ?? 20.0 : 20.0);

    final withdrawn = (rawMetrics['totalWithdrawn'] != null)
        ? double.tryParse(rawMetrics['totalWithdrawn'].toString()) ?? 0.0
        : 0.0;

    final pendingWith = (rawMetrics['pendingWithdrawals'] != null)
        ? double.tryParse(rawMetrics['pendingWithdrawals'].toString()) ?? 0.0
        : 0.0;

    final customers = (rawMetrics['totalCustomers'] != null)
        ? int.tryParse(rawMetrics['totalCustomers'].toString()) ?? 0
        : 0;

    final drafts = (rawMetrics['draftProducts'] != null)
        ? int.tryParse(rawMetrics['draftProducts'].toString()) ?? 0
        : 0;

    final underReview = (rawMetrics['underReviewProducts'] != null)
        ? int.tryParse(rawMetrics['underReviewProducts'].toString()) ?? 0
        : 0;

    return VendorPortalData(
      storeName: rawProfile['storeName']?.toString() ?? json['storeName']?.toString() ?? 'Official Store',
      businessType: rawProfile['businessType']?.toString() ?? json['businessType']?.toString() ?? 'Individual Vendor',
      isApproved: json['isApproved'] == true || json['isUnlocked'] == true,
      isVerified: rawProfile['isVerified'] == true || json['isVerified'] == true || json['isUnlocked'] == true,
      status: json['status']?.toString() ?? 'APPROVED',
      balance: avail,
      totalRevenue: gross,
      grossSales: gross,
      netEarnings: net,
      platformCommission: comm,
      clearedEarnings: cleared,
      pendingEscrowEarnings: pendingEscrow,
      escrowPending: escrow,
      escrowHolding: escrow,
      payoutHoldDays: holdDays,
      minWithdrawalAmount: minWithdrawal,
      totalWithdrawn: withdrawn,
      pendingWithdrawals: pendingWith,
      pendingPayout: (json['pendingPayout'] != null) ? double.tryParse(json['pendingPayout'].toString()) ?? 0.0 : 0.0,
      commissionRate: (rawMetrics['commissionRate'] != null) ? double.tryParse(rawMetrics['commissionRate'].toString()) ?? 10.0 : 10.0,
      activeProducts: (rawMetrics['activeProducts'] != null)
          ? int.tryParse(rawMetrics['activeProducts'].toString()) ?? 0
          : (rawStats['activeProducts'] != null ? int.tryParse(rawStats['activeProducts'].toString()) ?? 0 : 0),
      draftProducts: drafts,
      underReviewProducts: underReview,
      totalOrders: (rawMetrics['totalOrders'] != null)
          ? int.tryParse(rawMetrics['totalOrders'].toString()) ?? 0
          : (rawStats['totalOrders'] != null ? int.tryParse(rawStats['totalOrders'].toString()) ?? 0 : 0),
      pendingOrders: (rawMetrics['pendingOrders'] != null)
          ? int.tryParse(rawMetrics['pendingOrders'].toString()) ?? 0
          : (rawStats['pendingOrders'] != null ? int.tryParse(rawStats['pendingOrders'].toString()) ?? 0 : 0),
      shippedOrders: (rawStats['shippedOrders'] != null) ? int.tryParse(rawStats['shippedOrders'].toString()) ?? 0 : 0,
      deliveredOrders: (rawMetrics['completedOrders'] != null)
          ? int.tryParse(rawMetrics['completedOrders'].toString()) ?? 0
          : (rawStats['deliveredOrders'] != null ? int.tryParse(rawStats['deliveredOrders'].toString()) ?? 0 : 0),
      totalCustomers: customers,
      checklistProfileCompleted: rawChecklist['storeProfileCompleted'] == true,
      checklistProductAdded: rawChecklist['productAdded'] == true,
      checklistPayoutConnected: rawChecklist['payoutConnected'] == true,
      checklistPolicyViolations: (rawChecklist['policyViolations'] != null) ? int.tryParse(rawChecklist['policyViolations'].toString()) ?? 0 : 0,
      categories: rawCategories,
      currency: parsedCurrency,
      profile: rawProfile.isNotEmpty ? VendorStoreProfile.fromJson(rawProfile) : null,
      dossier: rawDossier.isNotEmpty ? VendorKycDossier.fromJson(rawDossier) : null,
      settings: rawSettings.isNotEmpty ? VendorSettings.fromJson(rawSettings) : VendorSettings(),
      products: rawProducts.map((p) => EcosystemProduct.fromJson(p)).toList(),
      orders: rawOrders.map((o) => EcosystemVendorOrder.fromJson(o)).toList(),
      withdrawals: rawWithdrawals.map((w) => EcosystemWithdrawal.fromJson(w)).toList(),
      notifications: rawNotifs.map((n) => EcosystemNotificationItem.fromJson(n)).toList(),
    );
  }
}

class EventTicketTier {
  String id;
  String name;
  double price;
  int quantity;
  int soldCount;
  String description;

  EventTicketTier({
    this.id = '',
    required this.name,
    required this.price,
    this.quantity = 100,
    this.soldCount = 0,
    this.description = '',
  });

  factory EventTicketTier.fromJson(Map<String, dynamic> json) {
    return EventTicketTier(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['tierName']?.toString() ?? 'General Admission',
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      quantity: (json['quantity'] != null)
          ? int.tryParse(json['quantity'].toString()) ?? 100
          : (json['capacity'] != null ? int.tryParse(json['capacity'].toString()) ?? 100 : 100),
      soldCount: (json['soldCount'] != null)
          ? int.tryParse(json['soldCount'].toString()) ?? 0
          : (json['sold'] != null ? int.tryParse(json['sold'].toString()) ?? 0 : 0),
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'soldCount': soldCount,
        'description': description,
      };
}

class EventSettlementPolicy {
  final int payoutHoldDays;
  final String payoutTrigger;
  final bool isEscrowProtectionActive;
  final String policyLabel;
  final double minWithdrawalAmount;

  EventSettlementPolicy({
    this.payoutHoldDays = 7,
    this.payoutTrigger = "EVENT_COMPLETION",
    this.isEscrowProtectionActive = true,
    this.policyLabel = "Event Completion Based",
    this.minWithdrawalAmount = 20.0,
  });

  bool get isImmediateBooking => payoutTrigger == "IMMEDIATE_BOOKING";

  factory EventSettlementPolicy.fromJson(Map<String, dynamic> json) {
    return EventSettlementPolicy(
      payoutHoldDays: int.tryParse(json['payoutHoldDays']?.toString() ?? '7') ?? 7,
      payoutTrigger: json['payoutTrigger']?.toString() ?? 'EVENT_COMPLETION',
      isEscrowProtectionActive: json['isEscrowProtectionActive'] == true,
      policyLabel: json['policyLabel']?.toString() ?? 'Event Completion Based',
      minWithdrawalAmount: double.tryParse(json['minWithdrawalAmount']?.toString() ?? '20.0') ?? 20.0,
    );
  }
}

class EcosystemEvent {
  String id;
  String title;
  String description;
  String? venue;
  String? address;
  String? city;
  String? country;
  bool isOnline;
  String? onlineUrl;
  double priceFrom;
  String startDateTime;
  String endDateTime;
  String timezone;
  int checkInWindowMinutes;
  int maxAttendees;
  int registeredAttendees;
  String status;
  String? featuredImage;
  String? category;
  String? metaTitle;
  String? metaDescription;
  String? changesRequested;
  String? rejectionReason;
  double grossRevenue;
  double commission;
  double netEarnings;
  double escrowAmount;
  String clearanceStatus;
  String fundsReleaseDate;
  bool isCleared;
  String payoutStatus;
  int daysUntilClearance;
  List<EventTicketTier> tickets;

  EcosystemEvent({
    required this.id,
    required this.title,
    required this.description,
    this.venue,
    this.address,
    this.city,
    this.country,
    this.isOnline = false,
    this.onlineUrl,
    required this.priceFrom,
    required this.startDateTime,
    required this.endDateTime,
    this.timezone = "UTC",
    this.checkInWindowMinutes = 30,
    required this.maxAttendees,
    this.registeredAttendees = 0,
    required this.status,
    this.featuredImage,
    this.category,
    this.metaTitle,
    this.metaDescription,
    this.changesRequested,
    this.rejectionReason,
    this.grossRevenue = 0.0,
    this.commission = 0.0,
    this.netEarnings = 0.0,
    this.escrowAmount = 0.0,
    this.clearanceStatus = "CLEARED & AVAILABLE",
    this.fundsReleaseDate = "",
    this.isCleared = true,
    this.payoutStatus = "AVAILABLE",
    this.daysUntilClearance = 0,
    this.tickets = const [],
  });

  DateTime get startDate => DateTime.tryParse(startDateTime) ?? DateTime.now();
  DateTime get endDate => DateTime.tryParse(endDateTime) ?? DateTime.now();

  bool get isCheckInOpen {
    if (checkInWindowMinutes <= 0) return true;
    final openTime = startDate.millisecondsSinceEpoch - (checkInWindowMinutes * 60 * 1000);
    return DateTime.now().millisecondsSinceEpoch >= openTime;
  }

  DateTime get checkInOpensAt {
    final openTime = startDate.millisecondsSinceEpoch - (checkInWindowMinutes * 60 * 1000);
    return DateTime.fromMillisecondsSinceEpoch(openTime);
  }

  factory EcosystemEvent.fromJson(Map<String, dynamic> json) {
    var rawTickets = json['tickets'];
    List<EventTicketTier> parsedTickets = [];
    if (rawTickets is List) {
      parsedTickets = rawTickets.map((t) => EventTicketTier.fromJson(t)).toList();
    }
    return EcosystemEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      venue: json['venue']?.toString(),
      address: json['address']?.toString() ?? json['streetAddress']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      isOnline: json['isOnline'] == true,
      onlineUrl: json['onlineUrl']?.toString(),
      priceFrom: (json['priceFrom'] != null) ? double.tryParse(json['priceFrom'].toString()) ?? 0.0 : 0.0,
      startDateTime: json['startDateTime']?.toString() ?? '',
      endDateTime: json['endDateTime']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'UTC',
      checkInWindowMinutes: (json['checkInWindowMinutes'] != null)
          ? int.tryParse(json['checkInWindowMinutes'].toString()) ?? 30
          : 30,
      maxAttendees: (json['maxAttendees'] != null) ? int.tryParse(json['maxAttendees'].toString()) ?? 0 : 0,
      registeredAttendees: (json['totalAttendees'] != null)
          ? int.tryParse(json['totalAttendees'].toString()) ?? 0
          : ((json['registeredAttendees'] != null)
              ? int.tryParse(json['registeredAttendees'].toString()) ?? 0
              : 0),
      status: json['status']?.toString() ?? 'PUBLISHED',
      featuredImage: json['featuredImage']?.toString(),
      category: json['category'] is Map
          ? json['category']['name']?.toString()
          : json['category']?.toString(),
      metaTitle: json['metaTitle']?.toString(),
      metaDescription: json['metaDescription']?.toString(),
      changesRequested: json['changesRequested']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      grossRevenue: (json['grossRevenue'] != null) ? double.tryParse(json['grossRevenue'].toString()) ?? 0.0 : 0.0,
      commission: (json['commission'] != null) ? double.tryParse(json['commission'].toString()) ?? 0.0 : 0.0,
      netEarnings: (json['netEarnings'] != null) ? double.tryParse(json['netEarnings'].toString()) ?? 0.0 : 0.0,
      escrowAmount: (json['escrowAmount'] != null) ? double.tryParse(json['escrowAmount'].toString()) ?? 0.0 : 0.0,
      clearanceStatus: json['clearanceStatus']?.toString() ?? 'CLEARED & AVAILABLE',
      fundsReleaseDate: json['fundsReleaseDate']?.toString() ?? '',
      isCleared: json['isCleared'] == true || json['payoutStatus'] == 'AVAILABLE' || json['clearanceStatus'] == 'CLEARED & AVAILABLE',
      payoutStatus: json['payoutStatus']?.toString() ?? 'AVAILABLE',
      daysUntilClearance: int.tryParse(json['daysUntilClearance']?.toString() ?? '0') ?? 0,
      tickets: parsedTickets,
    );
  }
}

class EcosystemCampaign {
  String id;
  String title;
  String? description;
  String? beneficiary;
  double goalAmount;
  double raisedAmount;
  String currency;
  String? featuredImage;
  String? startDate;
  String? endDate;
  String status;
  int totalDonors;

  EcosystemCampaign({
    required this.id,
    required this.title,
    this.description,
    this.beneficiary,
    required this.goalAmount,
    this.raisedAmount = 0.0,
    required this.currency,
    this.featuredImage,
    this.startDate,
    this.endDate,
    required this.status,
    this.totalDonors = 0,
  });

  factory EcosystemCampaign.fromJson(Map<String, dynamic> json) {
    return EcosystemCampaign(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      beneficiary: json['beneficiary']?.toString(),
      goalAmount: (json['goalAmount'] != null) ? double.tryParse(json['goalAmount'].toString()) ?? 0.0 : 0.0,
      raisedAmount: (json['raisedAmount'] != null) ? double.tryParse(json['raisedAmount'].toString()) ?? 0.0 : 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      featuredImage: json['featuredImage']?.toString(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      totalDonors: (json['totalDonors'] != null) ? int.tryParse(json['totalDonors'].toString()) ?? 0 : 0,
    );
  }
}

class EcosystemAttendee {
  String id;
  String? eventId;
  String eventTitle;
  String firstName;
  String lastName;
  String email;
  String phone;
  String status;
  String ticketName;
  double ticketPrice;
  int quantity;
  String ticketNumber;
  double totalAmount;
  bool checkedIn;
  String? checkedInAt;
  String? createdAt;

  EcosystemAttendee({
    required this.id,
    this.eventId,
    required this.eventTitle,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    this.ticketName = "General Admission",
    this.ticketPrice = 0.0,
    this.quantity = 1,
    required this.ticketNumber,
    required this.totalAmount,
    this.checkedIn = false,
    this.checkedInAt,
    this.createdAt,
  });

  factory EcosystemAttendee.fromJson(Map<String, dynamic> json) {
    return EcosystemAttendee(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? json['event']?['id']?.toString(),
      eventTitle: json['eventTitle']?.toString() ?? json['event']?['title']?.toString() ?? 'Event',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'CONFIRMED',
      ticketName: json['ticketName']?.toString() ?? json['ticket']?['name']?.toString() ?? 'General Admission',
      ticketPrice: double.tryParse(json['ticketPrice']?.toString() ?? '') ?? (double.tryParse(json['ticket']?['price']?.toString() ?? '') ?? 0.0),
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      ticketNumber: json['ticketNumber']?.toString() ?? json['paymentId']?.toString() ?? json['id']?.toString() ?? '',
      totalAmount: (json['totalAmount'] != null) ? double.tryParse(json['totalAmount'].toString()) ?? 0.0 : 0.0,
      checkedIn: json['checkedIn'] == true,
      checkedInAt: json['checkedInAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class OrganizerProfile {
  String organizationName;
  String organizationType;
  String? description;
  String? website;
  String? email;
  String? phone;
  Map<String, dynamic> socialLinks;

  OrganizerProfile({
    required this.organizationName,
    required this.organizationType,
    this.description,
    this.website,
    this.email,
    this.phone,
    this.socialLinks = const {},
  });

  factory OrganizerProfile.fromJson(Map<String, dynamic> json) {
    return OrganizerProfile(
      organizationName: json['organizationName']?.toString() ?? 'My Organization',
      organizationType: json['organizationType']?.toString() ?? 'Organizer',
      description: json['description']?.toString(),
      website: json['website']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      socialLinks: (json['socialLinks'] is Map) ? Map<String, dynamic>.from(json['socialLinks']) : {},
    );
  }
}

class OrganizerKycDossier {
  String applicantType;
  String firstName;
  String lastName;
  String email;
  String phone;
  String organizationName;
  String organizationType;
  String website;
  String city;
  String country;
  String streetAddress;
  String idDocumentType;
  String idFrontUrl;
  String idBackUrl;
  String bankName;
  String accountHolder;
  String accountNumber;
  String routingNumber;
  String verificationStatus;
  bool isApproved;

  OrganizerKycDossier({
    required this.applicantType,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone = '',
    this.organizationName = '',
    this.organizationType = '',
    this.website = '',
    this.city = '',
    this.country = '',
    this.streetAddress = '',
    this.idDocumentType = 'International Passport',
    this.idFrontUrl = '',
    this.idBackUrl = '',
    this.bankName = '',
    this.accountHolder = '',
    this.accountNumber = '',
    this.routingNumber = '',
    this.verificationStatus = 'VERIFIED & APPROVED',
    this.isApproved = false,
  });

  factory OrganizerKycDossier.fromJson(Map<String, dynamic> json) {
    return OrganizerKycDossier(
      applicantType: json['applicantType']?.toString() ?? 'individual',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      organizationName: json['organizationName']?.toString() ?? '',
      organizationType: json['organizationType']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      streetAddress: json['streetAddress']?.toString() ?? '',
      idDocumentType: json['idDocumentType']?.toString() ?? 'International Passport',
      idFrontUrl: json['idFrontUrl']?.toString() ?? '',
      idBackUrl: json['idBackUrl']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? json['bankDetails']?['bankName']?.toString() ?? '',
      accountHolder: json['accountHolder']?.toString() ?? json['bankDetails']?['accountHolder']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? json['bankDetails']?['accountNumber']?.toString() ?? '',
      routingNumber: json['routingNumber']?.toString() ?? json['bankDetails']?['routingNumber']?.toString() ?? '',
      verificationStatus: json['verificationStatus']?.toString() ?? (json['isApproved'] == true ? 'VERIFIED & APPROVED' : 'ACTION REQUIRED'),
      isApproved: json['isApproved'] == true,
    );
  }
}

class OrganizerSettings {
  String payoutMethod;
  String settlementSchedule;
  String bankName;
  String accountHolder;
  String accountNumber;
  String routingNumber;
  int defaultCheckInWindow;
  String defaultRefundPolicy;
  bool notifyRegistrationAlert;
  bool notifyDonationAlert;
  bool notifyEventReminder;

  OrganizerSettings({
    this.payoutMethod = 'Direct Bank Wire / Local Transfer',
    this.settlementSchedule = 'Weekly Auto-Settlement (Recommended)',
    this.bankName = '',
    this.accountHolder = '',
    this.accountNumber = '',
    this.routingNumber = '',
    this.defaultCheckInWindow = 30,
    this.defaultRefundPolicy = '30-Day Policy',
    this.notifyRegistrationAlert = true,
    this.notifyDonationAlert = true,
    this.notifyEventReminder = true,
  });

  factory OrganizerSettings.fromJson(Map<String, dynamic> json) {
    return OrganizerSettings(
      payoutMethod: json['payoutMethod']?.toString() ?? 'Direct Bank Wire / Local Transfer',
      settlementSchedule: json['settlementSchedule']?.toString() ?? 'Weekly Auto-Settlement (Recommended)',
      bankName: json['bankName']?.toString() ?? '',
      accountHolder: json['accountHolder']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      routingNumber: json['routingNumber']?.toString() ?? '',
      defaultCheckInWindow: int.tryParse(json['defaultCheckInWindow']?.toString() ?? '30') ?? 30,
      defaultRefundPolicy: json['defaultRefundPolicy']?.toString() ?? '30-Day Policy',
      notifyRegistrationAlert: json['notifyRegistrationAlert'] != false,
      notifyDonationAlert: json['notifyDonationAlert'] != false,
      notifyEventReminder: json['notifyEventReminder'] != false,
    );
  }
}

class FundraisingCampaignFinancialItem {
  final String campaignId;
  final String title;
  final String slug;
  final String status;
  final String currency;
  final double goalAmount;
  final double raisedAmount;
  final double grossCollected;
  final double commissionDeducted;
  final double gatewayFees;
  final double netEarnings;
  final double pendingSettlement;
  final double clearedEntitlement;
  final double reservedWithdrawals;
  final double totalWithdrawn;
  final double availableBalance;
  final String? nextClearingDate;
  final int donationsCount;
  final int payoutHoldDays;

  FundraisingCampaignFinancialItem({
    required this.campaignId,
    required this.title,
    required this.slug,
    required this.status,
    required this.currency,
    required this.goalAmount,
    required this.raisedAmount,
    required this.grossCollected,
    required this.commissionDeducted,
    required this.gatewayFees,
    required this.netEarnings,
    required this.pendingSettlement,
    required this.clearedEntitlement,
    required this.reservedWithdrawals,
    required this.totalWithdrawn,
    required this.availableBalance,
    this.nextClearingDate,
    required this.donationsCount,
    required this.payoutHoldDays,
  });

  factory FundraisingCampaignFinancialItem.fromJson(Map<String, dynamic> json) {
    return FundraisingCampaignFinancialItem(
      campaignId: json['campaignId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
      currency: json['currency']?.toString() ?? 'CAD',
      goalAmount: double.tryParse(json['goalAmount']?.toString() ?? '') ?? 0.0,
      raisedAmount: double.tryParse(json['raisedAmount']?.toString() ?? '') ?? 0.0,
      grossCollected: double.tryParse(json['grossCollected']?.toString() ?? '') ?? 0.0,
      commissionDeducted: double.tryParse(json['commissionDeducted']?.toString() ?? '') ?? 0.0,
      gatewayFees: double.tryParse(json['gatewayFees']?.toString() ?? '') ?? 0.0,
      netEarnings: double.tryParse(json['netEarnings']?.toString() ?? '') ?? 0.0,
      pendingSettlement: double.tryParse(json['pendingSettlement']?.toString() ?? '') ?? 0.0,
      clearedEntitlement: double.tryParse(json['clearedEntitlement']?.toString() ?? '') ?? 0.0,
      reservedWithdrawals: double.tryParse(json['reservedWithdrawals']?.toString() ?? '') ?? 0.0,
      totalWithdrawn: double.tryParse(json['totalWithdrawn']?.toString() ?? '') ?? 0.0,
      availableBalance: double.tryParse(json['availableBalance']?.toString() ?? '') ?? 0.0,
      nextClearingDate: json['nextClearingDate']?.toString(),
      donationsCount: int.tryParse(json['donationsCount']?.toString() ?? '') ?? 0,
      payoutHoldDays: int.tryParse(json['payoutHoldDays']?.toString() ?? '') ?? 0,
    );
  }
}

class FundraisingFinancials {
  final double totalGrossCollected;
  final double totalCommissionDeducted;
  final double totalGatewayFees;
  final double totalNetEarnings;
  final double pendingSettlement;
  final double availableForWithdrawal;
  final double reservedWithdrawals;
  final double totalWithdrawn;
  final int campaignCount;
  final int payoutHoldDays;
  final String feeResponsibility;
  final bool kycApproved;
  final double minWithdrawalAmount;
  final double commissionRate;
  final List<FundraisingCampaignFinancialItem> campaigns;

  FundraisingFinancials({
    required this.totalGrossCollected,
    required this.totalCommissionDeducted,
    required this.totalGatewayFees,
    required this.totalNetEarnings,
    required this.pendingSettlement,
    required this.availableForWithdrawal,
    required this.reservedWithdrawals,
    required this.totalWithdrawn,
    required this.campaignCount,
    required this.payoutHoldDays,
    required this.feeResponsibility,
    required this.kycApproved,
    required this.minWithdrawalAmount,
    required this.commissionRate,
    required this.campaigns,
  });

  factory FundraisingFinancials.fromJson(Map<String, dynamic> json) {
    final rawCamps = json['campaigns'] as List? ?? [];
    return FundraisingFinancials(
      totalGrossCollected: double.tryParse(json['totalGrossCollected']?.toString() ?? '') ?? 0.0,
      totalCommissionDeducted: double.tryParse(json['totalCommissionDeducted']?.toString() ?? '') ?? 0.0,
      totalGatewayFees: double.tryParse(json['totalGatewayFees']?.toString() ?? '') ?? 0.0,
      totalNetEarnings: double.tryParse(json['totalNetEarnings']?.toString() ?? '') ?? 0.0,
      pendingSettlement: double.tryParse(json['pendingSettlement']?.toString() ?? '') ?? 0.0,
      availableForWithdrawal: double.tryParse(json['availableForWithdrawal']?.toString() ?? '') ?? 0.0,
      reservedWithdrawals: double.tryParse(json['reservedWithdrawals']?.toString() ?? '') ?? 0.0,
      totalWithdrawn: double.tryParse(json['totalWithdrawn']?.toString() ?? '') ?? 0.0,
      campaignCount: int.tryParse(json['campaignCount']?.toString() ?? '') ?? rawCamps.length,
      payoutHoldDays: int.tryParse(json['payoutHoldDays']?.toString() ?? '') ?? 0,
      feeResponsibility: json['feeResponsibility']?.toString() ?? 'FOUNDATION_ABSORBS',
      kycApproved: json['kycApproved'] == true,
      minWithdrawalAmount: double.tryParse(json['minWithdrawalAmount']?.toString() ?? '') ?? 20.0,
      commissionRate: double.tryParse(json['commissionRate']?.toString() ?? '') ?? 2.0,
      campaigns: rawCamps.map((c) => FundraisingCampaignFinancialItem.fromJson(c)).toList(),
    );
  }
}

class OrganizerPortalData {
  String referenceId;
  String fundraiserReferenceId;
  String organizationName;
  String organizationType;
  bool isApproved;
  double balance;
  double grossRevenue;
  double commission;
  double netEarnings;
  double availableBalance;
  double escrowHolding;
  double totalPaidOut;
  double processingWithdrawals;
  int totalEvents;
  int publishedEvents;
  int pendingEvents;
  int draftEvents;
  int changesRequestedEvents;
  int completedEvents;
  int totalTicketsSold;
  int totalCampaigns;
  int totalAttendees;
  double totalRevenue;
  double totalRaised;
  List<String> categories;
  PlatformCurrency currency;
  OrganizerProfile? profileData;
  OrganizerKycDossier? dossier;
  OrganizerSettings? settings;
  FundraisingFinancials? fundraising;
  EventSettlementPolicy? settlementPolicy;
  List<EcosystemEvent> events;
  List<EcosystemCampaign> campaigns;
  List<EcosystemAttendee> attendees;
  List<EcosystemWithdrawal> withdrawals;
  List<EcosystemNotificationItem> notifications;

  OrganizerPortalData({
    this.referenceId = 'ORG-FOUNDATION-9281',
    this.fundraiserReferenceId = 'FR-ORG-7781',
    required this.organizationName,
    required this.organizationType,
    required this.isApproved,
    required this.balance,
    this.grossRevenue = 0.0,
    this.commission = 0.0,
    this.netEarnings = 0.0,
    this.availableBalance = 0.0,
    this.escrowHolding = 0.0,
    this.totalPaidOut = 0.0,
    this.processingWithdrawals = 0.0,
    required this.totalEvents,
    this.publishedEvents = 0,
    this.pendingEvents = 0,
    this.draftEvents = 0,
    this.changesRequestedEvents = 0,
    this.completedEvents = 0,
    this.totalTicketsSold = 0,
    required this.totalCampaigns,
    required this.totalAttendees,
    required this.totalRevenue,
    required this.totalRaised,
    this.categories = const [],
    PlatformCurrency? currency,
    this.profileData,
    this.dossier,
    this.settings,
    this.fundraising,
    this.settlementPolicy,
    this.events = const [],
    this.campaigns = const [],
    this.attendees = const [],
    this.withdrawals = const [],
    this.notifications = const [],
  }) : currency = currency ?? PlatformCurrency();

  factory OrganizerPortalData.fromJson(Map<String, dynamic> json) {
    final rawCurrency = json['currency'];
    final parsedCurrency = (rawCurrency is Map<String, dynamic>)
        ? PlatformCurrency.fromJson(rawCurrency)
        : PlatformCurrency();

    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final dossierJson = json['dossier'] as Map<String, dynamic>? ?? {};
    final settingsJson = json['settings'] as Map<String, dynamic>? ?? {};
    final fundJson = json['fundraising'] as Map<String, dynamic>?;

    final rawEvents = json['events'] as List? ?? [];
    final rawCampaigns = json['campaigns'] as List? ?? [];
    final rawAttendees = json['attendees'] as List? ?? [];
    final rawWithdrawals = json['withdrawals'] as List? ?? [];
    final rawNotifs = json['notifications'] as List? ?? [];
    final rawCats = json['categories'] as List? ?? [];

    final parsedCategories = rawCats.map((c) {
      if (c is Map) return c['name']?.toString() ?? '';
      return c.toString();
    }).where((s) => s.isNotEmpty).toList();

    return OrganizerPortalData(
      referenceId: json['referenceId']?.toString() ?? profile['id']?.toString() ?? 'ORG-FOUNDATION-9281',
      fundraiserReferenceId: json['fundraiserReferenceId']?.toString() ?? 'FR-ORG-7781',
      organizationName: profile['organizationName']?.toString() ?? json['organizationName']?.toString() ?? 'My Organization',
      organizationType: profile['organizationType']?.toString() ?? json['organizationType']?.toString() ?? 'Organizer',
      isApproved: profile['isApproved'] == true || json['isApproved'] == true,
      balance: (stats['availableBalance'] != null)
          ? double.tryParse(stats['availableBalance'].toString()) ?? 0.0
          : ((profile['balance'] != null)
              ? double.tryParse(profile['balance'].toString()) ?? 0.0
              : (json['balance'] != null ? double.tryParse(json['balance'].toString()) ?? 0.0 : 0.0)),
      grossRevenue: (stats['grossRevenue'] != null) ? double.tryParse(stats['grossRevenue'].toString()) ?? 0.0 : 0.0,
      commission: (stats['commission'] != null) ? double.tryParse(stats['commission'].toString()) ?? 0.0 : 0.0,
      netEarnings: (stats['netEarnings'] != null) ? double.tryParse(stats['netEarnings'].toString()) ?? 0.0 : 0.0,
      availableBalance: (stats['availableBalance'] != null) ? double.tryParse(stats['availableBalance'].toString()) ?? 0.0 : 0.0,
      escrowHolding: (stats['escrowHolding'] != null) ? double.tryParse(stats['escrowHolding'].toString()) ?? 0.0 : 0.0,
      totalPaidOut: (stats['totalPaidOut'] != null) ? double.tryParse(stats['totalPaidOut'].toString()) ?? 0.0 : 0.0,
      processingWithdrawals: (stats['processingWithdrawals'] != null) ? double.tryParse(stats['processingWithdrawals'].toString()) ?? 0.0 : 0.0,
      totalEvents: (stats['totalEvents'] != null) ? int.tryParse(stats['totalEvents'].toString()) ?? 0 : rawEvents.length,
      publishedEvents: (stats['publishedEvents'] != null) ? int.tryParse(stats['publishedEvents'].toString()) ?? 0 : 0,
      pendingEvents: (stats['pendingEvents'] != null) ? int.tryParse(stats['pendingEvents'].toString()) ?? 0 : 0,
      draftEvents: (stats['draftEvents'] != null) ? int.tryParse(stats['draftEvents'].toString()) ?? 0 : 0,
      changesRequestedEvents: (stats['changesRequestedEvents'] != null) ? int.tryParse(stats['changesRequestedEvents'].toString()) ?? 0 : 0,
      completedEvents: (stats['completedEvents'] != null) ? int.tryParse(stats['completedEvents'].toString()) ?? 0 : 0,
      totalTicketsSold: (stats['totalTicketsSold'] != null) ? int.tryParse(stats['totalTicketsSold'].toString()) ?? 0 : 0,
      totalCampaigns: (stats['totalCampaigns'] != null) ? int.tryParse(stats['totalCampaigns'].toString()) ?? 0 : rawCampaigns.length,
      totalAttendees: (stats['totalAttendees'] != null) ? int.tryParse(stats['totalAttendees'].toString()) ?? 0 : rawAttendees.length,
      totalRevenue: (stats['totalRevenue'] != null) ? double.tryParse(stats['totalRevenue'].toString()) ?? 0.0 : 0.0,
      totalRaised: (stats['totalRaised'] != null) ? double.tryParse(stats['totalRaised'].toString()) ?? 0.0 : 0.0,
      categories: parsedCategories,
      currency: parsedCurrency,
      profileData: profile.isNotEmpty ? OrganizerProfile.fromJson(profile) : null,
      dossier: dossierJson.isNotEmpty ? OrganizerKycDossier.fromJson(dossierJson) : null,
      settings: settingsJson.isNotEmpty ? OrganizerSettings.fromJson(settingsJson) : OrganizerSettings(),
      fundraising: fundJson != null ? FundraisingFinancials.fromJson(fundJson) : null,
      settlementPolicy: json['settlementPolicy'] != null ? EventSettlementPolicy.fromJson(json['settlementPolicy']) : EventSettlementPolicy(),
      events: rawEvents.map((e) => EcosystemEvent.fromJson(e)).toList(),
      campaigns: rawCampaigns.map((c) => EcosystemCampaign.fromJson(c)).toList(),
      attendees: rawAttendees.map((a) => EcosystemAttendee.fromJson(a)).toList(),
      withdrawals: rawWithdrawals.map((w) => EcosystemWithdrawal.fromJson(w)).toList(),
      notifications: rawNotifs.map((n) => EcosystemNotificationItem.fromJson(n)).toList(),
    );
  }
}

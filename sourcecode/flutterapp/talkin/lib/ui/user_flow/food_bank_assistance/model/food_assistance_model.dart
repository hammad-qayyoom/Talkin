int _toInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? fallback;
  }
  return fallback;
}

class FoodBankCountry {
  final String id;
  final String code;
  final String name;
  final String currency;
  final bool isActive;
  final List<FoodBankProvince> provinces;

  FoodBankCountry({
    required this.id,
    required this.code,
    required this.name,
    this.currency = 'CAD',
    this.isActive = true,
    this.provinces = const [],
  });

  factory FoodBankCountry.fromJson(Map<String, dynamic> json) {
    return FoodBankCountry(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'CAD',
      isActive: json['isActive'] == true,
      provinces: (json['provinces'] as List<dynamic>?)
              ?.map((p) => FoodBankProvince.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FoodBankProvince {
  final String id;
  final String name;
  final String code;
  final bool isActive;
  final List<FoodBankCity> cities;

  FoodBankProvince({
    required this.id,
    required this.name,
    required this.code,
    this.isActive = true,
    this.cities = const [],
  });

  factory FoodBankProvince.fromJson(Map<String, dynamic> json) {
    return FoodBankProvince(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['isActive'] == true,
      cities: (json['cities'] as List<dynamic>?)
              ?.map((c) => FoodBankCity.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FoodBankDeliveryZone {
  final String id;
  final String name;
  final List<String> postalPrefixes;
  final bool isActive;
  final int maxDailyOrders;
  final List<String> deliveryDays;
  final List<String> timeWindows;

  FoodBankDeliveryZone({
    required this.id,
    required this.name,
    this.postalPrefixes = const [],
    this.isActive = true,
    this.maxDailyOrders = 25,
    this.deliveryDays = const [],
    this.timeWindows = const [],
  });

  factory FoodBankDeliveryZone.fromJson(Map<String, dynamic> json) {
    return FoodBankDeliveryZone(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      postalPrefixes: (json['postalPrefixes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] == true,
      maxDailyOrders: _toInt(json['maxDailyOrders'], 25),
      deliveryDays: (json['deliveryDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timeWindows: (json['timeWindows'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class FoodBankPickupLocation {
  final String id;
  final String name;
  final String address;
  final String contactPhone;
  final String operatingHours;
  final bool isActive;

  FoodBankPickupLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.contactPhone,
    required this.operatingHours,
    this.isActive = true,
  });

  factory FoodBankPickupLocation.fromJson(Map<String, dynamic> json) {
    return FoodBankPickupLocation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      operatingHours: json['operatingHours']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }
}

class FoodBankCity {
  final String id;
  final String name;
  final bool isActive;
  final int serviceRadiusKm;
  final int dailyCapacity;
  final int maxItemsPerRequest;
  final int requestCooldownDays;
  final String contactEmail;
  final String contactPhone;
  final String operatingNotes;
  final List<FoodBankDeliveryZone> zones;
  final List<FoodBankPickupLocation> pickupLocations;

  FoodBankCity({
    required this.id,
    required this.name,
    this.isActive = true,
    this.serviceRadiusKm = 35,
    this.dailyCapacity = 60,
    this.maxItemsPerRequest = 4,
    this.requestCooldownDays = 14,
    this.contactEmail = '',
    this.contactPhone = '',
    this.operatingNotes = '',
    this.zones = const [],
    this.pickupLocations = const [],
  });

  factory FoodBankCity.fromJson(Map<String, dynamic> json) {
    return FoodBankCity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isActive: json['isActive'] == true,
      serviceRadiusKm: _toInt(json['serviceRadiusKm'], 35),
      dailyCapacity: _toInt(json['dailyCapacity'], 60),
      maxItemsPerRequest: _toInt(json['maxItemsPerRequest'], 4),
      requestCooldownDays: _toInt(json['requestCooldownDays'], 14),
      contactEmail: json['contactEmail']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      operatingNotes: json['operatingNotes']?.toString() ?? '',
      zones: (json['zones'] as List<dynamic>?)
              ?.map((z) => FoodBankDeliveryZone.fromJson(z as Map<String, dynamic>))
              .toList() ??
          [],
      pickupLocations: (json['pickupLocations'] as List<dynamic>?)
              ?.map((pl) => FoodBankPickupLocation.fromJson(pl as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FoodBankOperationSettings {
  final String id;
  final bool isPlatformEnabled;
  final String platformName;
  final int defaultCooldownDays;
  final int maxProductTypesPerOrder;
  final bool emergencyOverride;

  FoodBankOperationSettings({
    required this.id,
    this.isPlatformEnabled = true,
    this.platformName = 'Worldwide Food Bank',
    this.defaultCooldownDays = 14,
    this.maxProductTypesPerOrder = 4,
    this.emergencyOverride = false,
  });

  factory FoodBankOperationSettings.fromJson(Map<String, dynamic> json) {
    return FoodBankOperationSettings(
      id: json['id']?.toString() ?? '',
      isPlatformEnabled: json['isPlatformEnabled'] != false,
      platformName: json['platformName']?.toString() ?? 'Worldwide Food Bank',
      defaultCooldownDays: _toInt(json['defaultCooldownDays'], 14),
      maxProductTypesPerOrder: _toInt(json['maxProductTypesPerOrder'], 4),
      emergencyOverride: json['emergencyOverride'] == true,
    );
  }
}

class FoodBankProduct {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String? imageUrl;
  final String packageSize;
  final int inventoryCount;
  final int reservedCount;
  final int maxPerRequest;
  final String? allergenInfo;
  final List<String> dietaryTags;
  final String status;
  final int sortOrder;

  FoodBankProduct({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.imageUrl,
    this.packageSize = 'Standard Pack',
    this.inventoryCount = 0,
    this.reservedCount = 0,
    this.maxPerRequest = 1,
    this.allergenInfo,
    this.dietaryTags = const [],
    this.status = 'AVAILABLE',
    this.sortOrder = 0,
  });

  int get availableCount => (inventoryCount - reservedCount).clamp(0, 99999);
  bool get isAvailable => status == 'AVAILABLE' && availableCount > 0;

  factory FoodBankProduct.fromJson(Map<String, dynamic> json) {
    return FoodBankProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'GRAINS',
      imageUrl: json['imageUrl']?.toString(),
      packageSize: json['packageSize']?.toString() ?? 'Standard Pack',
      inventoryCount: _toInt(json['inventoryCount'], 0),
      reservedCount: _toInt(json['reservedCount'], 0),
      maxPerRequest: _toInt(json['maxPerRequest'], 1),
      allergenInfo: json['allergenInfo']?.toString(),
      dietaryTags: (json['dietaryTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status']?.toString() ?? 'AVAILABLE',
      sortOrder: _toInt(json['sortOrder'], 0),
    );
  }
}

class BeneficiaryProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String streetAddress;
  final String? unit;
  final String postalCode;
  final int householdAdults;
  final int householdChildren;
  final int householdSeniors;
  final String status; // PENDING_REVIEW, APPROVED, REJECTED, INFO_REQUIRED
  final String? reviewerNotes;
  final String? verifiedAt;

  BeneficiaryProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.streetAddress,
    this.unit,
    required this.postalCode,
    this.householdAdults = 1,
    this.householdChildren = 0,
    this.householdSeniors = 0,
    required this.status,
    this.reviewerNotes,
    this.verifiedAt,
  });

  int get totalHouseholdMembers => householdAdults + householdChildren + householdSeniors;
  bool get isApproved => status == 'APPROVED';

  factory BeneficiaryProfile.fromJson(Map<String, dynamic> json) {
    return BeneficiaryProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      streetAddress: json['streetAddress']?.toString() ?? '',
      unit: json['unit']?.toString(),
      postalCode: json['postalCode']?.toString() ?? '',
      householdAdults: _toInt(json['householdAdults'], 1),
      householdChildren: _toInt(json['householdChildren'], 0),
      householdSeniors: _toInt(json['householdSeniors'], 0),
      status: json['status']?.toString() ?? 'PENDING_REVIEW',
      reviewerNotes: json['reviewerNotes']?.toString(),
      verifiedAt: json['verifiedAt']?.toString(),
    );
  }
}

class FoodBankOrderItemRecord {
  final String id;
  final String productId;
  final String productName;
  final String packageSize;
  final int quantity;

  FoodBankOrderItemRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.packageSize,
    required this.quantity,
  });

  factory FoodBankOrderItemRecord.fromJson(Map<String, dynamic> json) {
    return FoodBankOrderItemRecord(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      packageSize: json['packageSize']?.toString() ?? 'Standard Pack',
      quantity: _toInt(json['quantity'], 1),
    );
  }
}

class FoodBankOrderRecord {
  final String id;
  final String orderNumber;
  final String beneficiaryName;
  final String beneficiaryEmail;
  final String beneficiaryPhone;
  final String deliveryType; // HOME_DELIVERY, PICKUP_POINT
  final String? deliveryStreet;
  final String? deliveryUnit;
  final String? deliveryPostalCode;
  final String? deliveryNotes;
  final String? pickupLocationName;
  final String status; // SUBMITTED, APPROVED, PACKING, ASSIGNED, OUT_FOR_DELIVERY, DELIVERED, CANCELLED, DELIVERY_FAILED
  final String? assignedDriverName;
  final String? assignedDriverPhone;
  final String createdAt;
  final List<FoodBankOrderItemRecord> items;

  FoodBankOrderRecord({
    required this.id,
    required this.orderNumber,
    required this.beneficiaryName,
    required this.beneficiaryEmail,
    required this.beneficiaryPhone,
    required this.deliveryType,
    this.deliveryStreet,
    this.deliveryUnit,
    this.deliveryPostalCode,
    this.deliveryNotes,
    this.pickupLocationName,
    required this.status,
    this.assignedDriverName,
    this.assignedDriverPhone,
    required this.createdAt,
    this.items = const [],
  });

  factory FoodBankOrderRecord.fromJson(Map<String, dynamic> json) {
    return FoodBankOrderRecord(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      beneficiaryName: json['beneficiaryName']?.toString() ?? '',
      beneficiaryEmail: json['beneficiaryEmail']?.toString() ?? '',
      beneficiaryPhone: json['beneficiaryPhone']?.toString() ?? '',
      deliveryType: json['deliveryType']?.toString() ?? 'HOME_DELIVERY',
      deliveryStreet: json['deliveryStreet']?.toString(),
      deliveryUnit: json['deliveryUnit']?.toString(),
      deliveryPostalCode: json['deliveryPostalCode']?.toString(),
      deliveryNotes: json['deliveryNotes']?.toString(),
      pickupLocationName: json['pickupLocation'] != null ? json['pickupLocation']['name']?.toString() : null,
      status: json['status']?.toString() ?? 'SUBMITTED',
      assignedDriverName: json['assignedPersonnel'] != null ? json['assignedPersonnel']['name']?.toString() : null,
      assignedDriverPhone: json['assignedPersonnel'] != null ? json['assignedPersonnel']['phone']?.toString() : null,
      createdAt: json['createdAt']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => FoodBankOrderItemRecord.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

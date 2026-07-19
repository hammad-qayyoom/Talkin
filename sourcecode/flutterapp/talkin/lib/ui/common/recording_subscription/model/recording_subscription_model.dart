class RecordingStoragePlanModel {
  final String? id;
  final String? name;
  final String? slug;
  final String? description;
  final String? appleProductId;
  final String? googleProductId;
  final num? price;
  final String? currency;
  final String? billingCycle;
  final int? storageDays;
  final List<String>? features;
  final bool isPopular;

  RecordingStoragePlanModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.appleProductId,
    this.googleProductId,
    this.price,
    this.currency,
    this.billingCycle,
    this.storageDays,
    this.features,
    this.isPopular = false,
  });

  factory RecordingStoragePlanModel.fromJson(Map<String, dynamic> json) {
    return RecordingStoragePlanModel(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      appleProductId: json['appleProductId']?.toString(),
      googleProductId: json['googleProductId']?.toString(),
      price: json['price'] as num?,
      currency: json['currency']?.toString(),
      billingCycle: json['billingCycle']?.toString(),
      storageDays: json['storageDays'] as int?,
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      isPopular: json['isPopular'] ?? false,
    );
  }
}

class RecordingSubscriptionModel {
  final String? id;
  final String? userId;
  final String? status;
  final String? role;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? gracePeriodEndsAt;

  RecordingSubscriptionModel({
    this.id,
    this.userId,
    this.status,
    this.role,
    this.startsAt,
    this.endsAt,
    this.gracePeriodEndsAt,
  });

  factory RecordingSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return RecordingSubscriptionModel(
      id: json['_id']?.toString(),
      userId: json['userId']?.toString(),
      status: json['status']?.toString(),
      role: json['role']?.toString(),
      startsAt: json['startsAt'] != null ? DateTime.tryParse(json['startsAt'].toString()) : null,
      endsAt: json['endsAt'] != null ? DateTime.tryParse(json['endsAt'].toString()) : null,
      gracePeriodEndsAt: json['gracePeriodEndsAt'] != null ? DateTime.tryParse(json['gracePeriodEndsAt'].toString()) : null,
    );
  }
}

class ConsultationRecordingModel {
  final String? id;
  final String? callId;
  final String? callType;
  final String? status;
  final String? cloudStorageUrl;
  final num? durationSeconds;
  final DateTime? recordedAt;
  final bool isAccessible;
  
  final Map<String, dynamic>? expert;
  final Map<String, dynamic>? user;

  ConsultationRecordingModel({
    this.id,
    this.callId,
    this.callType,
    this.status,
    this.cloudStorageUrl,
    this.durationSeconds,
    this.recordedAt,
    this.isAccessible = true,
    this.expert,
    this.user,
  });

  factory ConsultationRecordingModel.fromJson(Map<String, dynamic> json) {
    return ConsultationRecordingModel(
      id: json['_id']?.toString(),
      callId: json['callId']?.toString(),
      callType: json['callType']?.toString(),
      status: json['status']?.toString(),
      cloudStorageUrl: json['cloudStorageUrl']?.toString(),
      durationSeconds: json['durationSeconds'] as num?,
      recordedAt: json['recordedAt'] != null ? DateTime.tryParse(json['recordedAt'].toString()) : null,
      isAccessible: json['isAccessible'] ?? true,
      expert: json['expertId'] as Map<String, dynamic>?,
      user: json['userId'] as Map<String, dynamic>?,
    );
  }
}

class RecordingEligibilityModel {
  final bool eligible;
  final bool userSubscriptionActive;
  final bool expertSubscriptionActive;
  final String? reason;
  final String? message;

  RecordingEligibilityModel({
    required this.eligible,
    required this.userSubscriptionActive,
    required this.expertSubscriptionActive,
    this.reason,
    this.message,
  });

  factory RecordingEligibilityModel.fromJson(Map<String, dynamic> json) {
    return RecordingEligibilityModel(
      eligible: json['eligible'] ?? false,
      userSubscriptionActive: json['userSubscriptionActive'] ?? false,
      expertSubscriptionActive: json['expertSubscriptionActive'] ?? false,
      reason: json['reason']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

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
  final int maxRecordingMinutes;
  final bool unlimitedStorage;
  final int retentionDays;
  final bool unlimitedRetention;
  final int gracePeriodDays;
  final String targetUserType;
  final String planVisibility;
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
    this.maxRecordingMinutes = 0,
    this.unlimitedStorage = false,
    this.retentionDays = 30,
    this.unlimitedRetention = false,
    this.gracePeriodDays = 14,
    this.targetUserType = 'both',
    this.planVisibility = 'public',
    this.features,
    this.isPopular = false,
  });

  bool get hasStorageLimit => !unlimitedStorage && maxRecordingMinutes > 0;
  bool get hasRetentionLimit => !unlimitedRetention;

  String get storageLimitDisplay {
    if (unlimitedStorage || maxRecordingMinutes == 0) return 'Unlimited';
    if (maxRecordingMinutes >= 60) {
      final hours = maxRecordingMinutes ~/ 60;
      final mins = maxRecordingMinutes % 60;
      return mins > 0 ? '$hours hr $mins min' : '$hours hr';
    }
    return '$maxRecordingMinutes min';
  }

  String get retentionDisplay {
    if (unlimitedRetention) return 'Unlimited';
    if (retentionDays >= 365) {
      final years = retentionDays ~/ 365;
      return '$years year${years > 1 ? 's' : ''}';
    }
    if (retentionDays >= 30) {
      final months = retentionDays ~/ 30;
      return '$months month${months > 1 ? 's' : ''}';
    }
    return '$retentionDays days';
  }

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
      maxRecordingMinutes: json['maxRecordingMinutes'] as int? ?? 0,
      unlimitedStorage: json['unlimitedStorage'] ?? false,
      retentionDays: json['retentionDays'] as int? ?? 30,
      unlimitedRetention: json['unlimitedRetention'] ?? false,
      gracePeriodDays: json['gracePeriodDays'] as int? ?? 14,
      targetUserType: json['targetUserType']?.toString() ?? 'both',
      planVisibility: json['planVisibility']?.toString() ?? 'public',
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
  final int storageMinutesUsed;
  final String capacityWarningLevel;

  RecordingSubscriptionModel({
    this.id,
    this.userId,
    this.status,
    this.role,
    this.startsAt,
    this.endsAt,
    this.gracePeriodEndsAt,
    this.storageMinutesUsed = 0,
    this.capacityWarningLevel = 'none',
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
      storageMinutesUsed: json['storageMinutesUsed'] as int? ?? 0,
      capacityWarningLevel: json['capacityWarningLevel']?.toString() ?? 'none',
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
  final bool isExpired;
  final int? daysUntilExpiry;
  final int? retentionDays;
  final DateTime? expiresAt;

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
    this.isExpired = false,
    this.daysUntilExpiry,
    this.retentionDays,
    this.expiresAt,
    this.expert,
    this.user,
  });

  String get durationDisplay {
    if (durationSeconds == null) return '0s';
    final seconds = durationSeconds!.toInt();
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final mins = (seconds % 3600) ~/ 60;
      return '$hours:${mins.toString().padLeft(2, '0')}:00';
    }
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String get expiryDisplay {
    if (expiresAt == null) return 'No expiry';
    if (isExpired) return 'Expired';
    if (daysUntilExpiry != null) {
      if (daysUntilExpiry! <= 7) return 'Expires in $daysUntilExpiry days';
      if (daysUntilExpiry! <= 30) {
        final weeks = daysUntilExpiry! ~/ 7;
        return 'Expires in $weeks week${weeks > 1 ? 's' : ''}';
      }
      final months = daysUntilExpiry! ~/ 30;
      return 'Expires in $months month${months > 1 ? 's' : ''}';
    }
    return 'Expires ${expiresAt!.toLocal()}';
  }

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
      isExpired: json['isExpired'] ?? false,
      daysUntilExpiry: json['daysUntilExpiry'] as int?,
      retentionDays: json['retentionDays'] as int?,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
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
  final StorageInfo? storage;

  RecordingEligibilityModel({
    required this.eligible,
    required this.userSubscriptionActive,
    required this.expertSubscriptionActive,
    this.reason,
    this.message,
    this.storage,
  });

  factory RecordingEligibilityModel.fromJson(Map<String, dynamic> json) {
    return RecordingEligibilityModel(
      eligible: json['eligible'] ?? false,
      userSubscriptionActive: json['userSubscriptionActive'] ?? false,
      expertSubscriptionActive: json['expertSubscriptionActive'] ?? false,
      reason: json['reason']?.toString(),
      message: json['message']?.toString(),
      storage: json['storage'] != null ? StorageInfo.fromJson(json['storage']) : null,
    );
  }
}

class StorageInfo {
  final int usedMinutes;
  final int maxMinutes;
  final bool unlimited;
  final int usagePercent;
  final int retentionDays;
  final bool unlimitedRetention;

  StorageInfo({
    this.usedMinutes = 0,
    this.maxMinutes = 0,
    this.unlimited = false,
    this.usagePercent = 0,
    this.retentionDays = 30,
    this.unlimitedRetention = false,
  });

  String get usedDisplay {
    if (unlimited || maxMinutes == 0) return 'Unlimited';
    if (usedMinutes >= 60) {
      final hours = usedMinutes ~/ 60;
      final mins = usedMinutes % 60;
      return mins > 0 ? '$hours hr $mins min' : '$hours hr';
    }
    return '$usedMinutes min';
  }

  String get maxDisplay {
    if (unlimited || maxMinutes == 0) return 'Unlimited';
    if (maxMinutes >= 60) {
      final hours = maxMinutes ~/ 60;
      final mins = maxMinutes % 60;
      return mins > 0 ? '$hours hr $mins min' : '$hours hr';
    }
    return '$maxMinutes min';
  }

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    return StorageInfo(
      usedMinutes: json['usedMinutes'] as int? ?? 0,
      maxMinutes: json['maxMinutes'] as int? ?? 0,
      unlimited: json['unlimited'] ?? false,
      usagePercent: json['usagePercent'] as int? ?? 0,
      retentionDays: json['retentionDays'] as int? ?? 30,
      unlimitedRetention: json['unlimitedRetention'] ?? false,
    );
  }
}

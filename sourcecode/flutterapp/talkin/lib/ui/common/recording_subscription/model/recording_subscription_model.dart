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

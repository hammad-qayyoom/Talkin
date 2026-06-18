class VerificationDocument {
  final String url;
  final String originalName;
  final String uploadedAt;

  VerificationDocument({
    this.url = '',
    this.originalName = '',
    this.uploadedAt = '',
  });

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      url: json['url']?.toString() ?? '',
      originalName: json['originalName']?.toString() ?? '',
      uploadedAt: json['uploadedAt']?.toString() ?? '',
    );
  }
}

class VerificationStatusModel {
  final bool status;
  final String message;
  final VerificationStatusData? data;

  VerificationStatusModel({
    this.status = false,
    this.message = '',
    this.data,
  });

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return VerificationStatusModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? VerificationStatusData.fromJson(json['data'])
          : null,
    );
  }
}

class VerificationStatusData {
  final bool isVerifiedBadge;
  final String verifiedBadgeType;
  final String verifiedBadgeAt;
  final String manualVerificationStatus;
  final List<VerificationDocument> manualVerificationDocuments;
  final String manualVerificationSubmittedAt;
  final String manualVerificationReviewedAt;
  final String manualVerificationRejectionReason;
  final String manualVerificationAdminNotes;
  final int completedSessions;
  final int autoBadgeThreshold;
  final bool autoBadgeEnabled;
  final int sessionsRemaining;

  VerificationStatusData({
    this.isVerifiedBadge = false,
    this.verifiedBadgeType = 'none',
    this.verifiedBadgeAt = '',
    this.manualVerificationStatus = 'not_applied',
    this.manualVerificationDocuments = const [],
    this.manualVerificationSubmittedAt = '',
    this.manualVerificationReviewedAt = '',
    this.manualVerificationRejectionReason = '',
    this.manualVerificationAdminNotes = '',
    this.completedSessions = 0,
    this.autoBadgeThreshold = 0,
    this.autoBadgeEnabled = false,
    this.sessionsRemaining = 0,
  });

  factory VerificationStatusData.fromJson(Map<String, dynamic> json) {
    return VerificationStatusData(
      isVerifiedBadge: json['isVerifiedBadge'] == true,
      verifiedBadgeType: json['verifiedBadgeType']?.toString() ?? 'none',
      verifiedBadgeAt: json['verifiedBadgeAt']?.toString() ?? '',
      manualVerificationStatus: json['manualVerificationStatus']?.toString() ?? 'not_applied',
      manualVerificationDocuments: (json['manualVerificationDocuments'] as List<dynamic>?)
              ?.map((e) => VerificationDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      manualVerificationSubmittedAt: json['manualVerificationSubmittedAt']?.toString() ?? '',
      manualVerificationReviewedAt: json['manualVerificationReviewedAt']?.toString() ?? '',
      manualVerificationRejectionReason: json['manualVerificationRejectionReason']?.toString() ?? '',
      manualVerificationAdminNotes: json['manualVerificationAdminNotes']?.toString() ?? '',
      completedSessions: int.tryParse(json['completedSessions']?.toString() ?? '0') ?? 0,
      autoBadgeThreshold: int.tryParse(json['autoBadgeThreshold']?.toString() ?? '0') ?? 0,
      autoBadgeEnabled: json['autoBadgeEnabled'] == true,
      sessionsRemaining: int.tryParse(json['sessionsRemaining']?.toString() ?? '0') ?? 0,
    );
  }

  bool get isManuallyPending => manualVerificationStatus == 'pending';
  bool get isManuallyApproved => manualVerificationStatus == 'approved';
  bool get isManuallyRejected => manualVerificationStatus == 'rejected';
  bool get isNotApplied => manualVerificationStatus == 'not_applied';
}

class VerificationSubmitModel {
  final bool status;
  final String message;
  final VerificationSubmitData? data;

  VerificationSubmitModel({
    this.status = false,
    this.message = '',
    this.data,
  });

  factory VerificationSubmitModel.fromJson(Map<String, dynamic> json) {
    return VerificationSubmitModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? VerificationSubmitData.fromJson(json['data'])
          : null,
    );
  }
}

class VerificationSubmitData {
  final String status;
  final int documentsUploaded;

  VerificationSubmitData({
    this.status = '',
    this.documentsUploaded = 0,
  });

  factory VerificationSubmitData.fromJson(Map<String, dynamic> json) {
    return VerificationSubmitData(
      status: json['status']?.toString() ?? '',
      documentsUploaded: int.tryParse(json['documentsUploaded']?.toString() ?? '0') ?? 0,
    );
  }
}

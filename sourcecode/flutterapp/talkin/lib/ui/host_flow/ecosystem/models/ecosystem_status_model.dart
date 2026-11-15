class EcosystemStatusModel {
  bool? status;
  String? message;
  EcosystemData? data;

  EcosystemStatusModel({this.status, this.message, this.data});

  EcosystemStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] == true;
    message = json['message']?.toString();
    data = json['data'] != null ? EcosystemData.fromJson(json['data']) : null;
  }
}

class EcosystemData {
  EcosystemRoleStatus? vendor;
  EcosystemRoleStatus? organizer;

  EcosystemData({this.vendor, this.organizer});

  EcosystemData.fromJson(Map<String, dynamic> json) {
    vendor = json['vendor'] != null
        ? EcosystemRoleStatus.fromJson(json['vendor'], isVendor: true)
        : null;
    organizer = json['organizer'] != null
        ? EcosystemRoleStatus.fromJson(json['organizer'], isVendor: false)
        : null;
  }
}

class EcosystemRoleStatus {
  String status;
  String? applicationRef;
  String? name;
  String? notes;
  String? rejectionReason;
  String? changesRequested;
  bool isUnlocked;
  String? appliedAt;
  String? reviewedAt;

  EcosystemRoleStatus({
    required this.status,
    this.applicationRef,
    this.name,
    this.notes,
    this.rejectionReason,
    this.changesRequested,
    this.isUnlocked = false,
    this.appliedAt,
    this.reviewedAt,
  });

  factory EcosystemRoleStatus.fromJson(Map<String, dynamic> json, {required bool isVendor}) {
    return EcosystemRoleStatus(
      status: json['status']?.toString().toLowerCase() ?? 'not_applied',
      applicationRef: json['applicationRef']?.toString(),
      name: (isVendor ? json['businessName'] : json['organizationName'])?.toString(),
      notes: json['notes']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      changesRequested: json['changesRequested']?.toString(),
      isUnlocked: json['isUnlocked'] == true,
      appliedAt: json['appliedAt']?.toString(),
      reviewedAt: json['reviewedAt']?.toString(),
    );
  }
}


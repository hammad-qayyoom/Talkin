import 'dart:convert';

import 'package:notisboard/utils/play_policy_topic_filter.dart';

ListenerProfileModel listenerProfileModelFromJson(String str) =>
    ListenerProfileModel.fromJson(json.decode(str));

int? _parseInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? double.tryParse(val)?.toInt();
  return null;
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (['true', '1', 'yes'].contains(normalized)) return true;
  if (['false', '0', 'no'].contains(normalized)) return false;
  return null;
}

String listenerProfileModelToJson(ListenerProfileModel data) =>
    json.encode(data.toJson());

class ListenerProfileModel {
  final bool? status;
  final String? message;
  final ListenerData? data;

  ListenerProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory ListenerProfileModel.fromJson(Map<String, dynamic> json) =>
      ListenerProfileModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : ListenerData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class ListenerData {
  final String? id;
  final String? name;
  final String? selfIntro;
  final List<String>? talkTopics;
  final List<String>? language;
  final String? image;
  final int? ratePrivateVideoCall;
  final int? ratePrivateAudioCall;
  final double? rating;
  final int? callCount;
  final int? completedSessionCount;
  final String? experience;
  final String? statusLabel;
  int? totalCoins;
  final int? age; // Optional, included for compatibility
  bool? isFake;
  List<String>? video;
  String? uniqueId;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForChat;
  bool? isVerifiedBadge;
  String? verifiedBadgeType;
  DateTime? verifiedBadgeAt;
  String? audio;

  // In-Person Consultation fields
  final Map<String, dynamic>? consultationModes;
  final Map<String, dynamic>? inPersonPricing;
  final Map<String, dynamic>? clinicDetails;

  bool? isAvailableForInPersonSession;
  int? rateInPersonSession;

  ListenerData({
    this.id,
    this.name,
    this.selfIntro,
    this.talkTopics,
    this.language,
    this.image,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.rating,
    this.callCount,
    this.completedSessionCount,
    this.experience,
    this.statusLabel,
    this.age,
    this.totalCoins,
    this.video,
    this.isFake,
    this.uniqueId,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForChat,
    this.isVerifiedBadge,
    this.verifiedBadgeType,
    this.verifiedBadgeAt,
    this.audio,
    this.consultationModes,
    this.inPersonPricing,
    this.clinicDetails,
    this.isAvailableForInPersonSession,
    this.rateInPersonSession,
  });

  factory ListenerData.fromJson(Map<String, dynamic> json) => ListenerData(
        id: (json["_id"] ?? json["id"] ?? json["listenerId"])?.toString(),
        name: json["name"]?.toString(),
        selfIntro: json["selfIntro"]?.toString(),
        talkTopics: json["talkTopics"] is List
            ? PlayPolicyTopicFilter.visibleNames(
                (json["talkTopics"] as List).map((e) => e.toString()))
            : [],
        language: json["language"] is List
            ? (json["language"] as List).map((e) => e.toString()).toList()
            : [],
        image: json["image"]?.toString(),
        ratePrivateVideoCall: _parseInt(json["ratePrivateVideoCall"]),
        ratePrivateAudioCall: _parseInt(json["ratePrivateAudioCall"]),
        rating: (json["rating"] is num)
            ? (json["rating"] as num).toDouble()
            : double.tryParse((json["rating"] ?? '').toString()),
        callCount: _parseInt(json["callCount"]),
        completedSessionCount: _parseInt(
          json["completedSessionCount"] ??
              json["completedSessions"] ??
              json["bookingCompletedCount"] ??
              json["completedBookingCount"] ??
              json["totalCompletedSessions"] ??
              json["totalCompletedBookings"] ??
              json["sessionCompletedCount"] ??
              json["completedBookings"] ??
              json["sessionCountCompleted"] ??
              json["totalSessionsCompleted"] ??
              json["bookingsCompleted"],
        ),
        experience: json["experience"]?.toString(),
        statusLabel: json["statusLabel"]?.toString(),
        age: _parseInt(json["age"]),
        totalCoins: _parseInt(json["totalCoins"]),
        video: json["video"] is List
            ? (json["video"] as List).map((e) => e.toString()).toList()
            : [],
        isFake: json["isFake"] == true || json["isFake"]?.toString() == 'true',
        uniqueId: json["uniqueId"]?.toString(),
        isAvailableForPrivateAudioCall:
            json["isAvailableForPrivateAudioCall"] == true ||
                json["isAvailableForPrivateAudioCall"]?.toString() == 'true',
        isAvailableForPrivateVideoCall:
            json["isAvailableForPrivateVideoCall"] == true ||
                json["isAvailableForPrivateVideoCall"]?.toString() == 'true',
        isAvailableForInPersonSession:
            json["isAvailableForInPersonSession"] == true ||
                json["isAvailableForInPersonSession"]?.toString() == 'true',
        isAvailableForChat: json["isAvailableForChat"] == true ||
            json["isAvailableForChat"]?.toString() == 'true',
        isVerifiedBadge: _parseBool(json["isVerifiedBadge"]) ?? false,
        verifiedBadgeType: json["verifiedBadgeType"]?.toString(),
        verifiedBadgeAt: DateTime.tryParse(
          (json["verifiedBadgeAt"] ?? '').toString(),
        )?.toLocal(),
        audio: json["audio"]?.toString(),
        consultationModes: json["consultationModes"] is Map
            ? Map<String, dynamic>.from(json["consultationModes"])
            : null,
        inPersonPricing: json["inPersonPricing"] is Map
            ? Map<String, dynamic>.from(json["inPersonPricing"])
            : null,
        clinicDetails: json["clinicDetails"] is Map
            ? Map<String, dynamic>.from(json["clinicDetails"])
            : null,
        rateInPersonSession: _parseInt(json["rateInPersonSession"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "selfIntro": selfIntro,
        "talkTopics": talkTopics == null ? [] : List<dynamic>.from(talkTopics!),
        "language": language == null ? [] : List<dynamic>.from(language!),
        "image": image,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "rating": rating,
        "callCount": callCount,
        "completedSessionCount": completedSessionCount,
        "experience": experience,
        "statusLabel": statusLabel,
        "age": age,
        "totalCoins": totalCoins,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
        "uniqueId": uniqueId,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "isVerifiedBadge": isVerifiedBadge,
        "verifiedBadgeType": verifiedBadgeType,
        "verifiedBadgeAt": verifiedBadgeAt?.toIso8601String(),
        "audio": audio,
        "consultationModes": consultationModes,
        "inPersonPricing": inPersonPricing,
        "clinicDetails": clinicDetails,
        "isAvailableForInPersonSession": isAvailableForInPersonSession,
        "rateInPersonSession": rateInPersonSession,
      };
}

// To parse this JSON data, do
//
//     final fetchListenerProfileModel = fetchListenerProfileModelFromJson(jsonString);

import 'dart:convert';

import 'package:notisboard/utils/play_policy_topic_filter.dart';

FetchListenerProfileModel fetchListenerProfileModelFromJson(String str) =>
    FetchListenerProfileModel.fromJson(json.decode(str));

String fetchListenerProfileModelToJson(FetchListenerProfileModel data) =>
    json.encode(data.toJson());

class FetchListenerProfileModel {
  bool? status;
  String? message;
  Data? data;

  FetchListenerProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory FetchListenerProfileModel.fromJson(Map<String, dynamic> json) =>
      FetchListenerProfileModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  String? id;
  String? name;
  String? nickName;
  final String? uniqueId;

  String? email;
  String? selfIntro;
  List<String>? talkTopics;
  List<String>? categoryIds;
  List<String>? language;
  String? image;
  num? ratePrivateVideoCall;
  num? ratePrivateAudioCall;
  num? rating;
  num? callCount;
  String? experience;
  num? currentCoinBalance;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForInPersonSession;
  bool? isAvailableForChat;
  num? rateInPersonSession;
  Map<String, dynamic>? consultationModes;
  Map<String, dynamic>? inPersonPricing;
  Map<String, dynamic>? clinicDetails;
  bool? isVerifiedBadge;
  String? verifiedBadgeType;
  DateTime? verifiedBadgeAt;
  bool? isNotificationEnabled;
  bool? isFake;
  List<String>? video;

  Data({
    this.id,
    this.name,
    this.nickName,
    this.uniqueId,
    this.email,
    this.selfIntro,
    this.talkTopics,
    this.categoryIds,
    this.language,
    this.image,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.rating,
    this.callCount,
    this.experience,
    this.currentCoinBalance,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForInPersonSession,
    this.isAvailableForChat,
    this.rateInPersonSession,
    this.consultationModes,
    this.inPersonPricing,
    this.clinicDetails,
    this.isVerifiedBadge,
    this.verifiedBadgeType,
    this.verifiedBadgeAt,
    this.isNotificationEnabled,
    this.video,
    this.isFake,
  });

  static String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final normalized = value.toString().trim();
      if (normalized.isNotEmpty && normalized.toLowerCase() != 'null') {
        return normalized;
      }
    }
    return null;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final normalized = value.toString().trim().toLowerCase();
    if (['true', '1', 'yes'].contains(normalized)) return true;
    if (['false', '0', 'no'].contains(normalized)) return false;
    return null;
  }

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: _pickString(json, ["_id", "id", "listenerId", "expertId"]),
        name: _pickString(json, ["name", "fullName", "nickName"]),
        nickName: _pickString(json, ["nickName", "nickname", "name"]),
        uniqueId: _pickString(json, ["uniqueId", "expertUniqueId"]),
        email: _pickString(json, ["email"]),
        selfIntro: _pickString(json, ["selfIntro", "bio"]),
        talkTopics: PlayPolicyTopicFilter.visibleNames(
            _toStringList(json["talkTopics"])),
        categoryIds: _toStringList(json["categoryIds"]),
        language: _toStringList(json["language"]),
        image: _pickString(json, ["image", "profilePic", "avatar"]),
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        rating: json["rating"],
        callCount: json["callCount"],
        experience: json["experience"],
        currentCoinBalance: json["currentCoinBalance"],
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForInPersonSession: json["isAvailableForInPersonSession"],
        isAvailableForChat: json["isAvailableForChat"],
        rateInPersonSession: json["rateInPersonSession"],
        consultationModes: json["consultationModes"] is Map ? Map<String, dynamic>.from(json["consultationModes"]) : null,
        inPersonPricing: json["inPersonPricing"] is Map ? Map<String, dynamic>.from(json["inPersonPricing"]) : null,
        clinicDetails: json["clinicDetails"] is Map ? Map<String, dynamic>.from(json["clinicDetails"]) : null,
        isVerifiedBadge: _toBool(json["isVerifiedBadge"]) ?? false,
        verifiedBadgeType: _pickString(json, ["verifiedBadgeType"]),
        verifiedBadgeAt: DateTime.tryParse(
          (json["verifiedBadgeAt"] ?? '').toString(),
        )?.toLocal(),
        isNotificationEnabled: json["isNotificationEnabled"],
        video: _toStringList(json["video"]),
        isFake: json["isFake"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "nickName": nickName,
        "uniqueId": uniqueId,
        "email": email,
        "selfIntro": selfIntro,
        "talkTopics": talkTopics == null
            ? []
            : List<dynamic>.from(talkTopics!.map((x) => x)),
        "categoryIds": categoryIds == null
            ? []
            : List<dynamic>.from(categoryIds!.map((x) => x)),
        "language":
            language == null ? [] : List<dynamic>.from(language!.map((x) => x)),
        "image": image,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "rating": rating,
        "callCount": callCount,
        "experience": experience,
        "currentCoinBalance": currentCoinBalance,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "isVerifiedBadge": isVerifiedBadge,
        "verifiedBadgeType": verifiedBadgeType,
        "verifiedBadgeAt": verifiedBadgeAt?.toIso8601String(),
        "isNotificationEnabled": isNotificationEnabled,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
      };
}

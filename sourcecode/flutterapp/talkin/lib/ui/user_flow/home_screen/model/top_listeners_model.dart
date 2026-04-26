// To parse this JSON data, do
//
//     final topListenersModel = topListenersModelFromJson(jsonString);

import 'dart:convert';

TopListenersModel topListenersModelFromJson(String str) =>
    TopListenersModel.fromJson(json.decode(str));

String topListenersModelToJson(TopListenersModel data) =>
    json.encode(data.toJson());

class TopListenersModel {
  bool? status;
  String? message;
  List<TopListeners>? data;

  TopListenersModel({
    this.status,
    this.message,
    this.data,
  });

  factory TopListenersModel.fromJson(Map<String, dynamic> json) =>
      TopListenersModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<TopListeners>.from(
                json["data"]!.map((x) => TopListeners.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class TopListeners {
  String? id;
  String? name;
  int? age;
  List<String>? talkTopics;
  List<String>? language;
  String? image;
  int? ratePrivateVideoCall;
  int? ratePrivateAudioCall;
  List<String>? video;
  double? rating;
  int? callCount;
  String? experience;
  bool? isFake;
  bool? isOnline;
  String? statusLabel;
  String? uniqueId;
  List<String>? categoryIds;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForChat;
  String? audio;

  TopListeners({
    this.id,
    this.name,
    this.age,
    this.talkTopics,
    this.language,
    this.image,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.video,
    this.rating,
    this.callCount,
    this.experience,
    this.isFake,
    this.isOnline,
    this.statusLabel,
    this.uniqueId,
    this.categoryIds,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForChat,
    this.audio,
  });

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }

  static List<String> _categoryNames(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['name'] ?? '').toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }

  static List<String> _categoryIds(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['_id'] ?? item['id'] ?? '').toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _doubleValue(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static bool _positivePricing(dynamic pricing, String key) {
    if (pricing is! Map) return false;
    final value = num.tryParse(pricing[key]?.toString() ?? '');
    return (value ?? 0) > 0;
  }

  static bool _hasSessionType(dynamic windows, String type) {
    if (windows is! List) return false;
    for (final window in windows) {
      if (window is! Map<String, dynamic>) continue;
      final slots = window['slots'];
      if (slots is! List) continue;
      for (final slot in slots) {
        if (slot is Map<String, dynamic> &&
            (slot['sessionType'] ?? '').toString() == type) {
          return true;
        }
      }
    }
    return false;
  }

  factory TopListeners.fromJson(Map<String, dynamic> json) => TopListeners(
        id: (json["_id"] ?? json["id"] ?? json["listenerId"])?.toString(),
        name: json["name"] ?? json["displayName"],
        age: _intValue(json["age"]),
        talkTopics: json["talkTopics"] == null
            ? (_stringList(json["skills"]).isNotEmpty
                ? _stringList(json["skills"])
                : _categoryNames(json["categories"]))
            : _stringList(json["talkTopics"]),
        language: json["language"] == null
            ? _stringList(json["languages"])
            : _stringList(json["language"]),
        image: json["image"] ?? json["profilePic"],
        ratePrivateVideoCall: _intValue(json["ratePrivateVideoCall"] ??
            (json["pricing"] is Map ? json["pricing"]["oneToOneVideo"] : null)),
        ratePrivateAudioCall: _intValue(json["ratePrivateAudioCall"] ??
            (json["pricing"] is Map ? json["pricing"]["oneToOneAudio"] : null)),
        video: json["video"] == null
            ? []
            : List<String>.from(json["video"]!.map((x) => x)),
        rating: _doubleValue(json["rating"] ??
            json["averageRating"] ??
            (json["trustSignals"] is Map
                ? json["trustSignals"]["averageRating"]
                : null)),
        callCount: _intValue(json["callCount"] ?? json["totalSessions"]),
        experience:
            (json["experience"] ?? json["totalSessions"] ?? 0).toString(),
        isFake: json["isFake"],
        isOnline: json["isOnline"],
        statusLabel: json["statusLabel"] ??
            (json["isOnline"] == true ? "Available" : "Offline"),
        uniqueId: json["uniqueId"],
        categoryIds: json["categoryIds"] == null
            ? _categoryIds(json["categories"])
            : _stringList(json["categoryIds"]),
        isAvailableForPrivateAudioCall:
            json["isAvailableForPrivateAudioCall"] ??
                (_hasSessionType(
                        json["availabilityWindows"], "one_to_one_audio") ||
                    _positivePricing(json["pricing"], "oneToOneAudio")),
        isAvailableForPrivateVideoCall:
            json["isAvailableForPrivateVideoCall"] ??
                (_hasSessionType(
                        json["availabilityWindows"], "one_to_one_video") ||
                    _positivePricing(json["pricing"], "oneToOneVideo")),
        isAvailableForChat: json["isAvailableForChat"],
        audio: json["audio"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "age": age,
        "talkTopics": talkTopics == null
            ? []
            : List<dynamic>.from(talkTopics!.map((x) => x)),
        "language":
            language == null ? [] : List<dynamic>.from(language!.map((x) => x)),
        "image": image,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "rating": rating,
        "callCount": callCount,
        "experience": experience,
        "isFake": isFake,
        "isOnline": isOnline,
        "statusLabel": statusLabel,
        "uniqueId": uniqueId,
        "categoryIds": categoryIds == null
            ? []
            : List<dynamic>.from(categoryIds!.map((x) => x)),
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "audio": audio,
      };
}

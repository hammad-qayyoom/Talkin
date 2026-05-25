// To parse this JSON data, do
//
//     final topListenersModel = topListenersModelFromJson(jsonString);

import 'dart:convert';

import 'package:notisboard/utils/play_policy_topic_filter.dart';

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
  String? expertId;
  String? name;
  int? age;
  double? latitude;
  double? longitude;
  double? distanceKm;
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
  bool? isVerifiedBadge;
  String? verifiedBadgeType;
  DateTime? verifiedBadgeAt;
  String? audio;
  bool hasLegacyListener;

  TopListeners({
    this.id,
    this.expertId,
    this.name,
    this.age,
    this.latitude,
    this.longitude,
    this.distanceKm,
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
    this.isVerifiedBadge,
    this.verifiedBadgeType,
    this.verifiedBadgeAt,
    this.audio,
    this.hasLegacyListener = true,
  });

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .where((item) => !PlayPolicyTopicFilter.isRestrictedText(item))
          .toList();
    }
    return [];
  }

  static String? _nonEmptyString(dynamic value) {
    final parsed = value?.toString().trim() ?? '';
    return parsed.isEmpty ? null : parsed;
  }

  static String? _firstNonEmptyString(Iterable<dynamic> values) {
    for (final value in values) {
      final parsed = _nonEmptyString(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String? _idFromValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _firstNonEmptyString([
        value["_id"],
        value["id"],
        value["listenerId"],
        value["expertId"],
      ]);
    }
    if (value is Map) {
      return _idFromValue(value.map(
        (key, item) => MapEntry(key.toString(), item),
      ));
    }
    return _nonEmptyString(value);
  }

  static String? _imageFromValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _firstNonEmptyString([
        value["url"],
        value["secureUrl"],
        value["secure_url"],
        value["path"],
        value["image"],
        value["profilePic"],
        value["profileImage"],
        value["avatar"],
        value["avatarUrl"],
      ]);
    }
    if (value is Map) {
      return _imageFromValue(value.map(
        (key, item) => MapEntry(key.toString(), item),
      ));
    }
    return _nonEmptyString(value);
  }

  static List<String> _categoryNames(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['name'] ?? '').toString().trim())
          .where((item) => item.isNotEmpty)
          .where((item) => !PlayPolicyTopicFilter.isRestrictedText(item))
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

  static Map<String, dynamic>? _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return null;
  }

  static List<dynamic> _listValue(dynamic value) {
    if (value is List) {
      return value;
    }
    return [];
  }

  static String? _resolveImage(Map<String, dynamic> json) {
    final user = _mapValue(json["user"]);
    final profile = _mapValue(json["profile"]);
    final expert = _mapValue(json["expert"]);

    return _firstNonEmptyString([
      _imageFromValue(json["image"]),
      _imageFromValue(json["profilePic"]),
      _imageFromValue(json["profileImage"]),
      _imageFromValue(json["avatar"]),
      _imageFromValue(json["avatarUrl"]),
      _imageFromValue(user?["image"]),
      _imageFromValue(user?["profilePic"]),
      _imageFromValue(user?["profileImage"]),
      _imageFromValue(user?["avatar"]),
      _imageFromValue(user?["avatarUrl"]),
      _imageFromValue(profile?["image"]),
      _imageFromValue(profile?["profilePic"]),
      _imageFromValue(profile?["profileImage"]),
      _imageFromValue(profile?["avatar"]),
      _imageFromValue(profile?["avatarUrl"]),
      _imageFromValue(expert?["image"]),
      _imageFromValue(expert?["profilePic"]),
      _imageFromValue(expert?["profileImage"]),
      _imageFromValue(expert?["avatar"]),
      _imageFromValue(expert?["avatarUrl"]),
    ]);
  }

  static bool? _boolValue(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final normalized = value.toString().trim().toLowerCase();
    if (['true', '1', 'yes'].contains(normalized)) return true;
    if (['false', '0', 'no'].contains(normalized)) return false;
    return null;
  }

  factory TopListeners.fromJson(Map<String, dynamic> json) {
    final legacyListenerId = _firstNonEmptyString([
      json["listenerId"],
      _idFromValue(json["legacyListenerId"]),
    ]);
    final rawId = _nonEmptyString(json["_id"] ?? json["id"]);
    final expertProfileId = _firstNonEmptyString([
      json["expertId"],
      json["expertProfileId"],
      json["profileId"],
      if (legacyListenerId != null && rawId != legacyListenerId) rawId,
    ]);
    final hasLegacyListener =
        legacyListenerId != null || !json.containsKey("legacyListenerId");
    final expert = _mapValue(json["expert"]);
    final trustSignals = _mapValue(json["trustSignals"]);
    final isVerified = _boolValue(
          json["isVerifiedBadge"] ??
              expert?["isVerifiedBadge"] ??
              trustSignals?["isVerifiedBadge"],
        ) ??
        false;
    final badgeType = _firstNonEmptyString([
      json["verifiedBadgeType"],
      expert?["verifiedBadgeType"],
    ]);
    final badgeAtString = _firstNonEmptyString([
      json["verifiedBadgeAt"],
      expert?["verifiedBadgeAt"],
    ]);

    return TopListeners(
      latitude: () {
        final location = _mapValue(json["location"]);
        final geo = _mapValue(location?["geo"]);
        final coordinates = _listValue(geo?["coordinates"]);
        if (coordinates.length >= 2) {
          final fromGeo = _doubleValue(coordinates[1]);
          if (fromGeo != null) return fromGeo;
        }

        return _doubleValue(location?["lat"] ??
            location?["latitude"] ??
            json["lat"] ??
            json["latitude"]);
      }(),
      longitude: () {
        final location = _mapValue(json["location"]);
        final geo = _mapValue(location?["geo"]);
        final coordinates = _listValue(geo?["coordinates"]);
        if (coordinates.length >= 2) {
          final fromGeo = _doubleValue(coordinates[0]);
          if (fromGeo != null) return fromGeo;
        }

        return _doubleValue(location?["lng"] ??
            location?["lon"] ??
            location?["longitude"] ??
            json["lng"] ??
            json["lon"] ??
            json["longitude"]);
      }(),
      distanceKm: _doubleValue(json["distanceKm"] ?? json["distance"]),
      id: _firstNonEmptyString([
        legacyListenerId,
        if (!json.containsKey("legacyListenerId")) rawId,
      ]),
      expertId: expertProfileId,
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
      image: _resolveImage(json),
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
      experience: (json["experience"] ?? json["totalSessions"] ?? 0).toString(),
      isFake: json["isFake"],
      isOnline: json["isOnline"],
      statusLabel: json["statusLabel"] ??
          (json["isOnline"] == true ? "Available" : "Offline"),
      uniqueId: json["uniqueId"],
      categoryIds: json["categoryIds"] == null
          ? _categoryIds(json["categories"])
          : _stringList(json["categoryIds"]),
      isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"] ??
          (_hasSessionType(json["availabilityWindows"], "one_to_one_audio") ||
              _positivePricing(json["pricing"], "oneToOneAudio")),
      isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"] ??
          (_hasSessionType(json["availabilityWindows"], "one_to_one_video") ||
              _positivePricing(json["pricing"], "oneToOneVideo")),
      isAvailableForChat: json["isAvailableForChat"],
      isVerifiedBadge: isVerified,
      verifiedBadgeType: badgeType ?? (isVerified ? 'manual' : 'none'),
      verifiedBadgeAt: badgeAtString == null
          ? null
          : DateTime.tryParse(badgeAtString)?.toLocal(),
      audio: json["audio"],
      hasLegacyListener: hasLegacyListener,
    );
  }

  Map<String, dynamic> get profileRouteArguments {
    final listenerId = (id ?? '').trim();
    final resolvedExpertId = (expertId ?? '').trim();

    return {
      if (listenerId.isNotEmpty) "listenerId": listenerId,
      if (resolvedExpertId.isNotEmpty) "expertId": resolvedExpertId,
    };
  }

  Map<String, dynamic> get sessionBookingArguments {
    final listenerId = (id ?? '').trim();
    final resolvedExpertId = (expertId ?? '').trim();

    return {
      'listenerId': listenerId,
      if (resolvedExpertId.isNotEmpty) 'expertId': resolvedExpertId,
      'listenerName': name ?? '',
      'listenerImage': image ?? '',
      'isVerifiedBadge': isVerifiedBadge ?? false,
      'availableForPrivateAudioCall': isAvailableForPrivateAudioCall ?? false,
      'availableForPrivateVideoCall': isAvailableForPrivateVideoCall ?? false,
      'ratePrivateAudioCall': ratePrivateAudioCall ?? 0,
      'ratePrivateVideoCall': ratePrivateVideoCall ?? 0,
    };
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "expertId": expertId,
        "name": name,
        "age": age,
        "latitude": latitude,
        "longitude": longitude,
        "distanceKm": distanceKm,
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
        "isVerifiedBadge": isVerifiedBadge,
        "verifiedBadgeType": verifiedBadgeType,
        "verifiedBadgeAt": verifiedBadgeAt?.toIso8601String(),
        "audio": audio,
      };
}

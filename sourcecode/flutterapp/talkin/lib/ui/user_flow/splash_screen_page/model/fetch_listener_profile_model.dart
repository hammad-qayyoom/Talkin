// To parse this JSON data, do
//
//     final fetchListenerProfileModel = fetchListenerProfileModelFromJson(jsonString);

import 'dart:convert';

FetchListenerProfileModel fetchListenerProfileModelFromJson(String str) => FetchListenerProfileModel.fromJson(json.decode(str));

String fetchListenerProfileModelToJson(FetchListenerProfileModel data) => json.encode(data.toJson());

class FetchListenerProfileModel {
  bool? status;
  String? message;
  Data? data;

  FetchListenerProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory FetchListenerProfileModel.fromJson(Map<String, dynamic> json) => FetchListenerProfileModel(
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
  bool? isAvailableForChat;
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
    this.isAvailableForChat,
    this.isNotificationEnabled,
    this.video,
    this.isFake,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        name: json["name"],
        nickName: json["nickName"],
        uniqueId: json["uniqueId"],
        email: json["email"],
        selfIntro: json["selfIntro"],
        talkTopics: json["talkTopics"] == null ? [] : List<String>.from(json["talkTopics"]!.map((x) => x)),
        categoryIds: json["categoryIds"] == null ? [] : List<String>.from(json["categoryIds"]!.map((x) => x.toString())),
        language: json["language"] == null ? [] : List<String>.from(json["language"]!.map((x) => x)),
        image: json["image"],
        ratePrivateVideoCall: json["ratePrivateVideoCall"],
        ratePrivateAudioCall: json["ratePrivateAudioCall"],
        rating: json["rating"],
        callCount: json["callCount"],
        experience: json["experience"],
        currentCoinBalance: json["currentCoinBalance"],
        isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
        isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
        isAvailableForChat: json["isAvailableForChat"],
        isNotificationEnabled: json["isNotificationEnabled"],
        video: json["video"] == null ? [] : List<String>.from(json["video"]!.map((x) => x)),
        isFake: json["isFake"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "nickName": nickName,
        "uniqueId": uniqueId,
        "email": email,
        "selfIntro": selfIntro,
        "talkTopics": talkTopics == null ? [] : List<dynamic>.from(talkTopics!.map((x) => x)),
        "categoryIds": categoryIds == null ? [] : List<dynamic>.from(categoryIds!.map((x) => x)),
        "language": language == null ? [] : List<dynamic>.from(language!.map((x) => x)),
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
        "isNotificationEnabled": isNotificationEnabled,
        "video": video == null ? [] : List<dynamic>.from(video!.map((x) => x)),
        "isFake": isFake,
      };
}

// To parse this JSON data, do
//
//     final chatListResponseModel = chatListResponseModelFromJson(jsonString);

import 'dart:convert';

ChatListResponseModel chatListResponseModelFromJson(String str) =>
    ChatListResponseModel.fromJson(json.decode(str));

String chatListResponseModelToJson(ChatListResponseModel data) =>
    json.encode(data.toJson());

class ChatListResponseModel {
  bool? status;
  String? message;
  List<ChatList>? chatList;

  ChatListResponseModel({
    this.status,
    this.message,
    this.chatList,
  });

  factory ChatListResponseModel.fromJson(Map<String, dynamic> json) =>
      ChatListResponseModel(
        status: json["status"],
        message: json["message"],
        chatList: json["chatList"] == null
            ? []
            : List<ChatList>.from(
                json["chatList"]!.map((x) => ChatList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "chatList": chatList == null
            ? []
            : List<dynamic>.from(chatList!.map((x) => x.toJson())),
      };
}

class ChatList {
  String? id;
  String? receiverId;
  String? name;
  String? image;
  bool? isOnline;
  int? ratePrivateVideoCall;
  int? ratePrivateAudioCall;
  dynamic video;
  bool? isFake;
  String? chatTopicId;
  String? senderId;
  int? messageType;
  String? message;
  DateTime? lastChatMessageTime;
  int? unreadCount;
  String? time;
  bool? isAvailableForPrivateAudioCall;
  bool? isAvailableForPrivateVideoCall;
  bool? isAvailableForChat;
  bool? isVerifiedBadge;

  ChatList({
    this.id,
    this.receiverId,
    this.name,
    this.image,
    this.isOnline,
    this.ratePrivateVideoCall,
    this.ratePrivateAudioCall,
    this.video,
    this.isFake,
    this.chatTopicId,
    this.senderId,
    this.messageType,
    this.message,
    this.lastChatMessageTime,
    this.unreadCount,
    this.time,
    this.isAvailableForPrivateAudioCall,
    this.isAvailableForPrivateVideoCall,
    this.isAvailableForChat,
    this.isVerifiedBadge,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) {
    final expert = _mapValue(json["expert"]);
    final listener = _mapValue(json["listener"]);
    final receiver = _mapValue(json["receiver"]);
    final receiverUser = _mapValue(json["receiverUser"]);
    final receiverData = _mapValue(json["receiverData"]);
    final chatUser = _mapValue(json["chatUser"]);
    final user = _mapValue(json["user"]);

    return ChatList(
      id: json["_id"],
      receiverId: json["receiverId"],
      name: json["name"],
      image: json["image"],
      isOnline: json["isOnline"],
      ratePrivateVideoCall: json["ratePrivateVideoCall"],
      ratePrivateAudioCall: json["ratePrivateAudioCall"],
      video: json["video"],
      isFake: json["isFake"],
      chatTopicId: json["chatTopicId"],
      senderId: json["senderId"],
      messageType: json["messageType"],
      message: json["message"],
      lastChatMessageTime: json["lastChatMessageTime"] == null
          ? null
          : DateTime.parse(json["lastChatMessageTime"]),
      unreadCount: json["unreadCount"],
      time: json["time"],
      isAvailableForPrivateAudioCall: json["isAvailableForPrivateAudioCall"],
      isAvailableForPrivateVideoCall: json["isAvailableForPrivateVideoCall"],
      isAvailableForChat: json["isAvailableForChat"],
      isVerifiedBadge: _isVerifiedFromSources([
        json,
        expert,
        listener,
        receiver,
        receiverUser,
        receiverData,
        chatUser,
        user,
        _mapValue(json["trustSignals"]),
        _mapValue(expert?["trustSignals"]),
        _mapValue(listener?["trustSignals"]),
        _mapValue(receiver?["trustSignals"]),
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "receiverId": receiverId,
        "name": name,
        "image": image,
        "isOnline": isOnline,
        "ratePrivateVideoCall": ratePrivateVideoCall,
        "ratePrivateAudioCall": ratePrivateAudioCall,
        "video": video,
        "isFake": isFake,
        "chatTopicId": chatTopicId,
        "senderId": senderId,
        "messageType": messageType,
        "message": message,
        "lastChatMessageTime": lastChatMessageTime?.toIso8601String(),
        "unreadCount": unreadCount,
        "time": time,
        "isAvailableForPrivateAudioCall": isAvailableForPrivateAudioCall,
        "isAvailableForPrivateVideoCall": isAvailableForPrivateVideoCall,
        "isAvailableForChat": isAvailableForChat,
        "isVerifiedBadge": isVerifiedBadge,
      };

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  static Map<String, dynamic>? _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static bool _isVerifiedFromSources(List<Map<String, dynamic>?> sources) {
    for (final source in sources) {
      if (source == null) continue;

      final parsed = _parseBool(
        source["isVerifiedBadge"] ??
            source["verifiedBadge"] ??
            source["isVerified"] ??
            source["verified"],
      );
      if (parsed != null) return parsed;

      final badgeType = (source["verifiedBadgeType"] ?? '').toString().trim();
      if (badgeType.isNotEmpty && badgeType.toLowerCase() != 'none') {
        return true;
      }
    }

    return false;
  }
}

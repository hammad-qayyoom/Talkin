// To parse this JSON data, do
//
//     final hostCoinHistoryModel = hostCoinHistoryModelFromJson(jsonString);

import 'dart:convert';

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString();
  return normalized.isEmpty ? null : normalized;
}

HostCoinHistoryModel hostCoinHistoryModelFromJson(String str) =>
    HostCoinHistoryModel.fromJson(json.decode(str));

String hostCoinHistoryModelToJson(HostCoinHistoryModel data) =>
    json.encode(data.toJson());

class HostCoinHistoryModel {
  bool? status;
  String? message;
  List<HostCoinHistory>? data;

  HostCoinHistoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory HostCoinHistoryModel.fromJson(Map<String, dynamic> json) =>
      HostCoinHistoryModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] is List
            ? List<HostCoinHistory>.from(
                (json["data"] as List)
                    .whereType<Map<String, dynamic>>()
                    .map(HostCoinHistory.fromJson),
              )
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HostCoinHistory {
  String? id;
  String? duration;
  num? listenerCoin;
  int? payoutStatus;
  String? date;
  int? type;
  DateTime? createdAt;
  String? fullName;
  String? profilePic;

  HostCoinHistory({
    this.id,
    this.duration,
    this.listenerCoin,
    this.payoutStatus,
    this.date,
    this.type,
    this.createdAt,
    this.fullName,
    this.profilePic,
  });

  factory HostCoinHistory.fromJson(Map<String, dynamic> json) =>
      HostCoinHistory(
        id: _parseString(json["_id"]),
        duration: _parseString(json["duration"]),
        listenerCoin: _parseNum(json["listenerCoin"]),
        payoutStatus: _parseInt(json["payoutStatus"]),
        date: _parseString(json["date"]),
        type: _parseInt(json["type"]),
        createdAt: _parseString(json["createdAt"]) == null
            ? null
            : DateTime.tryParse(json["createdAt"].toString()),
        fullName: _parseString(json["fullName"]),
        profilePic: _parseString(json["profilePic"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "duration": duration,
        "listenerCoin": listenerCoin,
        "payoutStatus": payoutStatus,
        "date": date,
        "type": type,
        "createdAt": createdAt?.toIso8601String(),
        "fullName": fullName,
        "profilePic": profilePic,
      };
}

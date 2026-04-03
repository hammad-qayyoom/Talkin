// To parse this JSON data, do
//
//     final fetchCoinPlan = fetchCoinPlanFromJson(jsonString);

import 'dart:convert';

FetchCoinPlan fetchCoinPlanFromJson(String str) => FetchCoinPlan.fromJson(json.decode(str));

String fetchCoinPlanToJson(FetchCoinPlan data) => json.encode(data.toJson());

class FetchCoinPlan {
  bool? status;
  String? message;
  int? userCoin;
  bool? hasActiveSubscription;
  dynamic activeSubscription;
  List<CoinPlan>? data;

  FetchCoinPlan({
    this.status,
    this.message,
    this.userCoin,
    this.hasActiveSubscription,
    this.activeSubscription,
    this.data,
  });

  factory FetchCoinPlan.fromJson(Map<String, dynamic> json) => FetchCoinPlan(
        status: json["status"],
        message: json["message"],
        userCoin: json["userCoin"],
        hasActiveSubscription: json["hasActiveSubscription"],
        activeSubscription: json["activeSubscription"],
        data: json["data"] == null ? [] : List<CoinPlan>.from(json["data"]!.map((x) => CoinPlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "userCoin": userCoin,
        "hasActiveSubscription": hasActiveSubscription,
        "activeSubscription": activeSubscription,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CoinPlan {
  String? id;
  String? name;
  String? description;
  int? coins;
  int? sessionCredits;
  double? price;
  String? currency;
  String? billingCycle;
  String? productId;
  bool? isPopular;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  CoinPlan({
    this.id,
    this.name,
    this.description,
    this.coins,
    this.sessionCredits,
    this.price,
    this.currency,
    this.billingCycle,
    this.productId,
    this.isPopular,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory CoinPlan.fromJson(Map<String, dynamic> json) => CoinPlan(
        id: json["_id"],
        coins: json["coins"],
      sessionCredits: json["sessionCredits"] ?? json["coins"],
      name: json["name"],
      description: json["description"],
        price: json["price"]?.toDouble(),
      currency: json["currency"],
      billingCycle: json["billingCycle"],
      productId: json["productId"] ?? json["slug"],
        isPopular: json["isPopular"],
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "coins": coins,
        "sessionCredits": sessionCredits,
        "price": price,
        "currency": currency,
        "billingCycle": billingCycle,
        "productId": productId,
        "isPopular": isPopular,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

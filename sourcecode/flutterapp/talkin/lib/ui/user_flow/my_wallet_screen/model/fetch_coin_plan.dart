// To parse this JSON data, do
//
//     final fetchCoinPlan = fetchCoinPlanFromJson(jsonString);

import 'dart:convert';

FetchCoinPlan fetchCoinPlanFromJson(String str) =>
    FetchCoinPlan.fromJson(json.decode(str));

String fetchCoinPlanToJson(FetchCoinPlan data) => json.encode(data.toJson());

class FetchCoinPlan {
  bool? status;
  String? message;
  num? userCoin;
  bool? hasActiveSubscription;
  ActiveSubscription? activeSubscription;
  List<ActiveSubscription>? activeSubscriptions;
  List<CoinPlan>? data;

  FetchCoinPlan({
    this.status,
    this.message,
    this.userCoin,
    this.hasActiveSubscription,
    this.activeSubscription,
    this.activeSubscriptions,
    this.data,
  });

  factory FetchCoinPlan.fromJson(Map<String, dynamic> json) => FetchCoinPlan(
        status: json["status"],
        message: json["message"],
        userCoin: json["userCoin"] is num
            ? json["userCoin"]
            : num.tryParse(json["userCoin"]?.toString() ?? "0") ?? 0,
        hasActiveSubscription: json["hasActiveSubscription"],
        activeSubscription: json["activeSubscription"] == null
            ? null
            : ActiveSubscription.fromJson(json["activeSubscription"]),
        activeSubscriptions: json["activeSubscriptions"] == null
            ? []
            : List<ActiveSubscription>.from(json["activeSubscriptions"]!
                .map((x) => ActiveSubscription.fromJson(x))),
        data: json["data"] == null
            ? []
            : List<CoinPlan>.from(
                json["data"]!.map((x) => CoinPlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "userCoin": userCoin,
        "hasActiveSubscription": hasActiveSubscription,
        "activeSubscription": activeSubscription?.toJson(),
        "activeSubscriptions": activeSubscriptions == null
            ? []
            : List<dynamic>.from(activeSubscriptions!.map((x) => x.toJson())),
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ActiveSubscription {
  String? id;
  String? planId;
  String? planName;
  String? appleProductId;
  String? googleProductId;
  String? paymentGateway;
  String? purchasePlatform;
  String? status;
  bool? autoRenew;
  DateTime? startsAt;
  DateTime? endsAt;
  int? remainingSessionCredits;

  ActiveSubscription({
    this.id,
    this.planId,
    this.planName,
    this.appleProductId,
    this.googleProductId,
    this.paymentGateway,
    this.purchasePlatform,
    this.status,
    this.autoRenew,
    this.startsAt,
    this.endsAt,
    this.remainingSessionCredits,
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    final planIdValue = json["planId"];
    String? normalizedPlanId;
    if (planIdValue is Map<String, dynamic>) {
      normalizedPlanId = planIdValue["_id"]?.toString();
    } else {
      normalizedPlanId = planIdValue?.toString();
    }

    return ActiveSubscription(
      id: json["_id"]?.toString(),
      planId: normalizedPlanId,
      planName: json["planName"]?.toString(),
      appleProductId: json["appleProductId"]?.toString(),
      googleProductId: json["googleProductId"]?.toString(),
      paymentGateway: json["paymentGateway"]?.toString(),
      purchasePlatform: json["purchasePlatform"]?.toString(),
      status: json["status"]?.toString(),
      autoRenew: json["autoRenew"] is bool
          ? json["autoRenew"]
          : json["autoRenew"] == null
              ? null
              : json["autoRenew"].toString().toLowerCase() == 'true',
      startsAt: json["startsAt"] == null
          ? null
          : DateTime.tryParse(json["startsAt"].toString()),
      endsAt: json["endsAt"] == null
          ? null
          : DateTime.tryParse(json["endsAt"].toString()),
      remainingSessionCredits: json["remainingSessionCredits"] is int
          ? json["remainingSessionCredits"]
          : int.tryParse(json["remainingSessionCredits"]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "planId": planId,
        "planName": planName,
        "appleProductId": appleProductId,
        "googleProductId": googleProductId,
        "paymentGateway": paymentGateway,
        "purchasePlatform": purchasePlatform,
        "status": status,
        "autoRenew": autoRenew,
        "startsAt": startsAt?.toIso8601String(),
        "endsAt": endsAt?.toIso8601String(),
        "remainingSessionCredits": remainingSessionCredits,
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
  String? appleProductId;
  String? googleProductId;
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
    this.appleProductId,
    this.googleProductId,
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
        appleProductId: json["appleProductId"],
        googleProductId: json["googleProductId"],
        isPopular: json["isPopular"],
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
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
        "appleProductId": appleProductId,
        "googleProductId": googleProductId,
        "isPopular": isPopular,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

// To parse this JSON data, do
//
//     final purchaseCoinPlan = purchaseCoinPlanFromJson(jsonString);

import 'dart:convert';

PurchaseCoinPlan purchaseCoinPlanFromJson(String str) =>
    PurchaseCoinPlan.fromJson(json.decode(str));

String purchaseCoinPlanToJson(PurchaseCoinPlan data) =>
    json.encode(data.toJson());

class PurchaseCoinPlan {
  bool? status;
  String? message;
  int? totalCoins;
  HistoryRecord? historyRecord;
  PurchaseAuth? auth;
  bool? duplicate;
  bool? linkedExistingAccount;

  PurchaseCoinPlan({
    this.status,
    this.message,
    this.totalCoins,
    this.historyRecord,
    this.auth,
    this.duplicate,
    this.linkedExistingAccount,
  });

  factory PurchaseCoinPlan.fromJson(Map<String, dynamic> json) =>
      PurchaseCoinPlan(
        status: json["status"],
        message: json["message"],
        totalCoins: json["totalCoins"],
        historyRecord: json["historyRecord"] == null
            ? null
            : HistoryRecord.fromJson(json["historyRecord"]),
        auth: json["auth"] == null ? null : PurchaseAuth.fromJson(json["auth"]),
        duplicate: json["duplicate"],
        linkedExistingAccount: json["linkedExistingAccount"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "totalCoins": totalCoins,
        "historyRecord": historyRecord?.toJson(),
        "auth": auth?.toJson(),
        "duplicate": duplicate,
        "linkedExistingAccount": linkedExistingAccount,
      };
}

class PurchaseAuth {
  String? firebaseId;
  String? customToken;
  PurchaseUser? user;

  PurchaseAuth({
    this.firebaseId,
    this.customToken,
    this.user,
  });

  factory PurchaseAuth.fromJson(Map<String, dynamic> json) => PurchaseAuth(
        firebaseId: json["firebaseId"],
        customToken: json["customToken"],
        user: json["user"] == null ? null : PurchaseUser.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "firebaseId": firebaseId,
        "customToken": customToken,
        "user": user?.toJson(),
      };
}

class PurchaseUser {
  String? id;
  String? firebaseId;
  int? loginType;
  String? nickName;
  String? fullName;
  String? email;
  String? profilePic;
  String? phoneNumber;
  String? birthDate;
  String? gender;
  String? country;
  String? countryFlag;
  bool? isGuestAccount;

  PurchaseUser({
    this.id,
    this.firebaseId,
    this.loginType,
    this.nickName,
    this.fullName,
    this.email,
    this.profilePic,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.country,
    this.countryFlag,
    this.isGuestAccount,
  });

  factory PurchaseUser.fromJson(Map<String, dynamic> json) => PurchaseUser(
        id: json["_id"],
        firebaseId: json["firebaseId"],
        loginType: json["loginType"],
        nickName: json["nickName"],
        fullName: json["fullName"],
        email: json["email"],
        profilePic: json["profilePic"],
        phoneNumber: json["phoneNumber"],
        birthDate: json["birthDate"],
        gender: json["gender"],
        country: json["country"],
        countryFlag: json["countryFlag"],
        isGuestAccount: json["isGuestAccount"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "firebaseId": firebaseId,
        "loginType": loginType,
        "nickName": nickName,
        "fullName": fullName,
        "email": email,
        "profilePic": profilePic,
        "phoneNumber": phoneNumber,
        "birthDate": birthDate,
        "gender": gender,
        "country": country,
        "countryFlag": countryFlag,
        "isGuestAccount": isGuestAccount,
      };
}

class HistoryRecord {
  String? transactionId;
  String? date;
  double? amountPaid;
  String? paymentMode;
  int? userCoin;

  HistoryRecord({
    this.transactionId,
    this.date,
    this.amountPaid,
    this.paymentMode,
    this.userCoin,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) => HistoryRecord(
        transactionId: json["transactionId"],
        date: json["date"],
        amountPaid: json["amountPaid"]?.toDouble(),
        paymentMode: json["paymentMode"],
        userCoin: json["userCoin"],
      );

  Map<String, dynamic> toJson() => {
        "transactionId": transactionId,
        "date": date,
        "amountPaid": amountPaid,
        "paymentMode": paymentMode,
        "userCoin": userCoin,
      };
}

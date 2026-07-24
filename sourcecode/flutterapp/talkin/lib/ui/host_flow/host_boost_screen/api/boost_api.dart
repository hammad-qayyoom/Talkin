import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class BoostPlanModel {
  final String? id;
  final String? name;
  final String? slug;
  final String? description;
  final int? durationHours;
  final String? durationLabel;
  final int? creditCost;
  final double? visibilityMultiplier;
  final int? sortOrder;
  final bool? isActive;

  BoostPlanModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.durationHours,
    this.durationLabel,
    this.creditCost,
    this.visibilityMultiplier,
    this.sortOrder,
    this.isActive,
  });

  factory BoostPlanModel.fromJson(Map<String, dynamic> json) => BoostPlanModel(
        id: json["_id"],
        name: json["name"],
        slug: json["slug"],
        description: json["description"],
        durationHours: json["durationHours"],
        durationLabel: json["durationLabel"],
        creditCost: json["creditCost"],
        visibilityMultiplier: (json["visibilityMultiplier"] ?? 1.0).toDouble(),
        sortOrder: json["sortOrder"],
        isActive: json["isActive"],
      );
}

class BoostActiveModel {
  final String? id;
  final String? planName;
  final String? durationLabel;
  final double? visibilityMultiplier;
  final int? creditsDeducted;
  final String? startedAt;
  final String? expiresAt;
  final String? status;
  final String? daysRemaining;
  final BoostMetadata? metadata;

  BoostActiveModel({
    this.id,
    this.planName,
    this.durationLabel,
    this.visibilityMultiplier,
    this.creditsDeducted,
    this.startedAt,
    this.expiresAt,
    this.status,
    this.daysRemaining,
    this.metadata,
  });

  factory BoostActiveModel.fromJson(Map<String, dynamic> json) => BoostActiveModel(
        id: json["_id"],
        planName: json["planName"],
        durationLabel: json["durationLabel"],
        visibilityMultiplier: (json["visibilityMultiplier"] ?? 1.0).toDouble(),
        creditsDeducted: json["creditsDeducted"],
        startedAt: json["startedAt"],
        expiresAt: json["expiresAt"],
        status: json["status"],
        daysRemaining: json["daysRemaining"]?.toString(),
        metadata: json["metadata"] != null ? BoostMetadata.fromJson(json["metadata"]) : null,
      );
}

class BoostMetadata {
  final int? impressions;
  final int? searchAppearances;
  final int? profileViews;
  final int? bookingClicks;
  final int? bookingsGenerated;
  final double? revenueGenerated;

  BoostMetadata({
    this.impressions,
    this.searchAppearances,
    this.profileViews,
    this.bookingClicks,
    this.bookingsGenerated,
    this.revenueGenerated,
  });

  factory BoostMetadata.fromJson(Map<String, dynamic> json) => BoostMetadata(
        impressions: json["impressions"] ?? 0,
        searchAppearances: json["searchAppearances"] ?? 0,
        profileViews: json["profileViews"] ?? 0,
        bookingClicks: json["bookingClicks"] ?? 0,
        bookingsGenerated: json["bookingsGenerated"] ?? 0,
        revenueGenerated: (json["revenueGenerated"] ?? 0).toDouble(),
      );
}

class BoostAnalyticsModel {
  final BoostActiveModel? currentBoost;
  final BoostTotals? totals;
  final List<BoostDailyHistory>? dailyHistory;

  BoostAnalyticsModel({this.currentBoost, this.totals, this.dailyHistory});

  factory BoostAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      BoostAnalyticsModel(
        currentBoost: json["currentBoost"] != null
            ? BoostActiveModel.fromJson(json["currentBoost"])
            : null,
        totals: json["totals"] != null ? BoostTotals.fromJson(json["totals"]) : null,
        dailyHistory: json["dailyHistory"] != null
            ? List<BoostDailyHistory>.from(
                json["dailyHistory"].map((x) => BoostDailyHistory.fromJson(x)))
            : [],
      );
}

class BoostTotals {
  final int? impressions;
  final int? profileViews;
  final int? bookingsGenerated;
  final String? conversionRate;
  final double? revenueGenerated;

  BoostTotals({this.impressions, this.profileViews, this.bookingsGenerated, this.conversionRate, this.revenueGenerated});

  factory BoostTotals.fromJson(Map<String, dynamic> json) => BoostTotals(
        impressions: json["impressions"] ?? 0,
        profileViews: json["profileViews"] ?? 0,
        bookingsGenerated: json["bookingsGenerated"] ?? 0,
        conversionRate: json["conversionRate"] ?? "0%",
        revenueGenerated: (json["revenueGenerated"] ?? 0).toDouble(),
      );
}

class BoostDailyHistory {
  final String? date;
  final int? impressions;
  final int? profileViews;
  final int? bookingsGenerated;

  BoostDailyHistory({this.date, this.impressions, this.profileViews, this.bookingsGenerated});

  factory BoostDailyHistory.fromJson(Map<String, dynamic> json) => BoostDailyHistory(
        date: json["date"],
        impressions: json["impressions"] ?? 0,
        profileViews: json["profileViews"] ?? 0,
        bookingsGenerated: json["bookingsGenerated"] ?? 0,
      );
}

class BoostHistoryItem {
  final String? id;
  final String? planName;
  final int? creditsDeducted;
  final String? startedAt;
  final String? expiresAt;
  final String? status;
  final String? daysRemaining;

  BoostHistoryItem({this.id, this.planName, this.creditsDeducted, this.startedAt, this.expiresAt, this.status, this.daysRemaining});

  factory BoostHistoryItem.fromJson(Map<String, dynamic> json) => BoostHistoryItem(
        id: json["_id"],
        planName: json["planName"],
        creditsDeducted: json["creditsDeducted"],
        startedAt: json["startedAt"],
        expiresAt: json["expiresAt"],
        status: json["status"],
        daysRemaining: json["daysRemaining"]?.toString(),
      );
}

class BoostApi {
  static Future<List<BoostPlanModel>?> fetchPlans() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Boost Plans Api Calling...");

    final uri = Uri.parse("${Api.baseUrl}api/v2/experts/boost/plans");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      Utils.showLog("Boost Plans Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == true && jsonResponse["data"] != null) {
          return List<BoostPlanModel>.from(
            jsonResponse["data"].map((x) => BoostPlanModel.fromJson(x)),
          );
        }
      }
    } catch (e) {
      Utils.showLog("Boost Plans Api Error => ${e.toString()}");
    }
    return null;
  }

  static Future<BoostActiveModel?> fetchActiveBoost() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Active Boost Api Calling...");

    final uri = Uri.parse("${Api.baseUrl}api/v2/experts/boost/active");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      Utils.showLog("Active Boost Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == true && jsonResponse["data"] != null) {
          return BoostActiveModel.fromJson(jsonResponse["data"]);
        }
      }
    } catch (e) {
      Utils.showLog("Active Boost Api Error => ${e.toString()}");
    }
    return null;
  }

  static Future<BoostAnalyticsModel?> fetchAnalytics() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Boost Analytics Api Calling...");

    final uri = Uri.parse("${Api.baseUrl}api/v2/experts/boost/analytics");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      Utils.showLog("Boost Analytics Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == true && jsonResponse["data"] != null) {
          return BoostAnalyticsModel.fromJson(jsonResponse["data"]);
        }
      }
    } catch (e) {
      Utils.showLog("Boost Analytics Api Error => ${e.toString()}");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> activateBoost(String boostPlanId) async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Activate Boost Api Calling...");

    final uri = Uri.parse("${Api.baseUrl}api/v2/experts/boost/activate");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
      "Content-Type": "application/json",
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({"boostPlanId": boostPlanId}),
      );
      Utils.showLog("Activate Boost Api Response => ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      Utils.showLog("Activate Boost Api Error => ${e.toString()}");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> extendBoost(String boostPlanId) async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Extend Boost Api Calling...");

    final uri = Uri.parse("${Api.baseUrl}api/v2/experts/boost/extend");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
      "Content-Type": "application/json",
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({"boostPlanId": boostPlanId}),
      );
      Utils.showLog("Extend Boost Api Response => ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      Utils.showLog("Extend Boost Api Error => ${e.toString()}");
    }
    return null;
  }

  static Future<List<BoostHistoryItem>?> fetchHistory({int page = 1}) async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Boost History Api Calling...");

    final queryParameters = {
      "start": page.toString(),
      "limit": "20",
    };
    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse("${Api.baseUrl}api/v2/experts/boost/history?$query");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      Utils.showLog("Boost History Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == true && jsonResponse["data"] != null) {
          return List<BoostHistoryItem>.from(
            jsonResponse["data"].map((x) => BoostHistoryItem.fromJson(x)),
          );
        }
      }
    } catch (e) {
      Utils.showLog("Boost History Api Error => ${e.toString()}");
    }
    return null;
  }
}

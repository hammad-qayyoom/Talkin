import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/common/recording_subscription/model/recording_subscription_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class RecordingSubscriptionApi {
  // 0. Get available Recording Storage Plans
  static Future<List<RecordingStoragePlanModel>?> getPlans() async {
    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("RecordingSubscriptionApi getPlans Calling...");

    final uri = Uri.parse(Api.recordingSubscriptionPlans);
    final headers = {
      ApiParams.key: Api.secretKey,
      "Content-Type": "application/json",
      if (token != null) ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map((e) => RecordingStoragePlanModel.fromJson(e))
              .toList();
        }
      }
    } catch (error) {
      Utils.showLog("RecordingSubscriptionApi getPlans Error => $error");
    }
    return null;
  }

  // 1. Check if both participants are eligible for recording
  static Future<RecordingEligibilityModel?> checkEligibility(String expertId) async {
    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("RecordingSubscriptionApi checkEligibility Calling...");

    final uri = Uri.parse("${Api.recordingSubscriptionCheckEligibility}expertId=$expertId");
    final headers = {
      ApiParams.key: Api.secretKey,
      "Content-Type": "application/json",
      ApiParams.authToken: ApiParams.tokenStartPoint + (token ?? ""),
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return RecordingEligibilityModel.fromJson(jsonResponse);
      }
    } catch (error) {
      Utils.showLog("RecordingSubscriptionApi checkEligibility Error => $error");
    }
    return null;
  }

  // 2. Purchase or renew subscription
  static Future<RecordingSubscriptionModel?> purchasePlan({String role = "user", String? planId, String paymentGateway = "system"}) async {
    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("RecordingSubscriptionApi purchasePlan Calling...");

    final uri = Uri.parse(Api.recordingSubscriptionPurchase);
    final headers = {
      ApiParams.key: Api.secretKey,
      "Content-Type": "application/json",
      ApiParams.authToken: ApiParams.tokenStartPoint + (token ?? ""),
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    final body = <String, dynamic>{
      "role": role,
      "paymentGateway": paymentGateway,
      "gatewaySubscriptionId": "sub_${DateTime.now().millisecondsSinceEpoch}",
    };
    if (planId != null) body["planId"] = planId;

    try {
      final response = await http.post(uri, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['subscription'] != null) {
          return RecordingSubscriptionModel.fromJson(jsonResponse['subscription']);
        }
      }
    } catch (error) {
      Utils.showLog("RecordingSubscriptionApi purchasePlan Error => $error");
    }
    return null;
  }

  // 3. Get current subscription status
  static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    final token = await FirebaseAccessToken.onGet();
    final uri = Uri.parse(Api.recordingSubscriptionStatus);
    final headers = {
      ApiParams.key: Api.secretKey,
      "Content-Type": "application/json",
      ApiParams.authToken: ApiParams.tokenStartPoint + (token ?? ""),
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (error) {
      Utils.showLog("RecordingSubscriptionApi getSubscriptionStatus Error => $error");
    }
    return null;
  }

  // 4. Get User's Consultation Recordings
  static Future<Map<String, dynamic>?> getMyRecordings() async {
    final token = await FirebaseAccessToken.onGet();
    final uri = Uri.parse(Api.recordingSubscriptionMyRecordings);
    final headers = {
      ApiParams.key: Api.secretKey,
      "Content-Type": "application/json",
      ApiParams.authToken: ApiParams.tokenStartPoint + (token ?? ""),
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (error) {
      Utils.showLog("RecordingSubscriptionApi getMyRecordings Error => $error");
    }
    return null;
  }

  // 5. Delete a recording permanently
  static Future<bool> deleteRecording(String recordingId) async {
    final token = await FirebaseAccessToken.onGet();
    Utils.showLog("RecordingSubscriptionApi deleteRecording Calling... recordingId=$recordingId");

    final uri = Uri.parse("${Api.recordingSubscriptionDelete}/$recordingId");
    final headers = {
      ApiParams.key: Api.secretKey,
      "Content-Type": "application/json",
      ApiParams.authToken: ApiParams.tokenStartPoint + (token ?? ""),
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    try {
      final response = await http.delete(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] == true;
      }
    } catch (error) {
      Utils.showLog("RecordingSubscriptionApi deleteRecording Error => $error");
    }
    return false;
  }
}

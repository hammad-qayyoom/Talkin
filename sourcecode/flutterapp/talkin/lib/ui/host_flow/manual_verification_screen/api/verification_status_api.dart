import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/manual_verification_screen/model/verification_status_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class VerificationStatusApi {
  static Future<VerificationStatusModel?> callApi() async {
    Utils.showLog("Verification Status Api Calling...");

    try {
      final token = await FirebaseAccessToken.onGet();
      final uid = Database.loginUserFirebaseId;

      final uri = Uri.parse(Api.expertVerificationStatus);

      final headers = {
        "key": Api.secretKey,
        "Content-Type": "application/json",
        "x-auth-token": "Bearer $token",
        "x-auth-uid": uid,
      };

      log("Verification Status Api uri :: $uri");
      log("Verification Status Api headers :: $headers");

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));

      log('Verification Status API STATUS CODE :: ${response.statusCode}');
      log('Verification Status API RESPONSE :: ${response.body}');

      final jsonResult = json.decode(response.body);
      return VerificationStatusModel.fromJson(jsonResult);
    } catch (e) {
      log("Verification Status Api Error :: $e");
      return null;
    }
  }
}

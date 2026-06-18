import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/manual_verification_screen/model/verification_status_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class VerificationSubmitApi {
  static Future<VerificationSubmitModel?> callApi({
    required List<String> filePaths,
  }) async {
    Utils.showLog("Verification Submit Api Calling...");

    try {
      final token = await FirebaseAccessToken.onGet();
      final uid = Database.loginUserFirebaseId;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.expertVerificationSubmit),
      );

      request.headers.addAll({
        "key": Api.secretKey,
        "Content-Type": "application/json",
        "x-auth-token": "Bearer $token",
        "x-auth-uid": uid,
      });

      for (final filePath in filePaths) {
        request.files.add(await http.MultipartFile.fromPath('documents', filePath));
      }

      log("Verification Submit Api files => ${filePaths.length}");

      final response = await request.send();
      log("Verification Submit Api status => ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      final jsonResult = jsonDecode(responseBody);
      Utils.showLog("Verification Submit Api Body => $jsonResult");

      return VerificationSubmitModel.fromJson(jsonResult);
    } catch (e) {
      Utils.showLog("Verification Submit Api Error => $e");
      return null;
    }
  }
}

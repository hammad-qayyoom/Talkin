import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/setting_screen/model/delete_user_account_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class VerifyDeleteOtpApi {
  static Future<DeleteUserResponseModel?> callApi({required String otp}) async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Verify Delete OTP Api Calling...");

    final uri = Uri.parse(Api.verifyDeleteAccountOTP);
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    log("Verify Delete OTP Api URL ::$uri");

    final body = json.encode({
      "otp": otp,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("Verify Delete OTP Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return DeleteUserResponseModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Verify Delete OTP Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("Verify Delete OTP Api Response => ${e.toString()}");
    }
    return null;
  }
}

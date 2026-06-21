import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/setting_screen/model/delete_user_account_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class RequestDeleteOtpApi {
  static Future<DeleteUserResponseModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Request Delete OTP Api Calling...");

    final uri = Uri.parse(Api.requestDeleteAccountOTP);
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    log("Request Delete OTP Api URL ::$uri");

    try {
      final response = await http.post(uri, headers: headers);

      Utils.showLog("Request Delete OTP Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return DeleteUserResponseModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Request Delete OTP Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("Request Delete OTP Api Response => ${e.toString()}");
    }
    return null;
  }
}

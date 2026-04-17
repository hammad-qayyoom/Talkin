import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/user_notification/model/user_notification_clear_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class NotificationClearApi {
  static Future<NotificationClearModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog(" Notification clear Api Calling...");

    final uri = Uri.parse(Api.notificationClear);
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    log(" Notification clear Api URL ::$uri");

    try {
      final response = await http.delete(uri, headers: headers);

      Utils.showLog(" Notification clear Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return NotificationClearModel.fromJson(jsonResponse);
      } else {
        Utils.showLog(" Notification clear Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog(" Notification clear Api Response => ${e.toString()}");
    }
    return null;
  }
}

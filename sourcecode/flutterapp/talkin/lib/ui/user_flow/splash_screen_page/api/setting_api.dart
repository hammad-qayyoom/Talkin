import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/guest_auth.dart';
import 'package:notisboard/utils/utils.dart';

class SettingApi {
  static Future<SettingApiModel?> callApi() async {
    Utils.showLog("Setting Api Calling...");

    final uri = Uri.parse(Api.settingAPi);

    Utils.showLog("Setting uri => $uri");

    final headers = await GuestAuth.headers(allowGuest: true);

    log("Setting api headers  $headers");
    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        Utils.showLog("Setting Response => ${response.body}");
        Utils.showLog("Setting Response.status code => ${response.statusCode}");

        return SettingApiModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Setting StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Setting Api Error => $error");
    }
    return null;
  }
}

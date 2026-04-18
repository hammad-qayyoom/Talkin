import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/host_home_screen/model/growth_spotlight_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class GrowthSpotlightApi {
  static Future<GrowthSpotlightModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet();

    Utils.showLog("Growth Spotlight Api Calling...");

    final uri = Uri.parse(Api.listenerGrowthSpotlight);
    final headers = {
      ApiParams.key: Api.secretKey,
      "Content-Type": "application/json",
      ApiParams.authToken: ApiParams.tokenStartPoint + (token ?? ""),
      ApiParams.authUid: Database.loginUserFirebaseId,
    };

    log("Growth Spotlight Api url => $uri");
    log("Growth Spotlight Api headers => $headers");

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("Growth Spotlight Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return GrowthSpotlightModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Growth Spotlight Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Growth Spotlight Api Error => $error");
    }

    return null;
  }
}

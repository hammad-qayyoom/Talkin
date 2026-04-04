import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class UserCoinApi {
  static Future<UserCoinModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("User Session Credit Api Calling...");

    final uri = Uri.parse(Api.userCoin);

    Utils.showLog("User Session Credit Api url => $uri");

    final authUid = Database.loginUserFirebaseId.isNotEmpty
        ? Database.loginUserFirebaseId
        : (Database.fetchLoginUserProfileModel?.user?.firebaseId ?? "");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: authUid,
    };

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("User Session Credit Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UserCoinModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("User Session Credit Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("User Session Credit Api Response => ${e.toString()}");
    }
    return null;
  }
}

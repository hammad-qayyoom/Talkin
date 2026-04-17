import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class HostCoinApi {
  static Future<ListenerCoinModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Listener Session Credit Api Calling...");

    final queryParameters = {
      ApiParams.listenerId: Database.fetchListenerProfileModel?.data?.id,
    };
    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.listenerCoin + query);

    Utils.showLog("Listener Session Credit Api url => $uri");

    final headers = {ApiParams.key: Api.secretKey, ApiParams.authToken: ApiParams.tokenStartPoint + token, ApiParams.authUid: Database.loginUserFirebaseId};

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("Listener Session Credit Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ListenerCoinModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Listener Session Credit Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("Listener Session Credit Api Response => ${e.toString()}");
    }
    return null;
  }
}

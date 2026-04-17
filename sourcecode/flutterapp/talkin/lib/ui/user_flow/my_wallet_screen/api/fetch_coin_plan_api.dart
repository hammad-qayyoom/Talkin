import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class FetchCoinPlanApi {
  static Future<FetchCoinPlan?> callApi({
    required String uid,
    required String token,
  }) async {
    Utils.showLog("Fetch Session Credit plan Api Calling...");

    final uri = Uri.parse(Api.fetchCoinPlan);

    Utils.showLog("Fetch Session Credit plan Api url => $uri");

    final authUid = uid.isNotEmpty ? uid : (Database.fetchLoginUserProfileModel?.user?.firebaseId ?? "");

    final headers = {ApiParams.key: Api.secretKey, ApiParams.authToken: ApiParams.tokenStartPoint + token, ApiParams.authUid: authUid};

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("Fetch Session Credit plan Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        return FetchCoinPlan.fromJson(jsonResponse);
      } else {
        Utils.showLog("Fetch Session Credit plan Api StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Fetch Session Credit plan Api Error => $error");
    }
    return null;
  }
}

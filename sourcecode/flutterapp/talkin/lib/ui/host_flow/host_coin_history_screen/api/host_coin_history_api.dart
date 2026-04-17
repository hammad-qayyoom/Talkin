import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/host_coin_history_screen/model/coin_history_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class HostCoinHistoryApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static String _resolveListenerId() {
    final fromListenerProfile =
        (Database.fetchListenerProfileModel?.data?.id ?? '').toString().trim();
    if (fromListenerProfile.isNotEmpty) {
      return fromListenerProfile;
    }

    final fromLoginProfile =
        (Database.fetchLoginUserProfileModel?.user?.listenerId ?? '')
            .toString()
            .trim();
    if (fromLoginProfile.isNotEmpty) {
      return fromLoginProfile;
    }

    return Database.loginListenerId.trim();
  }

  static Future<HostCoinHistoryModel?> callApi({
    String? startDate,
    String? endDate,
  }) async {
    Utils.showLog("Host history Api Calling...");

    final listenerId = _resolveListenerId();
    if (listenerId.isEmpty) {
      Utils.showLog(
          "Host Session Credit history skipped: missing listenerId context.");
      return HostCoinHistoryModel(
        status: false,
        message: 'Unable to fetch history. Missing expert id.',
        data: const [],
      );
    }

    final token = await FirebaseAccessToken.onGet() ?? '';

    startPagination += 1;

    final Map<String, String> queryParameters = {
      ApiParams.listenerId: listenerId,
      ApiParams.startDate: startDate ?? "All",
      ApiParams.endDate: endDate ?? "All",
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Host history queryParameters ::$queryParameters");

    final uri = Uri.parse(Api.listenerCoinHistory +
        (Uri(queryParameters: queryParameters).query));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: 'application/json',
    };
    Utils.showLog("Host Session Credit history Api uri :: $uri");
    Utils.showLog("Host Session Credit history Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Host Session Credit history API STATUS CODE :: ${response.statusCode} \n Host history API RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostCoinHistoryModel.fromJson(jsonResponse);
      } else {
        Utils.showLog(
            "Host Session Credit history non-200 response: ${response.statusCode}");
        return HostCoinHistoryModel(
          status: false,
          message: 'Failed to fetch session credit history.',
          data: const [],
        );
      }
    } catch (e) {
      log("Host history :: $e");
    }
    return null;
  }
}

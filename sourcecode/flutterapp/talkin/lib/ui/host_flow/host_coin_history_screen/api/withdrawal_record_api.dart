import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/host_flow/host_coin_history_screen/model/withdrawal_record_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class WithdrawalRecordApi {
  static int startPagination = 0;
  static int limitPagination = 20;
  WithdrawalRecordModel? withdrawalRecordModel;

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

  static Future<WithdrawalRecordModel?> callApi({
    String? startDate,
    String? endDate,
  }) async {
    Utils.showLog("Withdrawal history Api Calling...");

    final listenerId = _resolveListenerId();
    if (listenerId.isEmpty) {
      Utils.showLog("Withdrawal history skipped: missing listenerId context.");
      return WithdrawalRecordModel(
        status: false,
        message: 'Unable to fetch withdrawals. Missing expert id.',
        data: const [],
      );
    }

    final token = await FirebaseAccessToken.onGet() ?? '';

    startPagination += 1;

    final Map<String, String> queryParameters = {
      ApiParams.listenerId: listenerId,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
      ApiParams.startDate: startDate ?? "All",
      ApiParams.endDate: endDate ?? "All",
    };

    log("Withdrawal history queryParameters ::$queryParameters");

    final uri = Uri.parse(Api.withdrawalRecord)
        .replace(queryParameters: queryParameters);

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: ApiParams.tokenStartPoint + token,
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: 'application/json',
    };
    Utils.showLog("Withdrawal history Api uri :: $uri");
    Utils.showLog("Withdrawal history Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Withdrawal history API STATUS CODE :: ${response.statusCode} \n Withdrawal history API RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return WithdrawalRecordModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Withdrawal history :: $e");
    }
    return null;
  }
}

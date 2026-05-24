import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class PushTokenSyncApi {
  static Future<bool> callApi({required String fcmToken}) async {
    final resolvedToken = fcmToken.trim();
    if (resolvedToken.isEmpty || resolvedToken.startsWith('pending_fcm_')) {
      return false;
    }

    if (!Database.isLogin) {
      return false;
    }

    final authToken = await FirebaseAccessToken.onGet();
    if ((authToken ?? '').trim().isEmpty) {
      Utils.showLog('Push token sync skipped: auth token unavailable.');
      return false;
    }

    final uri = Uri.parse(Api.syncUserFcmToken);
    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: 'Bearer $authToken',
      ApiParams.contentType: 'application/json',
    };
    final body = json.encode({
      ApiParams.fcmToken: resolvedToken,
    });

    try {
      final response = await http
          .patch(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        Utils.showLog(
          'Push token sync failed: status=${response.statusCode} body=${response.body}',
        );
        return false;
      }

      final jsonResponse = json.decode(response.body);
      final isSuccess = jsonResponse is Map && jsonResponse['status'] == true;
      if (!isSuccess) {
        Utils.showLog('Push token sync rejected: ${response.body}');
      }
      return isSuccess;
    } catch (error) {
      Utils.showLog('Push token sync error => $error');
      return false;
    }
  }
}

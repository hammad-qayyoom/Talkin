import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class ModerationReportApi {
  static String _resolveEndpoint(String reportType) {
    switch (reportType) {
      case 'user':
        return Api.moderationReportUser;
      case 'chat_message':
        return Api.moderationReportChatMessage;
      case 'session':
        return Api.moderationReportSession;
      case 'feed_post':
        return Api.moderationReportFeedPost;
      default:
        return Api.moderationReportUser;
    }
  }

  static Future<Map<String, dynamic>?> submitReport({
    required String reportType,
    required String targetId,
    required String reasonCode,
    String reasonText = '',
    List<String> evidenceUrls = const [],
    String source = 'mobile',
  }) async {
    final token = await FirebaseAccessToken.onGet();
    final endpoint = _resolveEndpoint(reportType);

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          ApiParams.key: Api.secretKey,
          ApiParams.authToken: '${ApiParams.tokenStartPoint}$token',
          ApiParams.authUid: Database.loginUserFirebaseId,
          ApiParams.contentType: 'application/json',
        },
        body: jsonEncode({
          'reportType': reportType,
          'targetId': targetId,
          'reasonCode': reasonCode,
          'reasonText': reasonText,
          'evidenceUrls': evidenceUrls,
          'source': source,
        }),
      );

      if (response.body.isEmpty) {
        return null;
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error) {
      Utils.showLog('ModerationReportApi.submitReport error => $error');
      return null;
    }
  }
}

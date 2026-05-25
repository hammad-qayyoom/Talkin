import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/referral_screen/model/referral_summary_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class ReferralSummaryApi {
  static Future<ReferralSummaryModel?> callApi() async {
    Utils.showLog('Referral Summary Api Calling...');

    final token = await FirebaseAccessToken.onGet();
    final uid = Database.loginUserFirebaseId.trim().isNotEmpty
        ? Database.loginUserFirebaseId.trim()
        : (FirebaseAuth.instance.currentUser?.uid ?? '').trim();

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.contentType: 'application/json',
      ApiParams.authToken: 'Bearer ${token ?? ''}',
      if (uid.isNotEmpty) ApiParams.authUid: uid,
    };

    try {
      final response = await http.get(
        Uri.parse(Api.referralSummary),
        headers: headers,
      );

      Utils.showLog('Referral Summary StatusCode :: ${response.statusCode}');
      Utils.showLog('Referral Summary Response :: ${response.body}');

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return ReferralSummaryModel.fromJson(decoded);
      }
    } catch (error) {
      Utils.showLog('Referral Summary Api Error => $error');
    }

    return null;
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/profile_detail_screen/model/listener_profile_response_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/guest_auth.dart';
import 'package:notisboard/utils/utils.dart';

class ListenerProfileApi {
  static Future<ListenerProfileModel?> callApi({
    String? listenerId,
    String? expertId,
  }) async {
    Utils.showLog("Listener profile Api Calling...");

    final resolvedListenerId = (listenerId ?? '').trim();
    final resolvedExpertId = (expertId ?? '').trim();
    if (resolvedListenerId.isEmpty && resolvedExpertId.isEmpty) {
      Utils.showLog(
          "Listener profile Api skipped: missing listenerId/expertId");
      return null;
    }

    final uri = Uri.parse(Api.listenerProfile).replace(
      queryParameters: {
        if (resolvedListenerId.isNotEmpty)
          ApiParams.listenerId: resolvedListenerId,
        if (resolvedExpertId.isNotEmpty) ApiParams.expertId: resolvedExpertId,
      },
    );
    final headers = await GuestAuth.headers(allowGuest: true);
    Utils.showLog("Listener profile Api uri :: $uri");
    Utils.showLog("Listener profile Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Listener profile API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ListenerProfileModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Listener profile :: $e");
    }
    return null;
  }
}

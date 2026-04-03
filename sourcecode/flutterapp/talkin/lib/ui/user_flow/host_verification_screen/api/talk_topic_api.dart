import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class TalkTopicApi {
  static Future<TalkTopicsModel?> callApi() async {
    Utils.showLog("Categories Api Calling...");

    final uri = Uri.parse(Api.getTalkTopics);
    final headers = {ApiParams.key: Api.secretKey};

    Utils.showLog("Categories Api uri :: $uri");
    Utils.showLog("Categories Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Categories API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return TalkTopicsModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Categories api  :: $e");
    }
    return null;
  }
}

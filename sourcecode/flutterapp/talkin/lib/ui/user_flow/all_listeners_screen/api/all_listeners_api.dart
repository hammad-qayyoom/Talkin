import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/guest_auth.dart';
import 'package:notisboard/utils/utils.dart';

class AllListenersApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<TopListenersModel?> callApi({
    String? searchString,
    String? talkTopic,
    String? language,
    String? categoryId,
  }) async {
    Utils.showLog("All Listeners Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    if (searchString != null && searchString.isNotEmpty) {
      queryParameters[ApiParams.searchString] = searchString;
    }
    if (talkTopic != null && talkTopic.isNotEmpty) {
      queryParameters[ApiParams.talkTopic] = talkTopic;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParameters[ApiParams.categoryId] = categoryId;
    }
    if (language != null && language.isNotEmpty) {
      queryParameters[ApiParams.language] = language;
    }

    log("All Listeners queryParameters ::$queryParameters");

    final allListenersUri = Uri.parse(Api.allListeners).replace(
      queryParameters: {
        for (final entry in queryParameters.entries)
          entry.key: entry.value.toString(),
      },
    );
    final discoverUri = Uri.parse(Api.expertsDiscover).replace(
      queryParameters: {
        for (final entry in queryParameters.entries)
          (entry.key == ApiParams.searchString ? 'search' : entry.key):
              entry.value.toString(),
      },
    );
    final useAuthenticatedEndpoint = Database.isLogin;
    final uri = useAuthenticatedEndpoint ? allListenersUri : discoverUri;

    final headers = await GuestAuth.headers(allowGuest: true);
    Utils.showLog("All Listeners Api uri :: $uri");
    Utils.showLog("All Listeners Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('All Listeners API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['status'] == true) {
          return TopListenersModel.fromJson(jsonResponse);
        }
      }

      if (useAuthenticatedEndpoint) {
        Utils.showLog(
            "All Listeners primary endpoint failed, trying discover fallback.");
        final fallbackResponse = await http.get(
          discoverUri,
          headers: {
            ApiParams.key: Api.secretKey,
          },
        );

        Utils.showLog(
            "All Listeners Discover Fallback => ${fallbackResponse.body}");

        if (fallbackResponse.statusCode == 200) {
          final jsonResponse = json.decode(fallbackResponse.body);
          if (jsonResponse is Map<String, dynamic>) {
            return TopListenersModel.fromJson(jsonResponse);
          }
        }
      }
    } catch (e) {
      log("All Listeners :: $e");
    }
    return null;
  }
}

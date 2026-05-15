import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notisboard/services/location/user_location_service.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/guest_auth.dart';
import 'package:notisboard/utils/utils.dart';

class AllListenersApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Uri _discoverUri({
    required Map<String, dynamic> queryParameters,
    UserLocationData? userLocation,
  }) {
    final mappedQueryParameters = <String, String>{
      for (final entry in queryParameters.entries)
        (entry.key == ApiParams.searchString ? 'search' : entry.key):
            entry.value.toString(),
      if (userLocation != null) 'lat': userLocation.latitude.toString(),
      if (userLocation != null) 'lng': userLocation.longitude.toString(),
      if (userLocation != null) 'sortBy': 'distance',
      if (userLocation != null) 'sortOrder': 'asc',
    };

    return Uri.parse(Api.expertsDiscover)
        .replace(queryParameters: mappedQueryParameters);
  }

  static Uri _legacyAllListenersUri({
    required Map<String, dynamic> queryParameters,
  }) {
    return Uri.parse(Api.allListeners).replace(
      queryParameters: {
        for (final entry in queryParameters.entries)
          entry.key: entry.value.toString(),
      },
    );
  }

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

    final userLocation = await UserLocationService.resolveLocation();
    final discoverUri = _discoverUri(
      queryParameters: queryParameters,
      userLocation: userLocation,
    );
    final allListenersUri =
        _legacyAllListenersUri(queryParameters: queryParameters);
    final primaryUri = allListenersUri;

    final headers = await GuestAuth.headers(allowGuest: true);
    Utils.showLog("All Listeners Api uri :: $primaryUri");
    Utils.showLog("All Listeners Api headers :: $headers");

    try {
      final response = await http.get(primaryUri, headers: headers);

      log('All Listeners API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['status'] == true) {
          return TopListenersModel.fromJson(jsonResponse);
        }
      }

      Utils.showLog("All Listeners legacy failed, trying discover fallback.");
      final fallbackResponse = await http.get(
        discoverUri,
        headers: headers,
      );

      Utils.showLog(
          "All Listeners Discover Fallback => ${fallbackResponse.body}");

      if (fallbackResponse.statusCode == 200) {
        final jsonResponse = json.decode(fallbackResponse.body);
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['status'] == true) {
          return TopListenersModel.fromJson(jsonResponse);
        }
      }
    } catch (e) {
      log("All Listeners :: $e");
    }
    return null;
  }
}

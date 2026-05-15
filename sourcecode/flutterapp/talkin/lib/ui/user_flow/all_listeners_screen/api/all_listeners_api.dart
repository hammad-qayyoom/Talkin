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

  static bool _hasExperts(TopListenersModel? model) {
    return (model?.data ?? []).isNotEmpty;
  }

  static bool _hasLocationSortSignal(TopListenersModel model) {
    return (model.data ?? []).any(
      (expert) =>
          expert.distanceKm != null ||
          (expert.latitude != null && expert.longitude != null),
    );
  }

  static Future<TopListenersModel?> _fetchListeners({
    required Uri uri,
    required Map<String, String> headers,
    required String logLabel,
    bool requireLocationSortSignal = false,
  }) async {
    final response = await http.get(uri, headers: headers);

    log('$logLabel STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

    if (response.statusCode != 200) {
      return null;
    }

    final jsonResponse = json.decode(response.body);
    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse['status'] == true) {
      final model = TopListenersModel.fromJson(jsonResponse);
      model.data?.removeWhere(
        (expert) =>
            !expert.hasLegacyListener || (expert.id ?? '').trim().isEmpty,
      );
      if (requireLocationSortSignal && !_hasLocationSortSignal(model)) {
        Utils.showLog(
          "$logLabel skipped: no distance or coordinates in response.",
        );
        return null;
      }
      return model;
    }

    return null;
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

    final userLocation = UserLocationService.cachedLocation;
    final discoverUri = _discoverUri(
      queryParameters: queryParameters,
      userLocation: userLocation,
    );
    final allListenersUri =
        _legacyAllListenersUri(queryParameters: queryParameters);
    final hasLocation = userLocation != null;
    final primaryUri = hasLocation ? discoverUri : allListenersUri;
    final fallbackUri = hasLocation ? allListenersUri : discoverUri;

    final headers = await GuestAuth.headers(allowGuest: true);
    Utils.showLog("All Listeners Api uri :: $primaryUri");
    Utils.showLog("All Listeners Api headers :: $headers");

    try {
      final primaryModel = await _fetchListeners(
        uri: primaryUri,
        headers: headers,
        logLabel:
            hasLocation ? "All Listeners Discover Api" : "All Listeners Api",
        requireLocationSortSignal: hasLocation,
      );
      if (_hasExperts(primaryModel)) return primaryModel;

      Utils.showLog("All Listeners primary empty, trying fallback.");
      final fallbackModel = await _fetchListeners(
        uri: fallbackUri,
        headers: headers,
        logLabel: hasLocation
            ? "All Listeners Legacy Fallback"
            : "All Listeners Discover Fallback",
      );
      if (_hasExperts(fallbackModel)) return fallbackModel;

      return primaryModel ?? fallbackModel;
    } catch (e) {
      log("All Listeners :: $e");
    }
    return null;
  }
}

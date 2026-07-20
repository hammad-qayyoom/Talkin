import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/services/location/user_location_service.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/guest_auth.dart';
import 'package:notisboard/utils/utils.dart';

class TopListenersApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Uri _discoverUri({
    required String searchString,
    String? categoryId,
    UserLocationData? userLocation,
    String? consultationMode,
  }) {
    final normalizedSearch = searchString.trim().isEmpty ? "All" : searchString;

    return Uri.parse(Api.expertsDiscover).replace(
      queryParameters: {
        ApiParams.start: startPagination.toString(),
        ApiParams.limit: limitPagination.toString(),
        'search': normalizedSearch,
        if (categoryId != null && categoryId.isNotEmpty)
          ApiParams.categoryId: categoryId,
        if (userLocation != null) 'lat': userLocation.latitude.toString(),
        if (userLocation != null) 'lng': userLocation.longitude.toString(),
        if (userLocation != null) 'sortBy': 'distance',
        if (userLocation != null) 'sortOrder': 'asc',
        if (consultationMode != null && consultationMode.isNotEmpty)
          'consultationMode': consultationMode,
      },
    );
  }

  static Uri _topListenersUri({
    required String searchString,
    String? categoryId,
    String? consultationMode,
  }) {
    return Uri.parse(Api.topListeners).replace(
      queryParameters: {
        ApiParams.start: startPagination.toString(),
        ApiParams.limit: limitPagination.toString(),
        ApiParams.searchString: searchString,
        if (categoryId != null && categoryId.isNotEmpty)
          ApiParams.categoryId: categoryId,
        if (consultationMode != null && consultationMode.isNotEmpty)
          'consultationMode': consultationMode,
      },
    );
  }

  static bool _isSuccess(Map<String, dynamic> payload) {
    return payload['status'] == true;
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

    Utils.showLog("$logLabel Response => ${response.body}");

    if (response.statusCode != 200) {
      Utils.showLog("$logLabel StateCode Error => ${response.statusCode}");
      return null;
    }

    final jsonResponse = json.decode(response.body);
    if (jsonResponse is Map<String, dynamic> && _isSuccess(jsonResponse)) {
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
    required String searchString,
    String token = '',
    String uid = '',
    String? categoryId,
    String? consultationMode,
  }) async {
    Utils.showLog("Top Listeners Api Calling...");

    startPagination += 1;

    final userLocation = UserLocationService.cachedLocation;
    final discoverUri = _discoverUri(
      searchString: searchString,
      categoryId: categoryId,
      userLocation: userLocation,
      consultationMode: consultationMode,
    );
    final topUri = _topListenersUri(
      searchString: searchString, 
      categoryId: categoryId,
      consultationMode: consultationMode,
    );
    final hasLocation = userLocation != null;
    final primaryUri = hasLocation ? discoverUri : topUri;
    final fallbackUri = hasLocation ? topUri : discoverUri;

    Utils.showLog("Top Listeners Api url => $primaryUri");

    final headers =
        await GuestAuth.headers(contentType: false, allowGuest: true);

    try {
      final primaryModel = await _fetchListeners(
        uri: primaryUri,
        headers: headers,
        logLabel:
            hasLocation ? "Top Listeners Discover Api" : "Top Listeners Api",
        requireLocationSortSignal: hasLocation,
      );
      if (_hasExperts(primaryModel)) return primaryModel;

      Utils.showLog("Top Listeners primary empty, trying fallback.");
      final fallbackModel = await _fetchListeners(
        uri: fallbackUri,
        headers: headers,
        logLabel: hasLocation
            ? "Top Listeners Legacy Fallback"
            : "Top Listeners Discover Fallback",
      );
      if (_hasExperts(fallbackModel)) return fallbackModel;

      return primaryModel ?? fallbackModel;
    } catch (e) {
      Utils.showLog("Top Listeners Api Response => ${e.toString()}");
    }
    return null;
  }
}

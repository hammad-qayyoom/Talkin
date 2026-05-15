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
      },
    );
  }

  static Uri _topListenersUri({
    required String searchString,
    String? categoryId,
  }) {
    return Uri.parse(Api.topListeners).replace(
      queryParameters: {
        ApiParams.start: startPagination.toString(),
        ApiParams.limit: limitPagination.toString(),
        ApiParams.searchString: searchString,
        if (categoryId != null && categoryId.isNotEmpty)
          ApiParams.categoryId: categoryId,
      },
    );
  }

  static bool _isSuccess(Map<String, dynamic> payload) {
    return payload['status'] == true;
  }

  static Future<TopListenersModel?> callApi({
    required String searchString,
    String token = '',
    String uid = '',
    String? categoryId,
  }) async {
    Utils.showLog("Top Listeners Api Calling...");

    startPagination += 1;

    final userLocation = await UserLocationService.resolveLocation();
    final discoverUri = _discoverUri(
      searchString: searchString,
      categoryId: categoryId,
      userLocation: userLocation,
    );
    final topUri =
        _topListenersUri(searchString: searchString, categoryId: categoryId);
    final primaryUri = topUri;

    Utils.showLog("Top Listeners Api url => $primaryUri");

    final headers =
        await GuestAuth.headers(contentType: false, allowGuest: true);

    try {
      final response = await http.get(primaryUri, headers: headers);

      Utils.showLog("Top Listeners Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is Map<String, dynamic> && _isSuccess(jsonResponse)) {
          return TopListenersModel.fromJson(jsonResponse);
        }
      } else {
        Utils.showLog("Top Listeners Api StateCode Error");
      }

      Utils.showLog("Top Listeners legacy failed, trying discover fallback.");
      final fallbackResponse = await http.get(
        discoverUri,
        headers: headers,
      );

      Utils.showLog(
          "Top Listeners Discover Fallback => ${fallbackResponse.body}");

      if (fallbackResponse.statusCode == 200) {
        final jsonResponse = json.decode(fallbackResponse.body);
        if (jsonResponse is Map<String, dynamic> && _isSuccess(jsonResponse)) {
          return TopListenersModel.fromJson(jsonResponse);
        }
      }
    } catch (e) {
      Utils.showLog("Top Listeners Api Response => ${e.toString()}");
    }
    return null;
  }
}

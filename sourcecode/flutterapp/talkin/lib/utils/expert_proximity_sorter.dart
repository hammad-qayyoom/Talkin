import 'dart:math' as math;

import 'package:notisboard/services/location/user_location_service.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';

class ExpertProximitySorter {
  static Future<void> sortNearestFirst(List<TopListeners> experts) async {
    if (experts.length < 2) return;

    final userLocation = await UserLocationService.resolveLocation();
    if (userLocation == null) return;

    final indexedExperts = experts.asMap().entries.toList();
    indexedExperts.sort((left, right) {
      final leftDistance = _distanceInKm(left.value, userLocation);
      final rightDistance = _distanceInKm(right.value, userLocation);

      final leftHasDistance = leftDistance != null;
      final rightHasDistance = rightDistance != null;

      if (leftHasDistance && !rightHasDistance) return -1;
      if (!leftHasDistance && rightHasDistance) return 1;

      if (leftHasDistance && rightHasDistance) {
        final distanceDelta = leftDistance.compareTo(rightDistance);
        if (distanceDelta != 0) return distanceDelta;
      }

      return left.key.compareTo(right.key);
    });

    experts
      ..clear()
      ..addAll(indexedExperts.map((item) => item.value));
  }

  static double? _distanceInKm(
    TopListeners expert,
    UserLocationData userLocation,
  ) {
    if (expert.distanceKm != null && expert.distanceKm!.isFinite) {
      return expert.distanceKm;
    }

    if (expert.latitude == null ||
        expert.longitude == null ||
        !expert.latitude!.isFinite ||
        !expert.longitude!.isFinite) {
      return null;
    }

    return _haversineDistanceKm(
      fromLat: userLocation.latitude,
      fromLng: userLocation.longitude,
      toLat: expert.latitude!,
      toLng: expert.longitude!,
    );
  }

  static double _haversineDistanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    const earthRadiusKm = 6371.0;
    const degreeToRadian = math.pi / 180;

    final deltaLat = (toLat - fromLat) * degreeToRadian;
    final deltaLng = (toLng - fromLng) * degreeToRadian;

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(fromLat * degreeToRadian) *
            math.cos(toLat * degreeToRadian) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }
}

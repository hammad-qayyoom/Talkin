import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/ip_api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class UserLocationData {
  final double latitude;
  final double longitude;

  const UserLocationData({
    required this.latitude,
    required this.longitude,
  });
}

class UserLocationService {
  static const Duration _cacheTtl = Duration(minutes: 10);

  static UserLocationData? _memoryCache;
  static DateTime? _cachedAt;
  static Future<UserLocationData?>? _inFlightRequest;
  static Future<UserLocationData?>? _inFlightPreciseRequest;

  static UserLocationData? get cachedLocation => _readCachedLocation();

  static Future<UserLocationData?> primeStartupLocation() async {
    final pending = _inFlightRequest;
    if (pending != null) {
      return pending;
    }

    final request = _primeStartupLocationInternal();
    _inFlightRequest = request;

    try {
      return await request;
    } finally {
      if (identical(_inFlightRequest, request)) {
        _inFlightRequest = null;
      }
    }
  }

  static Future<UserLocationData?> resolveLocation() async {
    final cached = _readCachedLocation();
    if (cached != null) {
      return cached;
    }

    final pending = _inFlightRequest;
    if (pending != null) {
      return pending;
    }

    final request = _resolveInternal();
    _inFlightRequest = request;

    try {
      return await request;
    } finally {
      if (identical(_inFlightRequest, request)) {
        _inFlightRequest = null;
      }
    }
  }

  static Future<UserLocationData?> _primeStartupLocationInternal() async {
    final preciseLocation =
        await _resolvePreciseLocation(requestPermission: false);
    if (preciseLocation != null) {
      await _cacheLocation(preciseLocation);
      return preciseLocation;
    }

    final cached = _readCachedLocation();
    if (cached != null) {
      return cached;
    }

    final fallbackIpLocation = await _resolveIpLocation();
    if (fallbackIpLocation != null) {
      await _cacheLocation(fallbackIpLocation);
      return fallbackIpLocation;
    }

    return null;
  }

  static UserLocationData? _readCachedLocation() {
    if (_memoryCache != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) <= _cacheTtl) {
      return _memoryCache;
    }

    final lat = Database.userLatitude;
    final lng = Database.userLongitude;

    if (_isValidCoordinate(lat) && _isValidCoordinate(lng)) {
      final location = UserLocationData(
        latitude: lat!,
        longitude: lng!,
      );
      _memoryCache = location;
      _cachedAt = DateTime.now();
      return location;
    }

    return null;
  }

  static Future<UserLocationData?> _resolveInternal() async {
    final preciseLocation =
        await _resolvePreciseLocation(requestPermission: true);
    if (preciseLocation != null) {
      await _cacheLocation(preciseLocation);
      return preciseLocation;
    }

    final fallbackIpLocation = await _resolveIpLocation();
    if (fallbackIpLocation != null) {
      await _cacheLocation(fallbackIpLocation);
      return fallbackIpLocation;
    }

    return null;
  }

  static Future<UserLocationData?> requestPreciseLocation() async {
    final pendingPreciseRequest = _inFlightPreciseRequest;
    if (pendingPreciseRequest != null) {
      return pendingPreciseRequest;
    }

    final startupRequest = _inFlightRequest;
    if (startupRequest != null) {
      try {
        await startupRequest;
      } catch (_) {
        // Continue with the explicit Home-screen permission request.
      }
    }

    final request = _requestPreciseLocationInternal();
    _inFlightPreciseRequest = request;

    try {
      return await request;
    } finally {
      if (identical(_inFlightPreciseRequest, request)) {
        _inFlightPreciseRequest = null;
      }
    }
  }

  static Future<UserLocationData?> _requestPreciseLocationInternal() async {
    final preciseLocation =
        await _resolvePreciseLocation(requestPermission: true);
    if (preciseLocation != null) {
      await _cacheLocation(preciseLocation);
    }
    return preciseLocation;
  }

  static Future<UserLocationData?> _resolvePreciseLocation({
    required bool requestPermission,
  }) async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (_isValidCoordinate(lastKnownPosition?.latitude) &&
          _isValidCoordinate(lastKnownPosition?.longitude)) {
        return UserLocationData(
          latitude: lastKnownPosition!.latitude,
          longitude: lastKnownPosition.longitude,
        );
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      if (_isValidCoordinate(currentPosition.latitude) &&
          _isValidCoordinate(currentPosition.longitude)) {
        return UserLocationData(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
        );
      }
    } catch (error) {
      Utils.showLog("UserLocationService precise location error => $error");
    }

    return null;
  }

  static Future<UserLocationData?> _resolveIpLocation() async {
    try {
      final ipLocation = await IpApi.callApi();
      final lat = ipLocation?.lat;
      final lng = ipLocation?.lon;

      if (_isValidCoordinate(lat) && _isValidCoordinate(lng)) {
        return UserLocationData(
          latitude: lat!,
          longitude: lng!,
        );
      }
    } catch (error) {
      Utils.showLog("UserLocationService IP fallback error => $error");
    }

    return null;
  }

  static bool _isValidCoordinate(double? value) {
    return value != null && value.isFinite;
  }

  static Future<void> _cacheLocation(UserLocationData location) async {
    _memoryCache = location;
    _cachedAt = DateTime.now();
    await Database.onSetUserLatitude(location.latitude);
    await Database.onSetUserLongitude(location.longitude);
  }
}

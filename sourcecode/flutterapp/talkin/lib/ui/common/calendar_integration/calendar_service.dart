import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';

class CalendarService {
  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet() ?? '';
    return {
      'Content-Type': 'application/json',
      'key': Api.secretKey,
      'x-auth-token': 'Bearer $token',
      'x-auth-uid': Database.loginUserFirebaseId,
    };
  }

  static Future<Map<String, dynamic>> getConnections() async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse(Api.calendarConnections),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> connectGoogle() async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.calendarConnectGoogle),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> connectGoogleComplete({
    required String code,
    required String state,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.calendarConnectGoogleComplete),
        headers: headers,
        body: json.encode({'code': code, 'state': state}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> connectApple({
    required String email,
    required String appPassword,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.calendarConnectApple),
        headers: headers,
        body: json.encode({'email': email, 'appPassword': appPassword}),
      );
      final body = json.decode(response.body);
      return body;
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> disconnect(String connectionId) async {
    try {
      final headers = await _headers();
      final response = await http.delete(
        Uri.parse('${Api.calendarDisconnect}$connectionId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> triggerSync(String connectionId) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse('${Api.calendarSync}$connectionId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getEvents({
    required String startAt,
    required String endAt,
  }) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(Api.calendarEvents).replace(
        queryParameters: {'startAt': startAt, 'endAt': endAt},
      );
      final response = await http.get(uri, headers: headers);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSettings(
    String connectionId, {
    bool? syncEnabled,
    int? syncIntervalMinutes,
    bool? importBusyTimes,
    bool? exportBookings,
  }) async {
    try {
      final headers = await _headers();
      final body = <String, dynamic>{};
      if (syncEnabled != null) body['syncEnabled'] = syncEnabled;
      if (syncIntervalMinutes != null) body['syncIntervalMinutes'] = syncIntervalMinutes;
      if (importBusyTimes != null) body['importBusyTimes'] = importBusyTimes;
      if (exportBookings != null) body['exportBookings'] = exportBookings;

      final response = await http.put(
        Uri.parse('${Api.calendarSettings}$connectionId'),
        headers: headers,
        body: json.encode(body),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }
}

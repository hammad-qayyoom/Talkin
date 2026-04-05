import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';

class SessionBookingService {
  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet();

    return {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: 'Bearer $token',
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: 'application/json',
    };
  }

  static Future<Map<String, dynamic>> getAvailableSlots({
    String? listenerId,
    String? expertId,
    required DateTime date,
    required String callType,
    int? clientTimezoneOffsetMinutes,
    bool includeBooked = false,
  }) async {
    try {
      final normalizedListenerId = (listenerId ?? '').trim();
      final normalizedExpertId = (expertId ?? '').trim();
      final effectiveClientTimezoneOffsetMinutes =
          clientTimezoneOffsetMinutes ??
              DateTime.now().timeZoneOffset.inMinutes;

      if (normalizedListenerId.isEmpty && normalizedExpertId.isEmpty) {
        return {
          'status': false,
          'message': 'listenerId or expertId is required.',
        };
      }

      final headers = await _headers();
      final dateValue =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final uri = Uri.parse(Api.sessionGetAvailableSlots).replace(
        queryParameters: {
          if (normalizedListenerId.isNotEmpty)
            'listenerId': normalizedListenerId,
          if (normalizedExpertId.isNotEmpty) 'expertId': normalizedExpertId,
          'date': dateValue,
          'callType': callType.toLowerCase(),
          'clientTimezoneOffsetMinutes':
              effectiveClientTimezoneOffsetMinutes.toString(),
          if (includeBooked) 'includeBooked': 'true',
        },
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid slots response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch available slots.',
      };
    }
  }

  static Future<Map<String, dynamic>> bookSession({
    required String userId,
    String? listenerId,
    String? expertId,
    required String callType,
    required DateTime slotStartAt,
    required int slotDurationMinutes,
    String? bookingTimezone,
    int? clientTimezoneOffsetMinutes,
  }) async {
    try {
      final headers = await _headers();
      final start = slotStartAt.toUtc();
      final end = start.add(Duration(minutes: slotDurationMinutes));
      final effectiveClientTimezoneOffsetMinutes =
          clientTimezoneOffsetMinutes ??
              DateTime.now().timeZoneOffset.inMinutes;

      final response = await http.post(
        Uri.parse(Api.sessionBookSession),
        headers: headers,
        body: json.encode({
          'userId': userId,
          if ((listenerId ?? '').trim().isNotEmpty) 'listenerId': listenerId,
          if ((expertId ?? '').trim().isNotEmpty) 'expertId': expertId,
          'callType': callType,
          'slotStartAt': start.toIso8601String(),
          'slotEndAt': end.toIso8601String(),
          'slotDurationMinutes': slotDurationMinutes,
          if ((bookingTimezone ?? '').trim().isNotEmpty)
            'timezone': bookingTimezone,
          'clientTimezoneOffsetMinutes': effectiveClientTimezoneOffsetMinutes,
          'bookingType': 'subscription_credit',
        }),
      );

      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid booking response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to book session.',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserSessions({
    String? userId,
    String view = 'upcoming',
  }) async {
    try {
      final headers = await _headers();
      final normalizedUserId = (userId ?? '').trim();
      final uri = Uri.parse(Api.sessionGetUserSessions).replace(
        queryParameters: {
          if (normalizedUserId.isNotEmpty) 'userId': normalizedUserId,
          'view': view,
        },
      );
      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid user sessions response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch user sessions.',
      };
    }
  }

  static Future<Map<String, dynamic>> getSessionAccess({
    required String sessionId,
    String? bookingId,
  }) async {
    try {
      final headers = await _headers();

      final body = <String, dynamic>{
        'sessionId': sessionId,
      };

      if ((bookingId ?? '').trim().isNotEmpty) {
        body['bookingId'] = bookingId;
      }

      final response = await http.post(
        Uri.parse(Api.sessionAccessCheck),
        headers: headers,
        body: json.encode(body),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid session access response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to validate session access.',
      };
    }
  }

  static Future<Map<String, dynamic>> reportSessionCallOutcome({
    required String bookingId,
    required String sessionId,
    required String outcome,
  }) async {
    try {
      final headers = await _headers();

      final response = await http.post(
        Uri.parse(Api.sessionReportCallOutcome),
        headers: headers,
        body: json.encode({
          'bookingId': bookingId,
          'sessionId': sessionId,
          'outcome': outcome,
        }),
      );

      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid report session call outcome response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to report session call outcome.',
      };
    }
  }

  static Future<Map<String, dynamic>> cancelSessionBooking({
    String? bookingId,
    String? sessionId,
    String? userId,
    String? cancelReason,
  }) async {
    try {
      if ((bookingId ?? '').trim().isEmpty &&
          (sessionId ?? '').trim().isEmpty) {
        return {
          'status': false,
          'message': 'bookingId or sessionId is required.',
        };
      }

      final headers = await _headers();

      final body = <String, dynamic>{
        if ((bookingId ?? '').trim().isNotEmpty) 'bookingId': bookingId,
        if ((sessionId ?? '').trim().isNotEmpty) 'sessionId': sessionId,
        if ((userId ?? '').trim().isNotEmpty) 'userId': userId,
        if ((cancelReason ?? '').trim().isNotEmpty)
          'cancelReason': cancelReason,
      };

      final response = await http.post(
        Uri.parse(Api.sessionCancelBooking),
        headers: headers,
        body: json.encode(body),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid cancel session response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to cancel session booking.',
      };
    }
  }

  static Future<Map<String, dynamic>> getExpertSessions({
    String? listenerId,
    String? expertId,
    String view = 'upcoming',
  }) async {
    try {
      final headers = await _headers();
      final normalizedListenerId = (listenerId ?? '').trim();
      final normalizedExpertId = (expertId ?? '').trim();
      final uri = Uri.parse(Api.sessionGetExpertSessions).replace(
        queryParameters: {
          if (normalizedListenerId.isNotEmpty)
            'listenerId': normalizedListenerId,
          if (normalizedExpertId.isNotEmpty) 'expertId': normalizedExpertId,
          'view': view,
        },
      );
      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid expert sessions response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch expert sessions.',
      };
    }
  }

  static Future<Map<String, dynamic>> getExpertAvailability({
    String? listenerId,
    String? expertId,
  }) async {
    try {
      final headers = await _headers();
      final normalizedListenerId = (listenerId ?? '').trim();
      final normalizedExpertId = (expertId ?? '').trim();
      final clientTimezoneOffsetMinutes =
          DateTime.now().timeZoneOffset.inMinutes;
      final queryParameters = <String, String>{
        if (normalizedListenerId.isNotEmpty) 'listenerId': normalizedListenerId,
        if (normalizedExpertId.isNotEmpty) 'expertId': normalizedExpertId,
        'clientTimezoneOffsetMinutes': clientTimezoneOffsetMinutes.toString(),
      };

      final uri = Uri.parse(Api.expertGetAvailability).replace(
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid availability response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch availability.',
      };
    }
  }

  static Future<Map<String, dynamic>> setExpertAvailability({
    String? listenerId,
    String? expertId,
    required List<Map<String, dynamic>> slots,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.expertSetAvailability),
        headers: headers,
        body: json.encode({
          if ((listenerId ?? '').trim().isNotEmpty) 'listenerId': listenerId,
          if ((expertId ?? '').trim().isNotEmpty) 'expertId': expertId,
          'clientTimezoneOffsetMinutes':
              DateTime.now().timeZoneOffset.inMinutes,
          'slots': slots,
        }),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid update availability response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to update availability.',
      };
    }
  }
}

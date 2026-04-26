import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/guest_auth.dart';

class SessionBookingService {
  static Future<Map<String, String>> _headers({
    bool allowGuest = false,
  }) async {
    if (allowGuest) {
      return GuestAuth.headers(allowGuest: true);
    }

    final token = await FirebaseAccessToken.onGet();

    return {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: 'Bearer $token',
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: 'application/json',
    };
  }

  static String _normalizeSessionAccessErrorMessage(dynamic message) {
    final rawMessage = (message ?? '').toString().trim();
    final normalized = rawMessage.toLowerCase();

    final isExpertNotJoinedTechnicalError =
        normalized.contains('joinwindowstate') &&
            normalized.contains('before initialization');

    if (isExpertNotJoinedTechnicalError) {
      return 'You can join this session only after the expert has joined.';
    }

    return rawMessage.isEmpty ? 'Session access denied.' : rawMessage;
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

      final headers = await _headers(allowGuest: true);
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

  static Future<Map<String, dynamic>> getGroupSessions({
    String? expertId,
    String? callType,
    String? status,
    bool mine = false,
    bool includePast = false,
    int start = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _headers(allowGuest: true);

      final queryParameters = <String, String>{
        'start': '$start',
        'limit': '$limit',
        'mine': mine ? 'true' : 'false',
        'includePast': includePast ? 'true' : 'false',
      };

      final normalizedExpertId = (expertId ?? '').trim();
      if (normalizedExpertId.isNotEmpty) {
        queryParameters['expertId'] = normalizedExpertId;
      }

      final normalizedCallType = (callType ?? '').trim().toLowerCase();
      if (normalizedCallType == 'audio' || normalizedCallType == 'video') {
        queryParameters['callType'] = normalizedCallType;
      }

      final normalizedStatus = (status ?? '').trim().toLowerCase();
      if (normalizedStatus.isNotEmpty) {
        queryParameters['status'] = normalizedStatus;
      }

      final uri = Uri.parse(Api.groupSessionList).replace(
        queryParameters: queryParameters,
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid group sessions response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch group sessions.',
      };
    }
  }

  static Future<Map<String, dynamic>> createGroupSession({
    required String title,
    required String description,
    required DateTime startAt,
    required int durationMinutes,
    required String callType,
    required int maxParticipants,
  }) async {
    try {
      final headers = await _headers();
      final normalizedDurationMinutes =
          durationMinutes <= 0 ? 30 : durationMinutes;
      final resolvedStartAt = startAt.toUtc();
      final resolvedEndAt =
          resolvedStartAt.add(Duration(minutes: normalizedDurationMinutes));

      final response = await http.post(
        Uri.parse(Api.groupSessionCreate),
        headers: headers,
        body: json.encode({
          'title': title.trim(),
          'description': description.trim(),
          'startAt': resolvedStartAt.toIso8601String(),
          'endAt': resolvedEndAt.toIso8601String(),
          'callType':
              callType.trim().toLowerCase() == 'video' ? 'video' : 'audio',
          'maxParticipants': maxParticipants < 2 ? 2 : maxParticipants,
          'timezone': startAt.timeZoneName,
          'joinDeadline': resolvedStartAt.toIso8601String(),
        }),
      );

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid create group session response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to create group session.',
      };
    }
  }

  static Future<Map<String, dynamic>> joinGroupSession({
    required String sessionId,
    String? userId,
  }) async {
    try {
      final headers = await _headers();

      final body = <String, dynamic>{
        'sessionId': sessionId,
      };

      if ((userId ?? '').trim().isNotEmpty) {
        body['userId'] = userId!.trim();
      }

      final response = await http.post(
        Uri.parse(Api.groupSessionJoin),
        headers: headers,
        body: json.encode(body),
      );

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid join group session response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to join group session.',
      };
    }
  }

  static Future<Map<String, dynamic>> leaveGroupSession({
    required String sessionId,
    String? userId,
  }) async {
    try {
      final headers = await _headers(allowGuest: true);

      final body = <String, dynamic>{
        'sessionId': sessionId,
      };

      if ((userId ?? '').trim().isNotEmpty) {
        body['userId'] = userId!.trim();
      }

      final response = await http.post(
        Uri.parse(Api.groupSessionLeave),
        headers: headers,
        body: json.encode(body),
      );

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid leave group session response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to leave group session.',
      };
    }
  }

  static Future<Map<String, dynamic>> getGroupSessionParticipants({
    required String sessionId,
  }) async {
    try {
      final headers = await _headers();

      final uri = Uri.parse(Api.groupSessionParticipants).replace(
        queryParameters: {
          'sessionId': sessionId,
        },
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid group participants response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch group session participants.',
      };
    }
  }

  static Future<Map<String, dynamic>> cancelGroupSession({
    required String sessionId,
    String? cancelReason,
  }) async {
    try {
      final headers = await _headers();

      final response = await http.post(
        Uri.parse(Api.groupSessionCancel),
        headers: headers,
        body: json.encode({
          'sessionId': sessionId,
          if ((cancelReason ?? '').trim().isNotEmpty)
            'cancelReason': cancelReason!.trim(),
        }),
      );

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid cancel group session response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to cancel group session.',
      };
    }
  }

  static Future<Map<String, dynamic>> markGroupSessionExpertPresence({
    required String sessionId,
    required String action,
  }) async {
    try {
      final headers = await _headers();
      final normalizedAction = action.trim().toLowerCase();

      final response = await http.post(
        Uri.parse(Api.groupSessionExpertPresence),
        headers: headers,
        body: json.encode({
          'sessionId': sessionId,
          'action': normalizedAction,
        }),
      );

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid group expert presence response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to update group expert presence.',
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
        if (decoded['status'] == true) {
          return decoded;
        }

        return {
          ...decoded,
          'message': _normalizeSessionAccessErrorMessage(decoded['message']),
        };
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
      final headers = await _headers(allowGuest: true);
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

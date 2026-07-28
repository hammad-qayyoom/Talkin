import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/guest_auth.dart';

class AiSchedulingService {
  static Future<Map<String, String>> _headers({
    bool allowGuest = false,
  }) async {
    if (allowGuest) {
      return GuestAuth.headers(allowGuest: true);
    }

    final token = (await FirebaseAccessToken.onGet() ?? '').trim();
    final authUid = Database.loginUserFirebaseId.trim().isNotEmpty
        ? Database.loginUserFirebaseId.trim()
        : '';

    final headers = <String, String>{
      ApiParams.key: Api.secretKey,
      ApiParams.contentType: 'application/json',
    };

    if (token.isNotEmpty && authUid.isNotEmpty) {
      headers[ApiParams.authToken] = 'Bearer $token';
      headers[ApiParams.authUid] = authUid;
    }

    return headers;
  }

  static Future<Map<String, dynamic>> getSuggestedSlots({
    String? listenerId,
    String? expertId,
    required String callType,
    String consultationMode = 'online',
  }) async {
    try {
      final normalizedListenerId = (listenerId ?? '').trim();
      final normalizedExpertId = (expertId ?? '').trim();

      if (normalizedListenerId.isEmpty && normalizedExpertId.isEmpty) {
        return {
          'status': false,
          'message': 'listenerId or expertId is required.',
        };
      }

      final headers = await _headers(allowGuest: true);
      final queryParameters = <String, String>{
        if (normalizedListenerId.isNotEmpty)
          'listenerId': normalizedListenerId,
        if (normalizedExpertId.isNotEmpty) 'expertId': normalizedExpertId,
        'callType': callType.toLowerCase(),
        'consultationMode': consultationMode,
      };

      final uri = Uri.parse(Api.smartSchedulingSuggest).replace(
        queryParameters: queryParameters,
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch suggested slots.',
      };
    }
  }

  static Future<Map<String, dynamic>> getAlternativeSlots({
    String? listenerId,
    String? expertId,
    required String callType,
    String consultationMode = 'online',
  }) async {
    try {
      final normalizedListenerId = (listenerId ?? '').trim();
      final normalizedExpertId = (expertId ?? '').trim();

      if (normalizedListenerId.isEmpty && normalizedExpertId.isEmpty) {
        return {
          'status': false,
          'message': 'listenerId or expertId is required.',
        };
      }

      final headers = await _headers(allowGuest: true);
      final queryParameters = <String, String>{
        if (normalizedListenerId.isNotEmpty)
          'listenerId': normalizedListenerId,
        if (normalizedExpertId.isNotEmpty) 'expertId': normalizedExpertId,
        'callType': callType.toLowerCase(),
        'consultationMode': consultationMode,
      };

      final uri = Uri.parse(Api.smartSchedulingAlternatives).replace(
        queryParameters: queryParameters,
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch alternative slots.',
      };
    }
  }

  static Future<Map<String, dynamic>> confirmSmartSchedule({
    required String userId,
    String? listenerId,
    String? expertId,
    required String callType,
    required String slotStartAt,
    required String slotEndAt,
    String consultationMode = 'online',
  }) async {
    try {
      final headers = await _headers();

      final body = <String, dynamic>{
        'userId': userId,
        if ((listenerId ?? '').trim().isNotEmpty) 'listenerId': listenerId,
        if ((expertId ?? '').trim().isNotEmpty) 'expertId': expertId,
        'callType': callType,
        'slotStartAt': slotStartAt,
        'slotEndAt': slotEndAt,
        'consultationMode': consultationMode,
      };

      final response = await http.post(
        Uri.parse(Api.smartSchedulingConfirm),
        headers: headers,
        body: json.encode(body),
      );

      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to confirm appointment.',
      };
    }
  }

  static Future<Map<String, dynamic>> chatWithAssistant({
    String? listenerId,
    String? expertId,
    required String message,
    String callType = 'audio',
    String consultationMode = 'online',
  }) async {
    try {
      final normalizedListenerId = (listenerId ?? '').trim();
      final normalizedExpertId = (expertId ?? '').trim();

      if (normalizedListenerId.isEmpty && normalizedExpertId.isEmpty) {
        return {
          'status': false,
          'message': 'listenerId or expertId is required.',
        };
      }

      final headers = await _headers();

      final body = <String, dynamic>{
        if (normalizedListenerId.isNotEmpty) 'listenerId': normalizedListenerId,
        if (normalizedExpertId.isNotEmpty) 'expertId': normalizedExpertId,
        'message': message,
        'callType': callType,
        'consultationMode': consultationMode,
      };

      final response = await http.post(
        Uri.parse(Api.smartSchedulingChat),
        headers: headers,
        body: json.encode(body),
      );

      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to chat with assistant.',
      };
    }
  }

  static Future<Map<String, dynamic>> toggleExpertSmartScheduling({
    required String expertId,
    required bool enabled,
  }) async {
    try {
      final headers = await _headers();

      final response = await http.post(
        Uri.parse(Api.smartSchedulingExpertToggle),
        headers: headers,
        body: json.encode({
          'expertId': expertId,
          'enabled': enabled,
        }),
      );

      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to toggle AI scheduling.',
      };
    }
  }
}

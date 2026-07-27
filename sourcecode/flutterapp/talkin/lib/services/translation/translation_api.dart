import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/services/translation/translation_models.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/guest_auth.dart';
import 'package:notisboard/utils/utils.dart';

class TranslationApi {
  static Future<TranslationConfigResponse?> fetchConfig() async {
    try {
      final headers = await GuestAuth.headers(allowGuest: true);
      final uri = Uri.parse(Api.translationConfig);
      final response = await http.get(uri, headers: headers);

      Utils.showLog("[TranslationApi] fetchConfig => ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return TranslationConfigResponse.fromJson(body);
      }
    } catch (e) {
      Utils.showLog("[TranslationApi] fetchConfig error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> startSession({
    required String sessionId,
    String? sourceLang,
    String? targetLang,
  }) async {
    try {
      final headers = await GuestAuth.headers();
      final uri = Uri.parse(Api.translationStart);
      final body = json.encode({
        'sessionId': sessionId,
        if (sourceLang != null) 'sourceLang': sourceLang,
        if (targetLang != null) 'targetLang': targetLang,
      });

      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("[TranslationApi] startSession => ${response.statusCode}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      Utils.showLog("[TranslationApi] startSession error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> stopSession({
    required String sessionId,
  }) async {
    try {
      final headers = await GuestAuth.headers();
      final uri = Uri.parse(Api.translationStop);
      final body = json.encode({'sessionId': sessionId});

      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("[TranslationApi] stopSession => ${response.statusCode}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      Utils.showLog("[TranslationApi] stopSession error: $e");
    }
    return null;
  }

  static Future<void> logUsage({
    required String sessionId,
    required int characterCount,
    String? sourceLang,
    String? targetLang,
  }) async {
    try {
      final headers = await GuestAuth.headers();
      final uri = Uri.parse(Api.translationLog);
      final body = json.encode({
        'sessionId': sessionId,
        'characterCount': characterCount,
        if (sourceLang != null) 'sourceLang': sourceLang,
        if (targetLang != null) 'targetLang': targetLang,
      });

      await http.post(uri, headers: headers, body: body);
    } catch (e) {
      Utils.showLog("[TranslationApi] logUsage error: $e");
    }
  }

  static Future<Map<String, dynamic>?> fetchAnonymousConfig({String? categoryId}) async {
    try {
      final headers = await GuestAuth.headers(allowGuest: true);
      var uri = Uri.parse(Api.anonymousConfig);
      if (categoryId != null && categoryId.isNotEmpty) {
        uri = uri.replace(queryParameters: {'categoryId': categoryId});
      }
      final response = await http.get(uri, headers: headers);

      Utils.showLog("[TranslationApi] fetchAnonymousConfig => ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['data'];
      }
    } catch (e) {
      Utils.showLog("[TranslationApi] fetchAnonymousConfig error: $e");
    }
    return null;
  }
}

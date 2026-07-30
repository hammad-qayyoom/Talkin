import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';

class PremiumContentService {
  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet() ?? '';
    return {
      'Content-Type': 'application/json',
      'key': Api.secretKey,
      'x-auth-token': 'Bearer $token',
      'x-auth-uid': Database.loginUserFirebaseId,
    };
  }

  static Future<Map<String, dynamic>> listMyContent({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _headers();
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse(Api.premiumContentList).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getContent(String contentId) async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse('${Api.premiumContentDetail}$contentId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> listExpertContent(
    String expertId, {
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _headers();
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('${Api.premiumContentExpert}$expertId').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> purchaseContent({
    required String contentId,
    required String sessionId,
    String? idempotencyKey,
  }) async {
    try {
      final headers = await _headers();
      final body = <String, dynamic>{
        'contentId': contentId,
        'sessionId': sessionId,
      };
      if (idempotencyKey != null) body['idempotencyKey'] = idempotencyKey;

      final response = await http.post(
        Uri.parse(Api.premiumContentPurchase),
        headers: headers,
        body: json.encode(body),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserPurchaseHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(Api.premiumContentPurchasesHistory).replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      final response = await http.get(uri, headers: headers);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getExpertSalesHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(Api.premiumContentSalesHistory).replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      final response = await http.get(uri, headers: headers);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getExpertSalesStats() async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse(Api.premiumContentSalesStats),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateContent(
    String contentId, {
    String? title,
    String? description,
    String? category,
    int? price,
  }) async {
    try {
      final headers = await _headers();
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (category != null) body['category'] = category;
      if (price != null) body['price'] = price;

      final response = await http.patch(
        Uri.parse('${Api.premiumContentDetail}$contentId'),
        headers: headers,
        body: json.encode(body),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteContent(String contentId) async {
    try {
      final headers = await _headers();
      final response = await http.delete(
        Uri.parse('${Api.premiumContentDetail}$contentId'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }
}

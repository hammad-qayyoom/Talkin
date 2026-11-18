import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';
import 'package:notisboard/utils/utils.dart';

class MarketplaceApi {
  static const String baseUrl = 'https://api.notisboardglobalfoundation.org/api';
  static const String bridgeSecret = 'Eb6ek8wbjlrR3fiK36IXsUw';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-ecosystem-secret': bridgeSecret,
        'key': bridgeSecret,
      };

  /// Fetch active products with filters and pagination
  static Future<List<MarketplaceProduct>> fetchProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    String? sort,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        queryParams['category'] = categoryId;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final uri = Uri.parse('$baseUrl/products/public').replace(
        queryParameters: queryParams,
      );

      Utils.showLog('MarketplaceApi.fetchProducts => $uri');
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final List list = decoded['data'];
          return list
              .map((item) => MarketplaceProduct.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else {
        Utils.showLog('MarketplaceApi.fetchProducts failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      Utils.showLog('MarketplaceApi.fetchProducts error => $e');
    }
    return [];
  }

  /// Fetch product categories
  static Future<List<MarketplaceCategory>> fetchCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/categories');
      Utils.showLog('MarketplaceApi.fetchCategories => $uri');
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final List list = decoded['data'];
          return list
              .map((item) => MarketplaceCategory.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      Utils.showLog('MarketplaceApi.fetchCategories error => $e');
    }
    return [];
  }

  /// Fetch home sections/CMS
  static Future<Map<String, dynamic>?> fetchHomeCMS() async {
    try {
      final uri = Uri.parse('$baseUrl/marketplace/home');
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is Map<String, dynamic>) {
          return decoded['data'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      Utils.showLog('MarketplaceApi.fetchHomeCMS error => $e');
    }
    return null;
  }

  /// Fetch single product detail by slug or ID
  static Future<MarketplaceProduct?> fetchProductDetail(String slugOrId) async {
    try {
      final uri = Uri.parse('$baseUrl/products/public/$slugOrId');
      Utils.showLog('MarketplaceApi.fetchProductDetail => $uri');
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is Map<String, dynamic>) {
          return MarketplaceProduct.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      Utils.showLog('MarketplaceApi.fetchProductDetail error => $e');
    }
    return null;
  }

  /// Create and place order, synchronizing immediately with Foundation Admin Panel
  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('$baseUrl/orders');
      final body = json.encode(payload);
      Utils.showLog('MarketplaceApi.createOrder payload => $body');

      final res = await http.post(
        uri,
        headers: _headers,
        body: body,
      );

      Utils.showLog('MarketplaceApi.createOrder status => ${res.statusCode}');
      Utils.showLog('MarketplaceApi.createOrder response => ${res.body}');

      final decoded = json.decode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {
          'success': true,
          'order': decoded['data'] != null ? MarketplaceOrder.fromJson(decoded['data']) : null,
          'raw': decoded['data'],
        };
      } else {
        return {
          'success': false,
          'error': decoded['error'] ?? decoded['message'] ?? 'Failed to place order (${res.statusCode})',
        };
      }
    } catch (e) {
      Utils.showLog('MarketplaceApi.createOrder error => $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetch past orders for user by email
  static Future<List<MarketplaceOrder>> fetchUserOrders(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/by-email?email=${Uri.encodeComponent(email)}');
      Utils.showLog('MarketplaceApi.fetchUserOrders => $uri');
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final List list = decoded['data'];
          return list
              .map((item) => MarketplaceOrder.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      Utils.showLog('MarketplaceApi.fetchUserOrders error => $e');
    }
    return [];
  }
}


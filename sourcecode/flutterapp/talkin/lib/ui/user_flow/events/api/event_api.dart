import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';
import 'package:notisboard/utils/utils.dart';

class EventApi {
  static const String baseUrl = 'https://api.notisboardglobalfoundation.org/api';
  static const String secretKey = 'Eb6ek8wbjlrR3fiK36IXsUw';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'key': secretKey,
        'x-bridge-secret': secretKey,
      };

  /// Fetch public published events with search and category filters
  static Future<List<FoundationEvent>> fetchEvents({
    int page = 1,
    int limit = 20,
    String? categorySlug,
    String? search,
    String? sort,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
        queryParams['category'] = categorySlug;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final uri = Uri.parse('$baseUrl/events/public').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = <FoundationEvent>[];
          for (final item in (data['data'] as List)) {
            if (item is Map<String, dynamic>) {
              try {
                list.add(FoundationEvent.fromJson(item));
              } catch (e) {
                Utils.showLog('Error parsing event item: $e');
              }
            }
          }
          return list;
        }
      }
    } catch (e) {
      Utils.showLog('EventApi.fetchEvents error: $e');
    }
    return [];
  }

  /// Fetch single event by slug
  static Future<FoundationEvent?> fetchEventDetail(String slug) async {
    try {
      final uri = Uri.parse('$baseUrl/events/public/$slug');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          return FoundationEvent.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      Utils.showLog('EventApi.fetchEventDetail error: $e');
    }
    return null;
  }

  /// Book tickets / Register for an event
  static Future<EventRegistrationRecord?> bookTickets({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/events/$eventId/register');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return EventRegistrationRecord.fromJson(data['data'] as Map<String, dynamic>);
        }
      } else {
        Utils.showLog('EventApi.bookTickets failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Utils.showLog('EventApi.bookTickets error: $e');
    }
    return null;
  }

  /// Fetch user registered tickets by email
  static Future<List<EventRegistrationRecord>> fetchUserTickets(String email) async {
    if (email.trim().isEmpty) return [];
    try {
      final uri = Uri.parse('$baseUrl/events/tickets/by-email?email=${Uri.encodeComponent(email.trim())}');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = <EventRegistrationRecord>[];
          for (final item in (data['data'] as List)) {
            if (item is Map<String, dynamic>) {
              try {
                list.add(EventRegistrationRecord.fromJson(item));
              } catch (_) {}
            }
          }
          return list;
        }
      }
    } catch (e) {
      Utils.showLog('EventApi.fetchUserTickets error: $e');
    }
    return [];
  }
}


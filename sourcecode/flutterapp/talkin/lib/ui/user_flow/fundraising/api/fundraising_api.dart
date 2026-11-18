import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/utils.dart';

class FundraisingApi {
  static const String baseUrl = 'https://api.notisboardglobalfoundation.org/api';
  static const String secretKey = 'Eb6ek8wbjlrR3fiK36IXsUw';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'key': secretKey,
        'x-bridge-secret': secretKey,
      };

  /// Fetch public campaigns with filters
  static Future<List<FundraisingCampaign>> fetchCampaigns({
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

      final uri = Uri.parse('$baseUrl/campaigns/public').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = <FundraisingCampaign>[];
          for (final item in (data['data'] as List)) {
            if (item is Map<String, dynamic>) {
              try {
                list.add(FundraisingCampaign.fromJson(item));
              } catch (e) {
                Utils.showLog('Error parsing campaign item: $e');
              }
            }
          }
          return list;
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchCampaigns error: $e');
    }
    return [];
  }

  /// Fetch campaign categories
  static Future<List<FundraisingCategory>> fetchCampaignCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/campaigns/categories');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = <FundraisingCategory>[];
          for (final item in (data['data'] as List)) {
            if (item is Map<String, dynamic>) {
              try {
                list.add(FundraisingCategory.fromJson(item));
              } catch (e) {
                Utils.showLog('Error parsing category item: $e');
              }
            }
          }
          return list;
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchCampaignCategories error: $e');
    }
    return [];
  }

  /// Fetch single campaign detail by slug
  static Future<FundraisingCampaign?> fetchCampaignDetail(String slug) async {
    try {
      final uri = Uri.parse('$baseUrl/campaigns/public/$slug');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          return FundraisingCampaign.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchCampaignDetail error: $e');
    }
    return null;
  }

  /// Fetch active Foundation programs
  static Future<List<FoundationProgram>> fetchPrograms({int limit = 50}) async {
    try {
      final uri = Uri.parse('$baseUrl/programs/public?limit=$limit');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = <FoundationProgram>[];
          for (final item in (data['data'] as List)) {
            if (item is Map<String, dynamic>) {
              try {
                list.add(FoundationProgram.fromJson(item));
              } catch (e) {
                Utils.showLog('Error parsing program item: $e');
              }
            }
          }
          return list;
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchPrograms error: $e');
    }
    return [];
  }

  /// Fetch single program detail by slug
  static Future<FoundationProgram?> fetchProgramDetail(String slug) async {
    try {
      final uri = Uri.parse('$baseUrl/programs/$slug');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is Map<String, dynamic>) {
          return FoundationProgram.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchProgramDetail error: $e');
    }
    return null;
  }

  /// Fetch hero & page CMS configuration (including spotlight featured mission)
  static Future<FundraisingHeroConfig> fetchFundraisingPageConfig() async {
    try {
      final uri = Uri.parse('$baseUrl/fundraising-page/config');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          FundraisingCampaign? featured;
          if (data['data']['featured']?['isEnabled'] == true &&
              data['data']['featured']?['campaign'] is Map<String, dynamic>) {
            try {
              featured = FundraisingCampaign.fromJson(data['data']['featured']['campaign'] as Map<String, dynamic>);
            } catch (e) {
              Utils.showLog('Error parsing featured campaign in config: $e');
            }
          }
          return FundraisingHeroConfig.fromJson(
            data['data']['hero'] as Map<String, dynamic>?,
            featured,
          );
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchFundraisingPageConfig error: $e');
    }
    return FundraisingHeroConfig();
  }

  /// Fetch public promotions / announcements (e.g. spotlight banner)
  static Future<List<FundraisingPromotionBanner>> fetchPromotions({
    String placement = 'fundraising',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/promotions/public/$placement');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = <FundraisingPromotionBanner>[];
          for (final item in (data['data'] as List)) {
            if (item is Map<String, dynamic>) {
              try {
                list.add(FundraisingPromotionBanner.fromJson(item));
              } catch (_) {}
            }
          }
          return list;
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchPromotions error: $e');
    }
    return [];
  }

  /// Submit a verified donation
  static Future<DonationRecord?> createDonation(Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('$baseUrl/donations');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return DonationRecord.fromJson(data['data'] as Map<String, dynamic>);
        }
      } else {
        Utils.showLog('Create donation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.createDonation error: $e');
    }
    return null;
  }

  /// Fetch all donations by user email
  static Future<List<DonationRecord>> fetchUserDonations(String email) async {
    if (email.trim().isEmpty) return [];
    try {
      final uri = Uri.parse('$baseUrl/donations/by-email?email=${Uri.encodeComponent(email.trim())}');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final list = <DonationRecord>[];
          for (final item in (data['data'] as List)) {
            if (item is Map<String, dynamic>) {
              try {
                list.add(DonationRecord.fromJson(item));
              } catch (_) {}
            }
          }
          return list;
        }
      }
    } catch (e) {
      Utils.showLog('FundraisingApi.fetchUserDonations error: $e');
    }
    return [];
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/food_bank_assistance/model/food_assistance_model.dart';
import 'package:notisboard/utils/utils.dart';

class FoodAssistanceApi {
  static const String baseUrl = 'https://api.notisboardglobalfoundation.org/api';
  static const String bridgeSecret = 'Eb6ek8wbjlrR3fiK36IXsUw';

  /// Fetch all active countries, provinces, cities, zones, pickup depots & platform settings
  static Future<Map<String, dynamic>?> fetchLocations() async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank-ops/locations');
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          final countries = (data['countries'] as List<dynamic>?)
                  ?.map((c) => FoodBankCountry.fromJson(c as Map<String, dynamic>))
                  .toList() ??
              [];
          final settings = data['settings'] != null
              ? FoodBankOperationSettings.fromJson(data['settings'] as Map<String, dynamic>)
              : FoodBankOperationSettings(id: '');
          return {
            'countries': countries,
            'settings': settings,
          };
        }
      }
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.fetchLocations error: $e');
    }
    return null;
  }

  /// Fetch food products for the active city
  static Future<List<FoodBankProduct>> fetchProducts({String? cityId}) async {
    try {
      final query = cityId != null && cityId.isNotEmpty ? '?cityId=$cityId' : '';
      final uri = Uri.parse('$baseUrl/food-bank-ops/products$query');
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return (json['data'] as List<dynamic>)
              .map((p) => FoodBankProduct.fromJson(p as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.fetchProducts error: $e');
    }
    return [];
  }

  /// Upload identity KYC document to media storage
  static Future<String?> uploadDocument(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/media/upload/public');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          return data['url']?.toString();
        }
      }
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.uploadDocument error: $e');
    }
    return null;
  }

  /// Submit a Beneficiary Application (Relief KYC)
  static Future<Map<String, dynamic>> applyBeneficiary({
    required String fullName,
    required String email,
    required String phone,
    required String countryId,
    required String provinceId,
    required String cityId,
    required String zoneId,
    required String streetAddress,
    String? unit,
    required String postalCode,
    required int householdAdults,
    required int householdChildren,
    required int householdSeniors,
    List<String> dietaryRestrictions = const [],
    String idDocumentType = 'GOVERNMENT_PHOTO_ID',
    String? idDocumentUrl,
    String? specialNotes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank-ops/beneficiaries/apply');
      final body = jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'countryId': countryId,
        'provinceId': provinceId,
        'cityId': cityId,
        'zoneId': zoneId,
        'streetAddress': streetAddress.trim(),
        'unit': unit?.trim(),
        'postalCode': postalCode.trim().toUpperCase(),
        'householdAdults': householdAdults,
        'householdChildren': householdChildren,
        'householdSeniors': householdSeniors,
        'dietaryRestrictions': dietaryRestrictions,
        'idDocumentType': idDocumentType,
        'idDocumentUrl': idDocumentUrl ?? 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=400&q=80',
        'termsConsent': true,
        'specialNotes': specialNotes?.trim(),
      });

      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'x-bridge-secret': bridgeSecret,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      final json = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (json['success'] == true) {
          return {'success': true, 'data': json['data']};
        }
      }
      return {'success': false, 'error': json['error'] ?? 'Application submission failed'};
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.applyBeneficiary error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Check beneficiary application status
  static Future<BeneficiaryProfile?> checkBeneficiaryStatus(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank-ops/beneficiaries/status?email=${Uri.encodeComponent(email.trim().toLowerCase())}');
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
        'x-bridge-secret': bridgeSecret,
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return BeneficiaryProfile.fromJson(json['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.checkBeneficiaryStatus error: $e');
    }
    return null;
  }

  /// Submit a Free Food Assistance Order Checkout ($0.00)
  static Future<Map<String, dynamic>> submitCheckout({
    required String cityId,
    required String beneficiaryEmail,
    required String beneficiaryName,
    required String beneficiaryPhone,
    required String deliveryType, // HOME_DELIVERY or PICKUP_POINT
    String? pickupLocationId,
    String? zoneId,
    String? deliveryStreet,
    String? deliveryUnit,
    String? deliveryPostalCode,
    String? deliveryNotes,
    String? specialDietaryNotes,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank-ops/requests/checkout');
      final body = jsonEncode({
        'cityId': cityId,
        'beneficiaryEmail': beneficiaryEmail.trim().toLowerCase(),
        'beneficiaryName': beneficiaryName.trim(),
        'beneficiaryPhone': beneficiaryPhone.trim(),
        'deliveryType': deliveryType,
        'pickupLocationId': pickupLocationId,
        'zoneId': zoneId,
        'deliveryStreet': deliveryStreet?.trim(),
        'deliveryUnit': deliveryUnit?.trim(),
        'deliveryPostalCode': deliveryPostalCode?.trim().toUpperCase(),
        'deliveryNotes': deliveryNotes?.trim(),
        'specialDietaryNotes': specialDietaryNotes?.trim(),
        'items': items,
      });

      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'x-bridge-secret': bridgeSecret,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      final json = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (json['success'] == true) {
          return {'success': true, 'data': json['data']};
        }
      }
      return {'success': false, 'error': json['error'] ?? 'Order checkout failed'};
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.submitCheckout error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetch beneficiary's request history and profile
  static Future<Map<String, dynamic>?> fetchMyRequests(String email) async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank-ops/requests/my-requests?email=${Uri.encodeComponent(email.trim().toLowerCase())}');
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
        'x-bridge-secret': bridgeSecret,
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          BeneficiaryProfile? profile;
          if (data['beneficiary'] != null) {
            profile = BeneficiaryProfile.fromJson(data['beneficiary'] as Map<String, dynamic>);
          }
          final orders = (data['orders'] as List<dynamic>?)
                  ?.map((o) => FoodBankOrderRecord.fromJson(o as Map<String, dynamic>))
                  .toList() ??
              [];
          return {
            'beneficiary': profile,
            'orders': orders,
          };
        }
      }
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.fetchMyRequests error: $e');
    }
    return null;
  }

  /// Cancel request
  static Future<bool> cancelRequest(String orderId, {String? reason}) async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank-ops/requests/$orderId/cancel');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-bridge-secret': bridgeSecret,
        },
        body: jsonEncode({'reason': reason ?? 'Cancelled by recipient'}),
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['success'] == true;
      }
    } catch (e) {
      Utils.showLog('FoodAssistanceApi.cancelRequest error: $e');
    }
    return false;
  }
}

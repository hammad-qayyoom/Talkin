import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/user_flow/food_bank/model/food_bank_model.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class FoodBankApi {
  static const String baseUrl = 'https://api.notisboardglobalfoundation.org/api';
  static const String bridgeSecret = 'Eb6ek8wbjlrR3fiK36IXsUw';

  /// Fetch dynamic food bank configuration & amounts
  static Future<FoodBankConfig?> fetchConfig() async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank/config');
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return FoodBankConfig.fromJson(json['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      Utils.showLog('FoodBankApi.fetchConfig error: $e');
    }
    return null;
  }

  /// Submit a Food Bank donation
  static Future<FoodBankDonationRecord?> submitDonation({
    required String donorName,
    required String donorEmail,
    String? donorPhone,
    required double amount,
    required String currency,
    required String paymentGateway,
    required String paymentTransactionId,
    String? message,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/food-bank/donate');
      final body = jsonEncode({
        'donorName': donorName.trim(),
        'donorEmail': donorEmail.trim(),
        'donorPhone': donorPhone?.trim(),
        'amount': amount,
        'currency': currency,
        'paymentGateway': paymentGateway,
        'paymentTransactionId': paymentTransactionId,
        'status': 'COMPLETED',
        'source': 'MOBILE_APP',
        'message': message?.trim(),
        'metadata': {
          'source': 'NOTISBOARD_MOBILE_APP',
          'userId': Database.fetchLoginUserProfileModel?.user?.id,
          'userPhone': Database.fetchLoginUserProfileModel?.user?.phoneNumber,
        },
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

      Utils.showLog('FoodBankApi.submitDonation status: ${res.statusCode}, body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return FoodBankDonationRecord.fromJson(json['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      Utils.showLog('FoodBankApi.submitDonation error: $e');
    }
    return null;
  }

  /// Retrieve donation history for a donor email
  static Future<List<FoodBankDonationRecord>> fetchUserDonations(String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      if (cleanEmail.isEmpty) return [];

      final uri = Uri.parse('$baseUrl/food-bank/donations/my-history?email=${Uri.encodeComponent(cleanEmail)}');
      final res = await http.get(uri, headers: {
        'Accept': 'application/json',
        'x-bridge-secret': bridgeSecret,
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] is List) {
          return (json['data'] as List)
              .map((d) => FoodBankDonationRecord.fromJson(d as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      Utils.showLog('FoodBankApi.fetchUserDonations error: $e');
    }
    return [];
  }
}

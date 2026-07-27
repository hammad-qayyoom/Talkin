import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/guest_auth.dart';
import 'package:notisboard/utils/utils.dart';

class TippingConfig {
  final bool enabled;
  final bool audioEnabled;
  final bool videoEnabled;
  final int minAmount;
  final int maxAmount;
  final List<int> suggestedAmounts;
  final int platformFeePercent;
  final bool refundPolicyEnabled;
  final int refundTimeLimitMinutes;

  TippingConfig({
    required this.enabled,
    required this.audioEnabled,
    required this.videoEnabled,
    required this.minAmount,
    required this.maxAmount,
    required this.suggestedAmounts,
    required this.platformFeePercent,
    required this.refundPolicyEnabled,
    required this.refundTimeLimitMinutes,
  });

  factory TippingConfig.fromJson(Map<String, dynamic> json) {
    return TippingConfig(
      enabled: json['tippingEnabled'] ?? false,
      audioEnabled: json['tippingAudioEnabled'] ?? true,
      videoEnabled: json['tippingVideoEnabled'] ?? true,
      minAmount: json['tippingMinAmount'] ?? 10,
      maxAmount: json['tippingMaxAmount'] ?? 500,
      suggestedAmounts: List<int>.from(json['tippingSuggestedAmounts'] ?? [10, 20, 50, 100, 200]),
      platformFeePercent: json['tippingPlatformFeePercent'] ?? 20,
      refundPolicyEnabled: json['tippingRefundPolicyEnabled'] ?? true,
      refundTimeLimitMinutes: json['tippingRefundTimeLimitMinutes'] ?? 60,
    );
  }
}

class TipApi {
  static Future<TippingConfig?> fetchConfig() async {
    try {
      Utils.showLog("Tipping Config Api Calling...");

      final headers = await GuestAuth.headers(allowGuest: false);
      final uri = Uri.parse(Api.tippingConfig);

      Utils.showLog("Tipping Config Api url => $uri");

      final response = await http.get(uri, headers: headers);

      Utils.showLog("Tipping Config Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return TippingConfig.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      Utils.showLog("Tipping Config Api Error => ${e.toString()}");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> sendTip({
    required String receiverId,
    required int amount,
    String? callType,
    String paymentMethod = 'wallet',
  }) async {
    try {
      Utils.showLog("Send Tip Api Calling...");

      final headers = await GuestAuth.headers(allowGuest: false);
      final uri = Uri.parse(Api.tippingSend);

      final body = json.encode({
        'receiverId': receiverId,
        'tipAmount': amount,
        'callType': callType ?? 'audio',
        'paymentMethod': paymentMethod,
      });

      Utils.showLog("Send Tip Api url => $uri");
      Utils.showLog("Send Tip Api body => $body");

      final response = await http.post(uri, headers: headers, body: body);

      Utils.showLog("Send Tip Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      }
    } catch (e) {
      Utils.showLog("Send Tip Api Error => ${e.toString()}");
    }
    return null;
  }
}

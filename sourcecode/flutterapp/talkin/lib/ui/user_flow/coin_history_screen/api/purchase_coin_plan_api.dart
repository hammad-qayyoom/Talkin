import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:notisboard/ui/user_flow/coin_history_screen/model/purchase_cpin_plan_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';

class PurchaseCoinGetPlanApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static DateTime? _parseApiDate(String? value) {
    if (value == null || value.trim().isEmpty || value == 'All') {
      return null;
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  static String _formatHistoryDate(DateTime value) {
    return DateFormat('M/d/yyyy, h:mm:ss a').format(value);
  }

  static Future<List<Datum>> _getSubscriptionPurchasesFallback({
    required String token,
    required int page,
    required int limit,
    String? startDate,
    String? endDate,
  }) async {
    final queryParameters = {
      ApiParams.start: page.toString(),
      ApiParams.limit: limit.toString(),
    };

    final query = Uri(queryParameters: queryParameters).query;
    final uri =
        Uri.parse(Api.subscriptionUserList + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: 'Bearer $token',
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: 'application/json',
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) {
        return <Datum>[];
      }

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final rawList = (jsonResponse['data'] as List?) ?? <dynamic>[];

      final fromDate = _parseApiDate(startDate);
      final toDate = _parseApiDate(endDate);
      final inclusiveTo = toDate == null
          ? null
          : DateTime(
              toDate.year,
              toDate.month,
              toDate.day,
              23,
              59,
              59,
              999,
            );

      final list = <Datum>[];

      for (final raw in rawList) {
        if (raw is! Map<String, dynamic>) {
          continue;
        }

        final status = (raw['status'] ?? '').toString().trim().toLowerCase();
        if (status == 'pending' || status == 'failed') {
          continue;
        }

        final createdAtValue = raw['createdAt']?.toString() ?? '';
        DateTime? createdAt;

        if (createdAtValue.isNotEmpty) {
          try {
            createdAt = DateTime.parse(createdAtValue).toLocal();
          } catch (_) {
            createdAt = null;
          }
        }

        if (fromDate != null &&
            createdAt != null &&
            createdAt.isBefore(fromDate)) {
          continue;
        }
        if (inclusiveTo != null &&
            createdAt != null &&
            createdAt.isAfter(inclusiveTo)) {
          continue;
        }

        final planMap = raw['planId'] is Map<String, dynamic>
            ? raw['planId'] as Map<String, dynamic>
            : <String, dynamic>{};

        final dynamic rawCredits =
            planMap['sessionCredits'] ?? raw['remainingSessionCredits'] ?? 0;
        final int credits = rawCredits is num
            ? rawCredits.toInt()
            : int.tryParse(rawCredits.toString()) ?? 0;

        final dynamic rawPrice =
            raw['priceAtPurchase'] ?? planMap['price'] ?? 0;
        final double price = rawPrice is num
            ? rawPrice.toDouble()
            : double.tryParse(rawPrice.toString()) ?? 0;

        list.add(
          Datum(
            id: raw['_id']?.toString(),
            uniqueId:
                raw['gatewaySubscriptionId']?.toString().trim().isNotEmpty ==
                        true
                    ? raw['gatewaySubscriptionId']?.toString()
                    : raw['_id']?.toString(),
            userCoin: credits,
            price: price,
            paymentGateway:
                (raw['paymentGateway']?.toString().trim().isNotEmpty == true)
                    ? raw['paymentGateway']?.toString()
                    : 'Subscription',
            date: createdAt != null ? _formatHistoryDate(createdAt) : '',
            createdAt: createdAt,
          ),
        );
      }

      return list;
    } catch (_) {
      return <Datum>[];
    }
  }

  static Future<GetPurchaseCoinPlanModel?> callApi({
    String? startDate,
    String? endDate,
  }) async {
    final token = await FirebaseAccessToken.onGet() ?? '';

    Utils.showLog("purchase Session Credit history Api Calling...");
    final nextPage = startPagination + 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.startDate: startDate,
      ApiParams.endDate: endDate,
      ApiParams.start: nextPage.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("purchase Session Credit history queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.paymentHistory + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("purchase Session Credit history Api uri :: $uri");
    Utils.showLog("purchase Session Credit history Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('purchase Session Credit history API STATUS CODE :: ${response.statusCode} \n purchase Session Credit history API RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final legacyModel = GetPurchaseCoinPlanModel.fromJson(jsonResponse);

        final merged = <Datum>[...(legacyModel.data ?? <Datum>[])];
        final fallback = await _getSubscriptionPurchasesFallback(
          token: token,
          page: nextPage,
          limit: limitPagination,
          startDate: startDate,
          endDate: endDate,
        );

        if (fallback.isNotEmpty) {
          final existingKeys = merged
              .map((item) =>
                  '${item.id ?? ''}-${item.uniqueId ?? ''}-${item.createdAt?.millisecondsSinceEpoch ?? 0}-${item.price ?? 0}')
              .toSet();

          for (final item in fallback) {
            final key =
                '${item.id ?? ''}-${item.uniqueId ?? ''}-${item.createdAt?.millisecondsSinceEpoch ?? 0}-${item.price ?? 0}';
            if (!existingKeys.contains(key)) {
              merged.add(item);
            }
          }
        }

        merged.sort((a, b) {
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });

        startPagination = nextPage;

        return GetPurchaseCoinPlanModel(
          status: legacyModel.status ?? true,
          message: legacyModel.message,
          data: merged,
        );
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("purchase Session Credit history :: $e");
    }
    return null;
  }
}

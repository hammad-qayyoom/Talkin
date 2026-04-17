import 'dart:developer';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/ui/user_flow/become_host_screen/api/listeners_request_check_api.dart';
import 'package:notisboard/ui/user_flow/become_host_screen/model/listeners_request_check_model.dart';
import 'package:notisboard/ui/user_flow/help_center_screen/api/get_faq_api.dart';
import 'package:notisboard/ui/user_flow/help_center_screen/model/faq_response_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class BecomeHostScreenController extends GetxController {
  static const List<String> _faqCategoryFallbacks = [
    'Expert',
    'Listener',
  ];

  FaqModel? faqModel;
  ListenersRequestCheckModel? listenersRequestCheckModel;
  List<Datum> faqList = [];

  // Kept for request-status screens that also read this controller.
  bool isLoading = false;
  bool isFaqLoading = false;

  SettingApiModel? settingApiModel;
  int expandedIndex = -1;

  @override
  void onInit() {
    super.onInit();
    listenersRequestCheck();
    getFaqData();
    init();
  }

  Future<void> init() async {
    settingApiModel = await SettingApi.callApi();
    Database.settingApiModel = settingApiModel;
  }

  Future<void> getFaqData() async {
    try {
      isFaqLoading = true;
      update([Constant.idFAQListeners]);

      FaqModel? resolvedModel;
      List<Datum> resolvedFaqs = [];

      for (final category in _faqCategoryFallbacks) {
        final data = await GetFaqApi.callApi(category: category);
        if (data == null) {
          continue;
        }

        resolvedModel ??= data;

        final items = data.data ?? const <Datum>[];
        if (items.isNotEmpty) {
          resolvedModel = data;
          resolvedFaqs = items;
          break;
        }
      }

      faqModel = resolvedModel;
      faqList = resolvedFaqs;

      if (expandedIndex >= faqList.length) {
        expandedIndex = -1;
      }
    } catch (e) {
      log('Error fetching FAQ: $e');
      faqList = [];
      expandedIndex = -1;
    } finally {
      isFaqLoading = false;
      update([Constant.idFAQListeners]);
    }
  }

  Future<void> listenersRequestCheck() async {
    try {
      isLoading = true;
      update();
      listenersRequestCheckModel = await ListenersRequestCheckApi.callApi();
    } catch (e) {
      log('Error fetching request status: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Map<String, String> getFormattedDateParts(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return {'date': '', 'time': ''};
    }

    try {
      final parsedDateTime = DateFormat('M/d/yyyy, h:mm:ss a').parse(dateStr);
      final date = DateFormat('MM/dd/yyyy').format(parsedDateTime);
      final time = DateFormat('hh:mm:ss a').format(parsedDateTime);

      return {'date': date, 'time': time};
    } catch (e) {
      log('Error parsing date: $e');
      return {'date': '', 'time': ''};
    }
  }

  void toggleExpanded(int index) {
    if (expandedIndex == index) {
      expandedIndex = -1;
    } else {
      expandedIndex = index;
    }
    update([Constant.idFAQListeners]);
  }

  Future<void> onRefresh() async {
    await Future.wait([
      listenersRequestCheck(),
      getFaqData(),
    ]);
  }

  @override
  void onClose() {
    Utils.onChangeStatusBar(brightness: Brightness.dark);
    super.onClose();
  }
}

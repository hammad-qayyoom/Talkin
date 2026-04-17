import 'dart:developer';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/help_center_screen/api/get_faq_api.dart';
import 'package:notisboard/ui/user_flow/help_center_screen/model/faq_response_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/utils.dart';

class HostHelpCenterScreenController extends GetxController {
  static const List<String> _faqCategoryFallbacks = [
    'Listener',
    'User',
    'Expert',
    'listener',
    'user',
    'expert',
  ];

  FaqModel? faqModel;
  List<Datum> faqList = [];
  int expandedIndex = -1;

  bool isLoading = false;

  @override
  void onInit() {
    getFaqData();
    super.onInit();
  }

  /// get faq
  Future<void> getFaqData() async {
    try {
      isLoading = true;
      update([Constant.idFAQListeners]);

      FaqModel? resolvedModel;
      List<Datum> resolvedFaqs = [];

      for (final category in _faqCategoryFallbacks) {
        final data = await GetFaqApi.callApi(category: category);
        if (data == null) {
          continue;
        }

        resolvedModel = data;
        final items = data.data ?? [];

        if (items.isNotEmpty) {
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
    } finally {
      isLoading = false;
      update([Constant.idFAQListeners]);
    }
  }

  /// toggle expansion
  void toggleExpansion(int index) {
    if (expandedIndex == index) {
      expandedIndex = -1;
    } else {
      expandedIndex = index;
    }
    update([Constant.idFAQListeners]);
  }

  @override
  void onClose() {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    super.onClose();
  }
}

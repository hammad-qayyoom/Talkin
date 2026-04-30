import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/top_listeners_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/expert_proximity_sorter.dart';
import 'package:notisboard/utils/firebse_access_token.dart';

class TopListenersViewAllController extends GetxController {
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool isBackProfile = false;
  String? selectedCategoryId;
  TopListenersModel? topListenersModel;
  List<TopListeners> topListeners = [];
  TextEditingController allListenersSearch = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    log("Enter top all listener controller");
    init();
    getTopListeners();
    super.onInit();
  }

  @override
  void onClose() {
    log("close top all listener controller");
    TopListenersApi.startPagination = 0;
    super.onClose();
  }

  init() async {
    scrollController.addListener(onTopListenersPagination);
    TopListenersApi.startPagination = 0;

    final args = Get.arguments;
    if (args is Map && args['categoryId'] != null) {
      final categoryId = args['categoryId'].toString().trim();
      selectedCategoryId = categoryId.isEmpty ? null : categoryId;
    }

    // await getTopListeners();
  }

  /// get top listeners
  getTopListeners() async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";

    isLoading = true;
    update([Constant.idGetListener]);

    topListenersModel = await TopListenersApi.callApi(
      token: token,
      uid: uid,
      searchString: "All",
      categoryId: selectedCategoryId,
    );
    topListeners.addAll(topListenersModel?.data ?? []);
    await ExpertProximitySorter.sortNearestFirst(topListeners);

    isLoading = false;
    update([Constant.idGetListener]);
  }

  /// pagination
  Future<void> onTopListenersPagination() async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";

    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener, Constant.idGetListener]);

      topListenersModel = await TopListenersApi.callApi(
        token: token,
        uid: uid,
        searchString: "All",
        categoryId: selectedCategoryId,
      );
      topListeners.addAll(topListenersModel?.data ?? []);
      await ExpertProximitySorter.sortNearestFirst(topListeners);

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idGetListener]);
    }
  }

  /// refresh
  onRefresh() async {
    TopListenersApi.startPagination = 0;
    topListeners.clear();

    await getTopListeners();
  }
}

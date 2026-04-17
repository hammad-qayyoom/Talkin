import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/top_listeners_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/api/talk_topic_api.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';

class HomeScreenController extends GetxController {
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool isBackProfile = false;
  TopListenersModel? topListenersModel;
  List<TopListeners> topListeners = [];
  TextEditingController allListenersSearch = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<TalkTopic> homeCategories = [];
  String? selectedCategoryId;
  bool isCategoryLoading = false;
  UserCoinModel? userCoinModel;
  bool isToastVisible = false;
  bool isCoinLoading = false;

  @override
  void onInit() {
    TopListenersApi.startPagination = 0;

    log("Enter home screen controller");
    loadHomeCategories();
    getTopListeners();

    init();
    super.onInit();
  }

  init() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);
    userCoinModel = await UserCoinApi.callApi();
    if (userCoinModel?.status == true) {
      Database.onSetUserCoin((userCoinModel?.coin ?? 0).toString());
    }
    isCoinLoading = false;
    update([Constant.idCoinUpdate]);

    log("Enter In Home screen Controller");
    scrollController.addListener(onTopListenersPagination);

    log("Enter In Home screen startPagination ${TopListenersApi.startPagination} ");
  }

  Future<void> loadHomeCategories() async {
    try {
      isCategoryLoading = true;
      update([Constant.idHomeCategories]);

      final data = await TalkTopicApi.callApi();
      homeCategories = data?.talkTopics ?? [];
    } finally {
      isCategoryLoading = false;
      update([Constant.idHomeCategories]);
    }
  }

  Future<void> selectHomeCategory(String? categoryId) async {
    final normalized = (categoryId ?? '').trim();
    final nextCategoryId = normalized.isEmpty ? null : normalized;

    if (selectedCategoryId == nextCategoryId) {
      return;
    }

    selectedCategoryId = nextCategoryId;
    TopListenersApi.startPagination = 0;
    topListeners.clear();
    update([Constant.idHomeCategories, Constant.idGetListener]);

    await getTopListeners();
  }

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

    isLoading = false;
    update([Constant.idGetListener]);
  }

  Future<void> onTopListenersPagination() async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";

    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      topListenersModel = await TopListenersApi.callApi(
        token: token,
        uid: uid,
        searchString: "All",
        categoryId: selectedCategoryId,
      );
      topListeners.addAll(topListenersModel?.data ?? []);

      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }

  onRefresh() async {
    TopListenersApi.startPagination = 0;
    topListeners.clear();
    await loadHomeCategories();
    userCoinModel = await UserCoinApi.callApi();
    if (userCoinModel?.status == true) {
      Database.onSetUserCoin((userCoinModel?.coin ?? 0).toString());
    }
    update([Constant.idCoinUpdate]);

    await getTopListeners();
  }
}

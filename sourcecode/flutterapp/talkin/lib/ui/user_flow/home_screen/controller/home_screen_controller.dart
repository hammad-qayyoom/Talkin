import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:notisboard/services/location/user_location_service.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/growth_spotlight_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/top_listeners_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_growth_spotlight_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/api/talk_topic_api.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/auth_guard.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/expert_proximity_sorter.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/play_policy_topic_filter.dart';

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
  String? selectedConsultationMode;
  bool isCategoryLoading = false;
  UserCoinModel? userCoinModel;
  bool isToastVisible = false;
  bool isCoinLoading = false;
  bool _didRequestHomeLocation = false;

  GrowthSpotlightModel? userSpotlightModel;
  List<GrowthSpotlightData> userSpotlightItems = [];
  bool isSpotlightLoading = false;
  int currentSpotlightIndex = 0;

  @override
  void onInit() {
    TopListenersApi.startPagination = 0;

    log("Enter home screen controller");
    loadHomeCategories();
    getTopListeners();
    getUserSpotlight();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestHomeLocationAfterFirstFrame();
    });

    init();
    super.onInit();
  }

  Future<void> requestHomeLocationAfterFirstFrame() async {
    if (_didRequestHomeLocation) return;
    _didRequestHomeLocation = true;

    final previousLocation = UserLocationService.cachedLocation;
    final location = await UserLocationService.requestPreciseLocation();
    if (location == null || isClosed) return;

    if (_isSameLocation(previousLocation, location)) return;

    await _reloadExpertsForUpdatedLocation();
  }

  bool _isSameLocation(
    UserLocationData? previousLocation,
    UserLocationData nextLocation,
  ) {
    if (previousLocation == null) return false;

    return (previousLocation.latitude - nextLocation.latitude).abs() <
            0.00001 &&
        (previousLocation.longitude - nextLocation.longitude).abs() < 0.00001;
  }

  Future<void> _reloadExpertsForUpdatedLocation() async {
    for (int index = 0; index < 80 && isLoading && !isClosed; index++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (isClosed || isLoading) return;

    await getTopListeners(reset: true, preserveExistingOnEmpty: true);
  }

  init() async {
    if (!AuthGuard.isGuest) {
      isCoinLoading = true;
      update([Constant.idCoinUpdate]);
      userCoinModel = await UserCoinApi.callApi();
      if (userCoinModel?.status == true) {
        Database.onSetUserCoin((userCoinModel?.coin ?? 0).toString());
      }
      isCoinLoading = false;
      update([Constant.idCoinUpdate]);
    } else {
      Database.onSetUserCoin('0');
    }

    log("Enter In Home screen Controller");
    scrollController.addListener(onTopListenersPagination);

    log("Enter In Home screen startPagination ${TopListenersApi.startPagination} ");
  }

  void onSpotlightPageChanged(int index, dynamic reason) {
    currentSpotlightIndex = index;
    update(['userSpotlight']);
  }

  Future<void> getUserSpotlight() async {
    isSpotlightLoading = true;
    update(['userSpotlight']);

    try {
      userSpotlightModel = await UserGrowthSpotlightApi.callApi();
      userSpotlightItems = userSpotlightModel?.data ?? [];
    } finally {
      isSpotlightLoading = false;
      update(['userSpotlight']);
    }
  }

  Future<void> loadHomeCategories() async {
    try {
      isCategoryLoading = true;
      update([Constant.idHomeCategories]);

      final data = await TalkTopicApi.callApi();
      homeCategories = (data?.talkTopics ?? [])
          .where((topic) => !PlayPolicyTopicFilter.isRestrictedText(
              '${topic.name ?? ''} ${topic.icon ?? ''}'))
          .toList();
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

  Future<void> selectConsultationMode(String? mode) async {
    final normalized = (mode ?? '').trim();
    final nextMode = normalized.isEmpty ? null : normalized;

    if (selectedConsultationMode == nextMode) {
      return;
    }

    selectedConsultationMode = nextMode;
    TopListenersApi.startPagination = 0;
    topListeners.clear();
    update([Constant.idGetListener]);

    await getTopListeners();
  }

  Future<void> getTopListeners({
    bool reset = false,
    bool preserveExistingOnEmpty = false,
  }) async {
    final uid = Database.loginUserFirebaseId;
    final token = await FirebaseAccessToken.onGet() ?? "";
    final previousListeners = List<TopListeners>.from(topListeners);

    if (reset) {
      TopListenersApi.startPagination = 0;
    }

    isLoading = true;
    update([Constant.idGetListener]);

    try {
      topListenersModel = await TopListenersApi.callApi(
        token: token,
        uid: uid,
        searchString: "All",
        categoryId: selectedCategoryId,
        consultationMode: selectedConsultationMode,
      );

      final nextListeners = topListenersModel?.data ?? [];
      if (reset) {
        topListeners.clear();
        if (nextListeners.isNotEmpty ||
            !preserveExistingOnEmpty ||
            previousListeners.isEmpty) {
          topListeners.addAll(nextListeners);
        } else {
          topListeners.addAll(previousListeners);
        }
      } else {
        topListeners.addAll(nextListeners);
      }

      await ExpertProximitySorter.sortNearestFirst(topListeners);
    } finally {
      isLoading = false;
      update([Constant.idGetListener]);
    }
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
        consultationMode: selectedConsultationMode,
      );
      topListeners.addAll(topListenersModel?.data ?? []);
      await ExpertProximitySorter.sortNearestFirst(topListeners);

      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }

  onRefresh() async {
    TopListenersApi.startPagination = 0;
    topListeners.clear();
    await loadHomeCategories();
    if (!AuthGuard.isGuest) {
      userCoinModel = await UserCoinApi.callApi();
      if (userCoinModel?.status == true) {
        Database.onSetUserCoin((userCoinModel?.coin ?? 0).toString());
      }
    } else {
      Database.onSetUserCoin('0');
    }
    update([Constant.idCoinUpdate]);

    await getTopListeners();
    await getUserSpotlight();
  }
}

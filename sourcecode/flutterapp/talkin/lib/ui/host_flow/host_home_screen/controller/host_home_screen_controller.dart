import 'dart:developer';

import 'package:carousel_slider/carousel_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/growth_spotlight_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/update_expert_call_status_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/growth_spotlight_model.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/update_expert_call_status_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart' show EnumLocale;
import 'package:notisboard/utils/utils.dart';

class HostHomeScreenController extends GetxController {
  // bool isChatPermission = Database.fetchListenerProfileModel?.data?.isAvailableForChat ?? false;
  bool isAvailableForPrivateAudioCall = Database
          .fetchListenerProfileModel?.data?.isAvailableForPrivateAudioCall ??
      false;
  bool isAvailableForPrivateVideoCall = Database
          .fetchListenerProfileModel?.data?.isAvailableForPrivateVideoCall ??
      false;
  bool isToastVisible = false;
  UpdateExpertCallStatusModel? updateExpertCallStatusModel;
  bool isCoinLoading = false;
  bool isSpotlightLoading = false;
  int currentIndex = 0;
  int totalCompletedSessions = 0;
  FetchListenerProfileModel? fetchListenerProfileModel;
  ListenerCoinModel? listenerCoinModel;
  GrowthSpotlightModel? growthSpotlightModel;

  List<GrowthSpotlightData> get spotlightItems =>
      growthSpotlightModel?.data ?? const <GrowthSpotlightData>[];

  String get _listenerId {
    final fromLogin =
        (Database.fetchLoginUserProfileModel?.user?.listenerId ?? '')
            .toString()
            .trim();
    if (fromLogin.isNotEmpty) {
      return fromLogin;
    }

    final fromListenerProfile =
        (Database.fetchListenerProfileModel?.data?.id ?? '').toString().trim();
    if (fromListenerProfile.isNotEmpty) {
      return fromListenerProfile;
    }

    return Database.loginListenerId.trim();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    await fetchRealStats();
    await hostCoin();
    await fetchGrowthSpotlights();
  }

  fetchRealStats() async {
    final listenerId = _listenerId;

    try {
      if (listenerId.isNotEmpty) {
        fetchListenerProfileModel =
            await FetchListenerProfileAPi.callApi(loginListenerId: listenerId);
        if (fetchListenerProfileModel != null) {
          Database.fetchListenerProfileModel = fetchListenerProfileModel;
          isAvailableForPrivateAudioCall =
              fetchListenerProfileModel?.data?.isAvailableForPrivateAudioCall ??
                  isAvailableForPrivateAudioCall;
          isAvailableForPrivateVideoCall =
              fetchListenerProfileModel?.data?.isAvailableForPrivateVideoCall ??
                  isAvailableForPrivateVideoCall;
        }
      }

      final response = await SessionBookingService.getExpertSessions(
        listenerId: listenerId.isEmpty ? null : listenerId,
        view: 'completed',
      );

      if (response['status'] == true) {
        final sessions = response['data'] as List<dynamic>? ?? [];
        totalCompletedSessions = sessions.length;
      } else {
        totalCompletedSessions = 0;
      }
    } catch (e) {
      log('Error fetching stats: $e');
      totalCompletedSessions = 0;
    }

    update();
    update([Constant.idCoinUpdate]);
  }

  init() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);
    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
    isCoinLoading = false;
    update([Constant.idCoinUpdate]);
    log("Listener Session Credit => ${listenerCoinModel?.coin}");
  }

  /// refresh
  onRefresh() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);

    await fetchRealStats();
    await fetchGrowthSpotlights();

    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
    isCoinLoading = false;

    update([Constant.idCoinUpdate]);
    log("Listener Session Credit => ${listenerCoinModel?.coin}");

    update();
  }

  /// get host coin
  hostCoin() async {
    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());

    update([Constant.idGetCoinPlan]);
  }

  Future<void> fetchGrowthSpotlights() async {
    isSpotlightLoading = true;
    update();

    try {
      growthSpotlightModel = await GrowthSpotlightApi.callApi();

      final items = spotlightItems;
      if (items.isEmpty) {
        currentIndex = 0;
      } else if (currentIndex >= items.length) {
        currentIndex = 0;
      }
    } catch (e) {
      log("Error fetching growth spotlights: $e");
      growthSpotlightModel = GrowthSpotlightModel(
        status: false,
        message: "Failed to fetch growth spotlights",
        data: const [],
      );
      currentIndex = 0;
    }

    isSpotlightLoading = false;
    update();
  }

  /// availability switch permission
  void permissionSwitch(bool currentValue, String status) async {
    log("status=============================$status");

    // Instant UI update
    if (status == "isAvailableForPrivateVideoCall") {
      isAvailableForPrivateVideoCall = currentValue;
    } else if (status == "isAvailableForPrivateAudioCall") {
      isAvailableForPrivateAudioCall = currentValue;
    }

    log("isPermission = currentValue=============================$isAvailableForPrivateAudioCall");
    update();

    /// API call to update permission
    final response = await UpdateExpertCallStatusApi.callApi(
      status: status.toString(),
      expertId: _listenerId,
    );
    updateExpertCallStatusModel = response;

    if (response != null && response.status == true) {
      // Success, keep toggled value
      if (status == "isAvailableForPrivateVideoCall") {
        isAvailableForPrivateVideoCall = currentValue;
        if (currentValue == true) {
          Utils.showToast(Get.context!,
              EnumLocale.txtListenerAvailableForPrivateVideoCall.name.tr,
              toastLength: Toast.LENGTH_SHORT);
        } else {
          Utils.showToast(Get.context!,
              EnumLocale.txtListenerDisableForPrivateVideoCall.name.tr,
              toastLength: Toast.LENGTH_SHORT);
        }
      } else if (status == "isAvailableForPrivateAudioCall") {
        isAvailableForPrivateAudioCall = currentValue;

        if (currentValue == true) {
          Utils.showToast(Get.context!,
              EnumLocale.txtListenerAvailableForPrivateAudioCall.name.tr,
              toastLength: Toast.LENGTH_SHORT);
        } else {
          Utils.showToast(Get.context!,
              EnumLocale.txtListenerDisableForPrivateAudioCall.name.tr,
              toastLength: Toast.LENGTH_SHORT);
        }
      }
    } else {
      // Failure, revert to previous value
      // isPermission = !currentValue;
      if (status == "isAvailableForPrivateVideoCall") {
        isAvailableForPrivateVideoCall = !currentValue;
      } else if (status == "isAvailableForPrivateAudioCall") {
        isAvailableForPrivateAudioCall = !currentValue;
      }
    }
    fetchListenerProfileModel =
        await FetchListenerProfileAPi.callApi(loginListenerId: _listenerId);
    Database.fetchListenerProfileModel = fetchListenerProfileModel;
    if (fetchListenerProfileModel?.status == false) {
      Utils.showLog(fetchListenerProfileModel?.message ?? "");
    }
    fetchListenerProfileModel?.data?.isAvailableForPrivateVideoCall =
        isAvailableForPrivateVideoCall;
    fetchListenerProfileModel?.data?.isAvailableForPrivateAudioCall =
        isAvailableForPrivateAudioCall;

    update();
  }

  /// slider change
  void onPageChanged(int index, CarouselPageChangedReason reason) {
    if (spotlightItems.isEmpty) {
      currentIndex = 0;
      update();
      return;
    }

    currentIndex = index;
    update();
  }
}

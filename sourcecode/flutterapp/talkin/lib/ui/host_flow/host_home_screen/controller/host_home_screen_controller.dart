import 'dart:developer';

import 'package:carousel_slider/carousel_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/update_expert_call_status_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/update_expert_call_status_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:notisboard/utils/app_asset.dart';
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
  final List<String> imageList = [
    AppAsset.homeCallPerson,
    AppAsset.homeCallPerson,
    AppAsset.homeCallPerson,
  ];
  bool isCoinLoading = false;
  int currentIndex = 0;
  int totalCompletedSessions = 0;
  FetchListenerProfileModel? fetchListenerProfileModel;
  ListenerCoinModel? listenerCoinModel;

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
    hostCoin();
    fetchRealStats();
    // init();
    super.onInit();
  }

  fetchRealStats() async {
    try {
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
          loginListenerId:
              Database.fetchLoginUserProfileModel?.user?.listenerId ?? '');
      Database.fetchListenerProfileModel = fetchListenerProfileModel;

      final response = await SessionBookingService.getExpertSessions(
        listenerId: _listenerId.isEmpty ? null : _listenerId,
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

    update([Constant.idCoinUpdate]);
  }

  init() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);
    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
    isCoinLoading = false;
    update([Constant.idCoinUpdate]);
    log("Listener Session Credit => ${listenerCoinModel?.coin}");
  }

  /// refresh
  onRefresh() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);

    await fetchRealStats();

    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
    isCoinLoading = false;

    update([Constant.idCoinUpdate]);
    log("Listener Session Credit => ${listenerCoinModel?.coin}");

    update();
  }

  /// get host coin
  hostCoin() async {
    listenerCoinModel = await HostCoinApi.callApi();
    Database.onSetListenerCoin(listenerCoinModel!.coin.toString());

    update([Constant.idGetCoinPlan]);
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
      expertId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
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
    fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId:
            Database.fetchLoginUserProfileModel?.user?.listenerId ?? '');
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
    currentIndex = index;
    update();
  }
}

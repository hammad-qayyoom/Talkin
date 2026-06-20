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
import 'package:flutter/material.dart';
import 'package:notisboard/ui/host_flow/host_listeners_detail_screen/api/host_listener_profile_update_api.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/app_asset.dart';

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
  bool isSpotlightLoading = true;
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

    final fromLoginListener = Database.loginListenerId.trim();
    if (fromLoginListener.isNotEmpty) {
      return fromLoginListener;
    }

    return Database.loginUserId.trim();
  }

  @override
  void onInit() {
    super.onInit();
    isSpotlightLoading = true;
    _initializeHome();
  }

  Future<void> _initializeHome() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);

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
    if (listenerCoinModel?.status == true) {
      Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
    }
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
    if (listenerCoinModel?.status == true) {
      Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
    }
    isCoinLoading = false;

    update([Constant.idCoinUpdate]);
    log("Listener Session Credit => ${listenerCoinModel?.coin}");

    update();
  }

  /// get host coin
  hostCoin() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);

    listenerCoinModel = await HostCoinApi.callApi();
    if (listenerCoinModel?.status == true) {
      Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
    }

    isCoinLoading = false;
    update([Constant.idCoinUpdate]);
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

  void showEditPriceDialog(String type) {
    final TextEditingController priceController = TextEditingController();
    String title = type == 'audio' ? 'Edit Audio Call Price' : 'Edit Video Call Price';
    String currentValue = type == 'audio'
        ? (Database.fetchListenerProfileModel?.data?.ratePrivateAudioCall?.toString() ?? '0')
        : (Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall?.toString() ?? '0');
    
    // Compute listenerId once — try all sources
    final String expertId = _listenerId;
    Utils.showLog("showEditPriceDialog: expertId = $expertId");
    
    priceController.text = currentValue;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        child: SingleChildScrollView(
          child: Container(
            width: 330,
            padding: const EdgeInsets.all(20),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AppAsset.starCoin,
                  height: 60,
                  width: 60,
                ),
                15.height,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW700(
                      fontColor: AppColors.black, fontSize: 22),
                ),
                8.height,
                Text(
                  'Set your required session credits\nfor this call type.',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW500(
                      fontColor: AppColors.grey, fontSize: 14),
                ).paddingOnly(left: 7, right: 7),
                20.height,
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW700(
                        fontColor: AppColors.black, fontSize: 20),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "0",
                    ),
                  ),
                ),
                25.height,
                GestureDetector(
                  onTap: () async {
                    final newPrice = int.tryParse(priceController.text.trim()) ?? 0;
                    
                    final minAudio = Database.settingApiModel?.data?.audioCallRatePrivate ?? 0;
                    final maxAudio = Database.settingApiModel?.data?.maxAudioCallRatePrivate ?? 0;
                    final minVideo = Database.settingApiModel?.data?.videoCallRatePrivate ?? 0;
                    final maxVideo = Database.settingApiModel?.data?.maxVideoCallRatePrivate ?? 0;
                    
                    if (type == 'audio') {
                      if (newPrice < minAudio) {
                        Utils.showToast(Get.context!, 'Price cannot be less than $minAudio credits.');
                        return;
                      }
                      if (maxAudio > 0 && newPrice > maxAudio) {
                        Utils.showToast(Get.context!, 'Price cannot exceed $maxAudio credits.');
                        return;
                      }
                    } else {
                      if (newPrice < minVideo) {
                        Utils.showToast(Get.context!, 'Price cannot be less than $minVideo credits.');
                        return;
                      }
                      if (maxVideo > 0 && newPrice > maxVideo) {
                        Utils.showToast(Get.context!, 'Price cannot exceed $maxVideo credits.');
                        return;
                      }
                    }

                    Get.back();
                    Utils.showToast(Get.context!, 'Updating price...');
                    
                    final data = Database.fetchListenerProfileModel?.data;
                    Utils.showLog("DEBUG: using expertId = $expertId, data?.id = ${data?.id}");

                    final response = await HostListenerProfileUpdateApi.callApi(
                      listenerId: expertId.isNotEmpty ? expertId : null,
                      name: '',
                      nickName: '',
                      image: null, 
                      selfIntro: '',
                      language: '',
                      talkTopics: '',
                      categoryIds: '',
                      ratePrivateAudioCall: type == 'audio' ? newPrice.toString() : '',
                      ratePrivateVideoCall: type == 'video' ? newPrice.toString() : '',
                    );
                  
                    if (response?.status == true) {
                      if (type == 'audio') {
                        Database.fetchListenerProfileModel?.data?.ratePrivateAudioCall = newPrice;
                      } else {
                        Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall = newPrice;
                      }
                      update();
                      Utils.showToast(Get.context!, 'Price updated successfully!');
                    } else {
                      Utils.showToast(Get.context!, response?.message ?? 'Failed to update price.');
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 45,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.appColor,
                    ),
                    child: Text(
                      "Save",
                      style: AppFontStyle.fontStyleW600(
                          fontColor: AppColors.white, fontSize: 16),
                    ),
                  ),
                ),
                10.height,
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    alignment: Alignment.center,
                    height: 45,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightGrey,
                    ),
                    child: Text(
                      EnumLocale.txtCancel.name.tr,
                      style: AppFontStyle.fontStyleW600(
                          fontColor: AppColors.appColor, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

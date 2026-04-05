import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:talk_in/socket/socket_listen.dart';
import 'package:talk_in/socket/socket_service.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/view/host_calling_screen.dart';
import 'package:talk_in/ui/host_flow/host_chat_screen/view/host_chat_screen.dart';
import 'package:talk_in/ui/host_flow/expert_sessions_screen/view/expert_sessions_screen.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/view/host_home_screen.dart';
import 'package:talk_in/ui/host_flow/host_profile_screen/view/host_profile_screen_view.dart';
import 'package:talk_in/ui/host_flow/host_wallet_screen/view/host_wallet_screen.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class HostBottomBarController extends GetxController {
  bool checkScreen = false;
  int selectIndex = 0;
  SettingApiModel? settingApiModel;

  @override
  void onInit() {
    // SocketManager.initSocketManager();
    init();
    super.onInit();
  }

  init() async {
    log("Enter Listener bottomBar Controller");
    await SocketService.socketDisConnect();
    await SocketService.socketConnect().then((_) {
      Utils.showLog(" Socket connect Listener");
      SocketListen.registerListeners();
    });
    settingApiModel = await SettingApi.callApi();
    Database.settingApiModel = settingApiModel;
    await createEngine();
  }

  final pages = [
    const HostHomeScreen(),
    HostCallingScreen(),
    HostChatScreen(),
    HostWalletScreen(),
    const ExpertSessionsScreen(),
    HostProfileScreen(),
    // ChatScreen(),
    // CallingScreen(),
    // const AppointmentScreen(),
    // const ChatScreen(),
    // const FavoriteAgencyScreen(),
    // const ProfileScreen(),
  ];
  Future<void> createEngine() async {
    final appId = int.tryParse(
        Database.settingApiModel?.data?.zegoAppId?.toString() ?? '');
    final appSign =
        Database.settingApiModel?.data?.zegoAppSignIn?.toString() ?? '';

    if (appId == null || appId <= 0 || appSign.isEmpty) {
      Utils.showLog("Zego engine skipped: invalid app settings for host.");
      return;
    }

    try {
      await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
        appId,
        ZegoScenario.Default,
        appSign: kIsWeb ? null : appSign,
      ));
    } catch (e) {
      Utils.showLog("Zego engine create (host) skipped/failed: $e");
    }
  }

  onClick(value) async {
    if (value != null) {
      selectIndex = value;
      update([Constant.idBottomBar]);
    }
  }
}

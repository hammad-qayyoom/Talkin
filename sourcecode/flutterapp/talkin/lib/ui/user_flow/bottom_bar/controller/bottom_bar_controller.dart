import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:notisboard/socket/socket_listen.dart';
import 'package:notisboard/socket/socket_service.dart';
import 'package:notisboard/ui/user_flow/chat_screen/view/chat_screen.dart';
import 'package:notisboard/ui/user_flow/feed_screen/view/feed_screen.dart';
import 'package:notisboard/ui/user_flow/home_screen/view/home_screen.dart';
import 'package:notisboard/ui/user_flow/listener_screen/view/listeners_screen.dart';
import 'package:notisboard/ui/user_flow/my_sessions_screen/view/my_sessions_screen.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:notisboard/utils/auth_guard.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class BottomBarController extends GetxController {
  bool checkScreen = false;
  int selectIndex = 0;
  SettingApiModel? settingApiModel;

  @override
  void onInit() {
    // SocketManager.initSocketManager();
    init();
    // SocketService.socketConnect().then((_) {
    //   Utils.showLog(" Socket connect User");
    //   SocketListen.registerListeners();
    // });

    super.onInit();
  }

  init() async {
    log("Enter user bottomBar Controller");
    if (!AuthGuard.isGuest) {
      await SocketService.socketDisConnect();
      await SocketService.socketConnect().then((_) {
        Utils.showLog(" Socket connect User");
        SocketListen.registerListeners();
      });
    }

    settingApiModel = await SettingApi.callApi();
    Database.settingApiModel = settingApiModel;
    if (!AuthGuard.isGuest) {
      createEngine();
    }
  }

  Future<void> createEngine() async {
    final appId = int.tryParse(
        Database.settingApiModel?.data?.zegoAppId?.toString() ?? '');
    final appSign =
        Database.settingApiModel?.data?.zegoAppSignIn?.toString() ?? '';

    if (appId == null || appId <= 0 || appSign.isEmpty) {
      Utils.showLog("Zego engine skipped: invalid app settings for user.");
      return;
    }

    try {
      await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
        appId,
        ZegoScenario.Default,
        appSign: kIsWeb ? null : appSign,
      ));
    } catch (e) {
      Utils.showLog("Zego engine create (user) skipped/failed: $e");
    }
  }

  final pages = [
    HomeScreen(),
    FeedScreen(controllerTag: 'bottomFeed'),
    ListenersScreen(),
    ChatScreen(),
    UserMySessionsScreen(),
  ];

  onClick(value) async {
    if (value != null) {
      if (AuthGuard.isGuest && (value == 3 || value == 4)) {
        AuthGuard.showLoginPrompt(
          message:
              'Chats and your sessions need an account. You can keep browsing experts without logging in.',
        );
        return;
      }

      selectIndex = value;
      update([Constant.idBottomBar]);
    }
  }
}

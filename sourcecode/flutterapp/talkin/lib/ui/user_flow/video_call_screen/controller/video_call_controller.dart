import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class VideoCallController extends GetxController {
  List<CoinPlan> coinPlan = [];

  late Map<String, dynamic> args;

  bool cameraTurn = true;

  bool micMute = false;
  bool isCameraOff = false;

  bool remoteVideoOff = false;
  bool remoteMicMute = false;

  String? callId;
  String? callerImage;
  String? callerName;
  String? receiverName;
  String? receiverImage;
  String? designation;
  String? callerId;
  String? receiverId;
  String? callType;
  String? callMode;
  String? callerRole;
  String? receiverRole;

  int countTime = 0;

  Timer? timer;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;
  int? minutes;
  int? seconds;
  String? finalDuration;
  String? formattedTime = "00:00";

  Widget? localView;
  Widget? remoteView;
  int? remoteViewID;
  int? localViewID;
  String? publishedStreamId;
  String? playingStreamId;

  @override
  void onInit() async {
    super.onInit();
    args = Get.arguments as Map<String, dynamic>;
    getDataFromArgs();

    final hasPermissions = await permissionManager();
    if (!hasPermissions) {
      Utils.showLog("Video call start blocked: required permissions denied.");
      return;
    }

    await createEngine();

    ZegoExpressEngine.instance.muteMicrophone(micMute);
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
    ZegoExpressEngine.instance.enableCamera(true);

    startListenEvent();

    final loginRoomResult = await loginRoom();
    if (loginRoomResult.errorCode == 0) {
      WakelockPlus.enable();
      startTimer();
    } else {
      Utils.showLog("Video call login failed: ${loginRoomResult.errorCode}");
    }
  }

  Future<bool> permissionManager() async {
    var micGranted = false;
    var cameraGranted = false;

    await PermissionHandler.onGetMicrophonePermission(
      onGranted: () {
        micGranted = true;
        Utils.showLog("Well Done Microphone Permission ");
      },
      onDenied: () {
        micGranted = false;
        Get.back();
      },
    );

    await PermissionHandler.onGetCameraPermission(
      onGranted: () {
        cameraGranted = true;
        Utils.showLog("Well Done Camera Permission ");
      },
      onDenied: () {
        cameraGranted = false;
        Get.back();
      },
    );

    return micGranted && cameraGranted;
  }

  @override
  void onClose() {
    log("video call controller close");
    stopListenEvent();

    logoutRoom();
    WakelockPlus.disable();

    stopTimer();
    super.onClose();
  }

  getDataFromArgs() {
    if (Get.arguments != null) {
      callId = Get.arguments["callId"] ?? "";
      callerId = Get.arguments["callerId"] ?? "";
      receiverId = Get.arguments["receiverId"] ?? "";
      receiverName = Get.arguments["receiverName"] ?? "";
      receiverImage = Get.arguments["receiverImage"] ?? "";
      callerName = Get.arguments["callerfullName"] ??
          Get.arguments["callerName"] ??
          Get.arguments["callernickName"] ??
          "";
      callerImage = Get.arguments["callerImage"] ?? "";
      callType = Get.arguments["callType"] ?? "";
      callMode = Get.arguments["callMode"] ?? "";
      callerRole = Get.arguments["callerRole"] ?? "";
      receiverRole = Get.arguments["receiverRole"] ?? "";
    }

    log("callId ::$callId");
    log("callerId ::$callerId");
    log("receiverId ::$receiverId");
    log("receiverName ::$receiverName");
    log("receiverImage ::$receiverImage");
    log("callerName ::$callerName");
    log("callerImage ::$callerImage");
    log("callType ::$callType");
    log("callType ::$callMode");
    log("callerRole ::$callerRole");
    log("receiverRole ::$receiverRole");
    log("callMode ::$callMode");
  }

  String _currentZegoUserId() {
    final listenerId =
        Database.fetchLoginUserProfileModel?.user?.listenerId?.toString();
    if (Database.fetchLoginUserProfileModel?.user?.isListener == true &&
        (listenerId?.trim().isNotEmpty ?? false)) {
      return listenerId!;
    }
    return Database.loginUserId;
  }

  String _safeZegoId(String value, {int maxLength = 63}) {
    final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    if (sanitized.isEmpty) return 'call_id';
    return sanitized.length > maxLength
        ? sanitized.substring(0, maxLength)
        : sanitized;
  }

  String _resolvedRoomId() {
    final rawCallId = (callId ?? '').trim();
    if (rawCallId.isNotEmpty) {
      return _safeZegoId(rawCallId, maxLength: 63);
    }

    final cId = _safeZegoId((callerId ?? '').trim(), maxLength: 24);
    final rId = _safeZegoId((receiverId ?? '').trim(), maxLength: 24);
    final pair = [cId, rId]..sort();
    return _safeZegoId('room_${pair[0]}_${pair[1]}', maxLength: 63);
  }

  String _resolvedStreamId() {
    final roomId = _resolvedRoomId();
    final userId = _safeZegoId(_currentZegoUserId(), maxLength: 24);
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    return _safeZegoId('${roomId}_${userId}_$stamp', maxLength: 120);
  }

  String _zegoUserName() {
    final name = Database.loginUserName.trim();
    if (name.isNotEmpty) return name;
    return _safeZegoId(_currentZegoUserId(), maxLength: 32);
  }

  Future<void> startTimer() async {
    Utils.showLog('Video call screen start timer >>>>>>>>>>>>>>>>>>');
    startTime = DateTime.now();
    int elapsedSeconds = 0;

    update();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      elapsedSeconds++;

      final minutes = elapsedSeconds ~/ 60;
      final seconds = elapsedSeconds % 60;

      formattedTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      log('Start timer :: $formattedTime');

      update([Constant.idVideoCall]);
    });
  }

  void stopTimer() {
    endTime = DateTime.now();
    timer?.cancel();
    timer = null;

    duration = endTime?.difference(startTime!);
    minutes = duration?.inMinutes.remainder(60);
    seconds = duration?.inSeconds.remainder(60);
    finalDuration =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    log('Call Duration :: $duration');
    log('Final Duration :: $finalDuration');
  }

  onMicMute() {
    micMute = !micMute;
    ZegoExpressEngine.instance.muteMicrophone(micMute);

    update([Constant.idMicMute, Constant.idVideoCall]);
  }

  onCameraOff() {
    Utils.showLog("***before******* $isCameraOff");

    if (isCameraOff) {
      ZegoExpressEngine.instance.enableCamera(true);
      isCameraOff = false;
    } else {
      ZegoExpressEngine.instance.enableCamera(false);
      isCameraOff = true;
    }

    Utils.showLog("****after****** $isCameraOff");

    update([Constant.idVideoTurn, Constant.idVideoCall]);
  }

  onCameraTurn() {
    cameraTurn = !cameraTurn;

    ZegoExpressEngine.instance.useFrontCamera(cameraTurn);
    update([Constant.idCameraTurn, Constant.idVideoCall]);
    // update();
  }

  Future<void> createEngine() async {
    final appId = int.tryParse(
        Database.settingApiModel?.data?.zegoAppId?.toString() ?? '');
    final appSign =
        Database.settingApiModel?.data?.zegoAppSignIn?.toString() ?? '';

    if (appId == null || appId <= 0 || appSign.isEmpty) {
      Utils.showLog("Zego engine skipped: invalid app settings in video call.");
      return;
    }

    try {
      await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
        appId,
        ZegoScenario.Default,
        appSign: kIsWeb ? null : appSign,
      ));
    } catch (e) {
      Utils.showLog("Zego engine create (video call) skipped/failed: $e");
    }
  }

  void startListenEvent() {
    Constant.storage.write("isVideoCall", true);

    ZegoExpressEngine.onRoomUserUpdate =
        (roomID, updateType, List<ZegoUser> userList) {
      Utils.showLog(
          'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };

    ZegoExpressEngine.onRemoteCameraStateUpdate = (streamID, state) {
      Utils.showLog("Camera is :: $state");

      if (state == ZegoRemoteDeviceState.Open) {
        remoteVideoOff = false;
      } else {
        remoteVideoOff = true;
      }
      update([Constant.idVideoCall]);
    };

    ZegoExpressEngine.onRemoteMicStateUpdate = (streamID, state) {
      Utils.showLog("Mic Mute is :: $state");

      if (state == ZegoRemoteDeviceState.Mute) {
        remoteMicMute = true;
      } else {
        remoteMicMute = false;
      }
      update([Constant.idVideoCall]);
    };

    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      Utils.showLog(
          'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          if (stream.streamID == publishedStreamId) {
            continue;
          }
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);
        }
      }
    };

    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      Utils.showLog(
          'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
      Utils.showLog(
          'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    ///call auto cut when app kill one side call uncomment this
    // ZegoExpressEngine.onRoomUserUpdate =
    //     (roomID, updateType, List<ZegoUser> userList) {
    //
    //       Utils.showLog(
    //       'onRoomUserUpdate: roomID: $roomID, '
    //           'updateType: ${updateType.name}, '
    //           'userList: ${userList.map((e) => e.userID)}'
    //   );
    //
    //   if (updateType == ZegoUpdateType.Delete) {
    //     // 👇 SAME USER ROOM MATHI NIKLI GAYO
    //
    //     Get.back();
    //
    //     endCallDueToBackground();
    //     Utils.showLog("User left the room");
    //
    //     // ahi tame call cut, UI update, etc kari shako
    //   }
    //
    //   if (updateType == ZegoUpdateType.Add) {
    //     // 👇 Navo user room ma aavyo
    //     Utils.showLog("User joined the room");
    //   }
    // };
  }

  void stopListenEvent() {
    log("Enter in stop listen event");
    Constant.storage.write("isVideoCall", false);

    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      if (state == ZegoRoomState.Disconnected) {
        ZegoExpressEngine.instance.muteMicrophone(false);
        ZegoExpressEngine.instance.enableCamera(true);
        ZegoExpressEngine.instance.useFrontCamera(true);

        stopTimer();
      }
    };
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPlayStream(String streamID) async {
    if (playingStreamId == streamID) {
      return;
    }

    if (playingStreamId != null && playingStreamId != streamID) {
      await stopPlayStream(playingStreamId!);
    }

    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }).then((canvasViewWidget) {
      playingStreamId = streamID;
      remoteView = canvasViewWidget;
      update([Constant.idVideoCall]);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    if (playingStreamId != null && playingStreamId != streamID) {
      return;
    }

    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);

      /// setState
      remoteViewID = null;
      remoteView = null;
      playingStreamId = null;
      update([Constant.idVideoCall]);
    }
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    await logoutRoom();
    final user = ZegoUser(_currentZegoUserId(), _zegoUserName());
    final roomID = _resolvedRoomId();
    Utils.showLog('Resolved Zego roomID (video): $roomID');

    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()
      ..isUserStatusNotify = true;

    return ZegoExpressEngine.instance
        .loginRoom(roomID, user, config: roomConfig)
        .then((ZegoRoomLoginResult loginRoomResult) async {
      log('loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
      if (loginRoomResult.errorCode == 0) {
        await startPreview();
        await startPublish();
      } else {
        log("Login Room Failed Status Code :: ${loginRoomResult.errorCode}");
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(_resolvedRoomId());
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;
      ZegoCanvas previewCanvas =
          ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      ///SetState
      localView = canvasViewWidget;
      update([Constant.idVideoCall]);
    });
  }

  Future<void> stopPreview() async {
    // ZegoExpressEngine.instance.stopPreview();
    ZegoExpressEngine.instance.stopPreview();

    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);

      ///setState
      localViewID = null;
      localView = null;
      update([Constant.idVideoCall]);
    }
  }

  Future<void> startPublish() async {
    publishedStreamId = _resolvedStreamId();
    Utils.showLog('Publishing Zego streamID (video): $publishedStreamId');
    return ZegoExpressEngine.instance.startPublishingStream(publishedStreamId!);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  void endCallDueToBackground() {
    log("endCallDueToBackground");
    SocketEmit.emitCallTerminated(
      callerId: callerId ?? '',
      receiverId: receiverId ?? '',
      callId: callId ?? '',
      callType: callType ?? '',
      callMode: callMode ?? '',
      callerRole: callerRole ?? '',
      receiverRole: receiverRole ?? '',
      receiverImage: receiverImage ?? '',
      receiverName: receiverName ?? '',
    );
    // Get.back(); // or navigate to a call ended screen
  }
}

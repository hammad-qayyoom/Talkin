import 'dart:async';
import 'dart:convert';
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
  static const String _hostControlType = 'host_control';
  static const String _groupChatType = 'group_chat';
  static const String _actionMuteAudio = 'mute_audio';
  static const String _actionUnmuteAudio = 'unmute_audio';
  static const String _actionMuteVideo = 'mute_video';
  static const String _actionUnmuteVideo = 'unmute_video';
  static const String _actionKickUser = 'kick_user';

  List<CoinPlan> coinPlan = [];

  late Map<String, dynamic> args;

  bool cameraTurn = true;

  bool micMute = false;
  bool isCameraOff = false;
  bool forceAudioMutedByHost = false;
  bool forceVideoMutedByHost = false;

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
  final Map<String, int> remoteViewIdsByStream = <String, int>{};
  final Map<String, Widget> remoteViewsByStream = <String, Widget>{};
  final Map<String, ZegoUser> roomUsersById = <String, ZegoUser>{};
  final Map<String, String> remoteUserIdsByStream = <String, String>{};
  final Map<String, String> remoteUserNamesByStream = <String, String>{};
  final Set<String> locallyMutedRemoteAudioStreamIds = <String>{};
  final Set<String> locallyMutedRemoteVideoStreamIds = <String>{};
  final Set<String> expertMutedRemoteAudioStreamIds = <String>{};
  final Set<String> expertMutedRemoteVideoStreamIds = <String>{};
  final Set<String> minimizedRemoteStreamIds = <String>{};
  final Set<String> _seenGroupChatMessageIds = <String>{};
  final List<GroupLiveChatMessage> groupLiveChatMessages =
      <GroupLiveChatMessage>[];
  final TextEditingController groupLiveChatInputController =
      TextEditingController();
  int unreadGroupChatCount = 0;
  bool isGroupChatSheetOpen = false;
  String? focusedRemoteStreamId;
  String? _runtimeGroupZegoUserId;

  static const double _selfPreviewMinWidth = 104;
  static const double _selfPreviewMaxWidth = 230;
  static const double _selfPreviewAspectRatio = 132 / 160;
  double selfPreviewWidth = 132;
  double selfPreviewHeight = 160;
  double selfPreviewLeft = 0;
  double selfPreviewTop = 35;
  bool _selfPreviewLayoutInitialized = false;

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
    groupLiveChatInputController.dispose();

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

  String _resolvedZegoUserId() {
    if (!_isGroupSessionCall) {
      return _currentZegoUserId();
    }

    if ((_runtimeGroupZegoUserId ?? '').trim().isEmpty) {
      final base = _safeZegoId(_currentZegoUserId(), maxLength: 40);
      final runtimeSuffix = DateTime.now().millisecondsSinceEpoch.toString();
      _runtimeGroupZegoUserId =
          _safeZegoId('${base}_grp_$runtimeSuffix', maxLength: 63);
    }

    return _runtimeGroupZegoUserId!;
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
    final userId = _safeZegoId(_resolvedZegoUserId(), maxLength: 24);
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
    if (forceAudioMutedByHost) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Expert control active: audio is locked');
      }
      return;
    }

    micMute = !micMute;
    ZegoExpressEngine.instance.muteMicrophone(micMute);

    update([Constant.idMicMute, Constant.idVideoCall]);
  }

  onCameraOff() {
    if (forceVideoMutedByHost) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Expert control active: video is locked');
      }
      return;
    }

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
    if (forceVideoMutedByHost) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Expert control active: video is locked');
      }
      return;
    }

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

      if (updateType == ZegoUpdateType.Add) {
        for (final user in userList) {
          roomUsersById[user.userID] = user;
        }
      } else {
        for (final user in userList) {
          roomUsersById.remove(user.userID);
        }
      }

      update([Constant.idVideoCall]);
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
          roomUsersById[stream.user.userID] = stream.user;
          remoteUserIdsByStream[stream.streamID] = stream.user.userID;
          remoteUserNamesByStream[stream.streamID] = stream.user.userName;
          startPlayStream(stream);
        }
      } else {
        for (final stream in streamList) {
          roomUsersById.remove(stream.user.userID);
          stopPlayStream(stream.streamID);
        }
      }
    };

    ZegoExpressEngine.onIMRecvCustomCommand = (roomID, fromUser, command) {
      _handleIncomingHostCommand(fromUser, command);
      _handleIncomingGroupChatCommand(fromUser, command);
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
    ZegoExpressEngine.onIMRecvCustomCommand = null;
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

  Future<void> startPlayStream(ZegoStream stream) async {
    final streamID = stream.streamID;

    if (remoteViewsByStream.containsKey(streamID)) {
      return;
    }

    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewIdsByStream[streamID] = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }).then((canvasViewWidget) {
      if (canvasViewWidget == null) {
        return;
      }
      remoteViewsByStream[streamID] = canvasViewWidget;

      if (locallyMutedRemoteAudioStreamIds.contains(streamID)) {
        ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, true);
      }

      if (locallyMutedRemoteVideoStreamIds.contains(streamID)) {
        ZegoExpressEngine.instance.mutePlayStreamVideo(streamID, true);
      }

      _refreshPrimaryRemoteView();
      update([Constant.idVideoCall]);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);

    final viewID = remoteViewIdsByStream.remove(streamID);
    if (viewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(viewID);
    }

    remoteViewsByStream.remove(streamID);
    final remoteUserId = remoteUserIdsByStream[streamID];
    if (remoteUserId != null && remoteUserId.isNotEmpty) {
      roomUsersById.remove(remoteUserId);
    }
    remoteUserIdsByStream.remove(streamID);
    remoteUserNamesByStream.remove(streamID);
    locallyMutedRemoteAudioStreamIds.remove(streamID);
    locallyMutedRemoteVideoStreamIds.remove(streamID);
    expertMutedRemoteAudioStreamIds.remove(streamID);
    expertMutedRemoteVideoStreamIds.remove(streamID);
    minimizedRemoteStreamIds.remove(streamID);
    if (focusedRemoteStreamId == streamID) {
      focusedRemoteStreamId = null;
    }
    _refreshPrimaryRemoteView();
    update([Constant.idVideoCall]);
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    await logoutRoom();
    final user = ZegoUser(_resolvedZegoUserId(), _zegoUserName());
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
    await _clearAllRemoteStreams();
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

  void _refreshPrimaryRemoteView() {
    if (remoteViewsByStream.isEmpty) {
      remoteViewID = null;
      remoteView = null;
      playingStreamId = null;
      return;
    }

    final firstStreamId = remoteViewsByStream.keys.first;
    playingStreamId = firstStreamId;
    remoteViewID = remoteViewIdsByStream[firstStreamId];
    remoteView = remoteViewsByStream[firstStreamId];
  }

  Future<void> _clearAllRemoteStreams() async {
    final streamIds = remoteViewsByStream.keys.toList(growable: false);
    for (final streamId in streamIds) {
      await stopPlayStream(streamId);
    }
  }

  void prepareSelfPreviewLayout(
    Size viewport, {
    double topPadding = 35,
    double bottomPadding = 120,
    double horizontalPadding = 10,
  }) {
    if (!_selfPreviewLayoutInitialized) {
      selfPreviewLeft = viewport.width - selfPreviewWidth - horizontalPadding;
      selfPreviewTop = topPadding;
      _selfPreviewLayoutInitialized = true;
    }

    _clampSelfPreviewInBounds(
      viewport,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      horizontalPadding: horizontalPadding,
    );
  }

  void dragSelfPreview(
    Offset delta,
    Size viewport, {
    double topPadding = 35,
    double bottomPadding = 120,
    double horizontalPadding = 10,
  }) {
    selfPreviewLeft += delta.dx;
    selfPreviewTop += delta.dy;

    _clampSelfPreviewInBounds(
      viewport,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      horizontalPadding: horizontalPadding,
    );
    update([Constant.idVideoCall]);
  }

  void resizeSelfPreview(
    Offset delta,
    Size viewport, {
    double topPadding = 35,
    double bottomPadding = 120,
    double horizontalPadding = 10,
  }) {
    final sizeDelta = delta.dx + (delta.dy * 0.7);
    selfPreviewWidth += sizeDelta;

    _clampSelfPreviewInBounds(
      viewport,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      horizontalPadding: horizontalPadding,
    );
    update([Constant.idVideoCall]);
  }

  void _clampSelfPreviewInBounds(
    Size viewport, {
    required double topPadding,
    required double bottomPadding,
    required double horizontalPadding,
  }) {
    final availableWidth = (viewport.width - (horizontalPadding * 2))
        .clamp(80.0, double.infinity)
        .toDouble();
    final availableHeight = (viewport.height - topPadding - bottomPadding)
        .clamp(120.0, double.infinity)
        .toDouble();

    final maxWidthByHeight = (availableHeight * _selfPreviewAspectRatio)
        .clamp(_selfPreviewMinWidth, _selfPreviewMaxWidth)
        .toDouble();
    final maxAllowedWidth =
        availableWidth < maxWidthByHeight ? availableWidth : maxWidthByHeight;

    selfPreviewWidth = selfPreviewWidth
        .clamp(_selfPreviewMinWidth, maxAllowedWidth)
        .toDouble();
    selfPreviewHeight = (selfPreviewWidth / _selfPreviewAspectRatio).toDouble();

    final maxLeft = viewport.width - horizontalPadding - selfPreviewWidth;
    final safeMaxLeft =
        maxLeft >= horizontalPadding ? maxLeft : horizontalPadding;
    selfPreviewLeft =
        selfPreviewLeft.clamp(horizontalPadding, safeMaxLeft).toDouble();

    final maxTop = viewport.height - bottomPadding - selfPreviewHeight;
    final safeMaxTop = maxTop >= topPadding ? maxTop : topPadding;
    selfPreviewTop = selfPreviewTop.clamp(topPadding, safeMaxTop).toDouble();
  }

  void toggleMinimizeRemoteTile(String streamID) {
    if (!remoteViewsByStream.containsKey(streamID)) {
      return;
    }

    if (minimizedRemoteStreamIds.contains(streamID)) {
      minimizedRemoteStreamIds.remove(streamID);
    } else {
      minimizedRemoteStreamIds.add(streamID);
      if (focusedRemoteStreamId == streamID) {
        focusedRemoteStreamId = null;
      }
    }
    update([Constant.idVideoCall]);
  }

  void setFocusedRemoteStream(String? streamID) {
    if (streamID == null || !remoteViewsByStream.containsKey(streamID)) {
      focusedRemoteStreamId = null;
      update([Constant.idVideoCall]);
      return;
    }

    if (minimizedRemoteStreamIds.contains(streamID)) {
      minimizedRemoteStreamIds.remove(streamID);
    }

    focusedRemoteStreamId = streamID;
    update([Constant.idVideoCall]);
  }

  bool isRemoteStreamMinimized(String streamID) {
    return minimizedRemoteStreamIds.contains(streamID);
  }

  String remoteDisplayName(String streamID) {
    final name = (remoteUserNamesByStream[streamID] ?? '').trim();
    if (name.isNotEmpty) {
      return name;
    }

    final userId = (remoteUserIdsByStream[streamID] ?? '').trim();
    if (userId.length <= 8) {
      return userId.isEmpty ? 'Participant' : userId;
    }
    return '${userId.substring(0, 8)}...';
  }

  bool isLocalRemoteAudioMuted(String streamID) {
    return locallyMutedRemoteAudioStreamIds.contains(streamID);
  }

  bool isLocalRemoteVideoMuted(String streamID) {
    return locallyMutedRemoteVideoStreamIds.contains(streamID);
  }

  void markGroupChatSheetOpened() {
    unreadGroupChatCount = 0;
    isGroupChatSheetOpen = true;
    update([Constant.idVideoCall]);
  }

  void markGroupChatSheetClosed() {
    isGroupChatSheetOpen = false;
  }

  Future<void> sendGroupChatMessage(String rawMessage) async {
    if (!_isGroupSessionCall) {
      return;
    }

    final message = rawMessage.trim();
    if (message.isEmpty) {
      return;
    }

    groupLiveChatInputController.clear();

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final senderUserId = _resolvedZegoUserId();
    final senderName = _zegoUserName();
    final messageId = '${senderUserId}_$nowMs';

    _appendGroupChatMessage(
      GroupLiveChatMessage(
        messageId: messageId,
        senderUserId: senderUserId,
        senderName: senderName,
        message: message,
        sentAtMs: nowMs,
        isMine: true,
      ),
      incoming: false,
    );

    final recipients = roomUsersById.values
        .where((user) => user.userID != senderUserId)
        .toList(growable: false);
    if (recipients.isEmpty) {
      return;
    }

    final payload = jsonEncode({
      'type': _groupChatType,
      'messageId': messageId,
      'senderUserId': senderUserId,
      'senderName': senderName,
      'message': message,
      'sentAt': nowMs,
    });

    try {
      final result = await ZegoExpressEngine.instance.sendCustomCommand(
        _resolvedRoomId(),
        payload,
        recipients,
      );

      if (result.errorCode != 0 && Get.context != null) {
        Utils.showToast(
          Get.context!,
          'Live chat delivery failed (${result.errorCode})',
        );
      }
    } catch (e) {
      Utils.showLog('Group live chat send failed: $e');
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Unable to send live chat message');
      }
    }
  }

  void _handleIncomingGroupChatCommand(ZegoUser fromUser, String command) {
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(command);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      payload = decoded;
    } catch (_) {
      return;
    }

    if ((payload['type'] ?? '').toString() != _groupChatType) {
      return;
    }

    final message = (payload['message'] ?? '').toString().trim();
    if (message.isEmpty) {
      return;
    }

    final senderUserId =
        (payload['senderUserId'] ?? fromUser.userID).toString().trim();
    if (senderUserId.isEmpty || senderUserId == _resolvedZegoUserId()) {
      return;
    }

    final messageId =
        (payload['messageId'] ?? '${senderUserId}_${payload['sentAt'] ?? ''}')
            .toString()
            .trim();

    final sentAtMs = int.tryParse((payload['sentAt'] ?? '').toString()) ??
        DateTime.now().millisecondsSinceEpoch;

    final senderName =
        (payload['senderName'] ?? fromUser.userName).toString().trim();

    _appendGroupChatMessage(
      GroupLiveChatMessage(
        messageId: messageId,
        senderUserId: senderUserId,
        senderName: senderName.isEmpty ? senderUserId : senderName,
        message: message,
        sentAtMs: sentAtMs,
        isMine: false,
      ),
      incoming: true,
    );
  }

  void _appendGroupChatMessage(
    GroupLiveChatMessage chatMessage, {
    required bool incoming,
  }) {
    if (chatMessage.messageId.isNotEmpty &&
        _seenGroupChatMessageIds.contains(chatMessage.messageId)) {
      return;
    }

    if (chatMessage.messageId.isNotEmpty) {
      _seenGroupChatMessageIds.add(chatMessage.messageId);
    }

    groupLiveChatMessages.add(chatMessage);
    if (incoming && !isGroupChatSheetOpen) {
      unreadGroupChatCount++;
    }

    update([Constant.idVideoCall]);
  }

  bool isExpertRemoteAudioMuted(String streamID) {
    return expertMutedRemoteAudioStreamIds.contains(streamID);
  }

  bool isExpertRemoteVideoMuted(String streamID) {
    return expertMutedRemoteVideoStreamIds.contains(streamID);
  }

  Future<void> setLocalRemoteAudioMuted(
    String streamID, {
    required bool muted,
  }) async {
    if (!remoteViewsByStream.containsKey(streamID)) {
      return;
    }

    try {
      await ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, muted);

      if (muted) {
        locallyMutedRemoteAudioStreamIds.add(streamID);
      } else {
        locallyMutedRemoteAudioStreamIds.remove(streamID);
      }

      if (Get.context != null) {
        Utils.showToast(
          Get.context!,
          muted
              ? 'Participant muted only for you'
              : 'Participant audio restored for you',
        );
      }
      update([Constant.idVideoCall]);
    } catch (e) {
      Utils.showLog('Local remote-audio mute failed: $e');
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Unable to update local audio');
      }
    }
  }

  Future<void> setLocalRemoteVideoMuted(
    String streamID, {
    required bool muted,
  }) async {
    if (!remoteViewsByStream.containsKey(streamID)) {
      return;
    }

    try {
      await ZegoExpressEngine.instance.mutePlayStreamVideo(streamID, muted);

      if (muted) {
        locallyMutedRemoteVideoStreamIds.add(streamID);
      } else {
        locallyMutedRemoteVideoStreamIds.remove(streamID);
      }

      if (Get.context != null) {
        Utils.showToast(
          Get.context!,
          muted
              ? 'Participant video paused only for you'
              : 'Participant video restored for you',
        );
      }
      update([Constant.idVideoCall]);
    } catch (e) {
      Utils.showLog('Local remote-video mute failed: $e');
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Unable to update local video');
      }
    }
  }

  List<MapEntry<String, Widget>> get visibleRemoteVideoEntries =>
      remoteVideoEntries
          .where((entry) => !minimizedRemoteStreamIds.contains(entry.key))
          .toList(growable: false);

  List<MapEntry<String, Widget>> get minimizedRemoteVideoEntries =>
      remoteVideoEntries
          .where((entry) => minimizedRemoteStreamIds.contains(entry.key))
          .toList(growable: false);

  Widget? get focusedRemoteVideoWidget {
    final streamID = focusedRemoteStreamId;
    if (streamID == null) {
      return null;
    }
    return remoteViewsByStream[streamID];
  }

  String get focusedRemoteTitle {
    final streamID = focusedRemoteStreamId;
    if (streamID == null) {
      return '';
    }
    return remoteDisplayName(streamID);
  }

  bool get isExpertController {
    if (!_isGroupSessionCall) {
      return false;
    }
    return Database.fetchLoginUserProfileModel?.user?.isListener == true;
  }

  Future<void> hostMuteUserAudio(String streamID, {required bool mute}) async {
    final sent = await _sendHostCommandToStream(
      streamID,
      action: mute ? _actionMuteAudio : _actionUnmuteAudio,
    );

    if (!sent) {
      return;
    }

    if (mute) {
      expertMutedRemoteAudioStreamIds.add(streamID);
    } else {
      expertMutedRemoteAudioStreamIds.remove(streamID);
    }
    update([Constant.idVideoCall]);
  }

  Future<void> hostMuteUserVideo(String streamID, {required bool mute}) async {
    final sent = await _sendHostCommandToStream(
      streamID,
      action: mute ? _actionMuteVideo : _actionUnmuteVideo,
    );

    if (!sent) {
      return;
    }

    if (mute) {
      expertMutedRemoteVideoStreamIds.add(streamID);
    } else {
      expertMutedRemoteVideoStreamIds.remove(streamID);
    }
    update([Constant.idVideoCall]);
  }

  Future<void> hostRemoveUser(String streamID) async {
    final sent = await _sendHostCommandToStream(
      streamID,
      action: _actionKickUser,
    );

    if (!sent) {
      return;
    }

    expertMutedRemoteAudioStreamIds.remove(streamID);
    expertMutedRemoteVideoStreamIds.remove(streamID);
    update([Constant.idVideoCall]);
  }

  Future<bool> _sendHostCommandToStream(
    String streamID, {
    required String action,
  }) async {
    if (!isExpertController) {
      return false;
    }

    final targetUserId = (remoteUserIdsByStream[streamID] ?? '').trim();
    if (targetUserId.isEmpty) {
      return false;
    }

    if (targetUserId == _resolvedZegoUserId()) {
      return false;
    }

    final roomID = _resolvedRoomId();
    final payload = jsonEncode({
      'type': _hostControlType,
      'action': action,
      'targetUserId': targetUserId,
      'issuedAt': DateTime.now().millisecondsSinceEpoch,
    });

    final targetUser = ZegoUser(targetUserId, remoteDisplayName(streamID));
    try {
      final result = await ZegoExpressEngine.instance
          .sendCustomCommand(roomID, payload, <ZegoUser>[targetUser]);
      if (result.errorCode != 0 && Get.context != null) {
        Utils.showToast(Get.context!, 'Action failed (${result.errorCode})');
        return false;
      }

      return result.errorCode == 0;
    } catch (e) {
      Utils.showLog('Host command send failed: $e');
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Unable to send control command');
      }
      return false;
    }
  }

  void _handleIncomingHostCommand(ZegoUser fromUser, String command) {
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(command);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      payload = decoded;
    } catch (_) {
      return;
    }

    if ((payload['type'] ?? '').toString() != _hostControlType) {
      return;
    }

    final targetUserId = (payload['targetUserId'] ?? '').toString().trim();
    if (targetUserId.isEmpty || targetUserId != _resolvedZegoUserId()) {
      return;
    }

    final action = (payload['action'] ?? '').toString().trim();
    switch (action) {
      case _actionMuteAudio:
        forceAudioMutedByHost = true;
        micMute = true;
        ZegoExpressEngine.instance.muteMicrophone(true);
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Expert muted your audio');
        }
        break;
      case _actionUnmuteAudio:
        forceAudioMutedByHost = false;
        micMute = false;
        ZegoExpressEngine.instance.muteMicrophone(false);
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Expert unmuted your audio');
        }
        break;
      case _actionMuteVideo:
        forceVideoMutedByHost = true;
        isCameraOff = true;
        ZegoExpressEngine.instance.enableCamera(false);
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Expert turned off your video');
        }
        break;
      case _actionUnmuteVideo:
        forceVideoMutedByHost = false;
        isCameraOff = false;
        ZegoExpressEngine.instance.enableCamera(true);
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Expert turned on your video');
        }
        break;
      case _actionKickUser:
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Expert removed you from session');
        }
        Future.delayed(const Duration(milliseconds: 250), endCurrentCall);
        break;
      default:
        return;
    }

    Utils.showLog(
        'Host command applied from ${fromUser.userID}: $action for $targetUserId');
    update([Constant.idVideoCall, Constant.idMicMute, Constant.idVideoTurn]);
  }

  List<MapEntry<String, Widget>> get remoteVideoEntries =>
      remoteViewsByStream.entries.toList(growable: false);

  bool get isGroupSessionCall => _isGroupSessionCall;

  bool get _isGroupSessionCall {
    final normalized = (callMode ?? '').toString().trim().toLowerCase();
    return normalized == 'group_session' ||
        normalized == 'group' ||
        normalized == 'live_group';
  }

  void endCurrentCall() {
    if (_isGroupSessionCall) {
      if (Get.isOverlaysOpen) {
        Get.back();
      } else {
        Get.back();
      }
      return;
    }

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
  }

  void endCallDueToBackground() {
    log("endCallDueToBackground");
    endCurrentCall();
    // Get.back(); // or navigate to a call ended screen
  }
}

class GroupLiveChatMessage {
  final String messageId;
  final String senderUserId;
  final String senderName;
  final String message;
  final int sentAtMs;
  final bool isMine;

  const GroupLiveChatMessage({
    required this.messageId,
    required this.senderUserId,
    required this.senderName,
    required this.message,
    required this.sentAtMs,
    required this.isMine,
  });
}

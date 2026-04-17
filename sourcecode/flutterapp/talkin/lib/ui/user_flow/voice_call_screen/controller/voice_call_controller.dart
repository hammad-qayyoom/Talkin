import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:notisboard/services/permission_handler/permission_handler.dart';
import 'package:notisboard/socket/socket_emit.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class VoiceCallController extends GetxController {
  static const String _hostControlType = 'host_control';
  static const String _groupChatType = 'group_chat';
  static const String _actionMuteAudio = 'mute_audio';
  static const String _actionUnmuteAudio = 'unmute_audio';
  static const String _actionKickUser = 'kick_user';

  dynamic args = Get.arguments;
  bool micMute = true;
  bool cameraOff = true;
  bool cameraTurn = true;
  bool remoteVideoOff = true;
  bool remoteMicMute = false;

  String? callerId;
  String? receiverId;
  String? callerImage;
  String? callerName;
  String? receiverName;
  String? receiverImage;
  String? callId;
  String? receiverRole;
  String? callType;
  String? callMode;
  String? callerRole;

  Timer? timer;
  DateTime? startTime;
  DateTime? endTime;
  Duration? duration;
  int? minutes;
  int? seconds;
  String? finalDuration;
  String? formattedTime;

  Widget? localView;
  Widget? remoteView;
  int? remoteViewID;
  int? localViewID;
  String? publishedStreamId;
  final Set<String> playingStreamIds = <String>{};
  bool isSpeakerOn = false;
  bool isMicMute = false;
  bool forceAudioMutedByHost = false;
  String? _runtimeGroupZegoUserId;
  // bool isSpeakerOn = Get.arguments["speakerOn"] ?? "";
  // bool isMicMute = Get.arguments["micMute"] ?? "";

  StreamSubscription<bool>? subsProximity;
  bool isProximitySupported = false;
  bool isObjectNear = false;
  bool userEnabledSpeaker = false; // Only true if user taps speaker button
  final Map<String, ZegoUser> roomUsersById = <String, ZegoUser>{};
  final Map<String, String> streamIdsByUserId = <String, String>{};
  final Set<String> locallyMutedUserIds = <String>{};
  final Set<String> expertMutedUserIds = <String>{};
  final Set<String> _seenGroupChatMessageIds = <String>{};
  final List<GroupLiveChatMessage> groupLiveChatMessages =
      <GroupLiveChatMessage>[];
  final TextEditingController groupLiveChatInputController =
      TextEditingController();
  int unreadGroupChatCount = 0;
  bool isGroupChatSheetOpen = false;

  @override
  void onInit() async {
    super.onInit();
    Utils.showLog("onInit voice call controller");

    args = Get.arguments as Map<String, dynamic>;
    getDataFromArgs();

    final hasMicPermission = await _requestMicrophonePermission();
    if (!hasMicPermission) {
      Utils.showLog("Voice call start blocked: microphone permission denied.");
      Get.back();
      return;
    }

    await createEngine();

    ZegoExpressEngine.instance.muteMicrophone(isMicMute);
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);

    startListenEvent();
    final loginRoomResult = await loginRoom();
    if (loginRoomResult.errorCode != 0) {
      Utils.showLog("Voice call login failed: ${loginRoomResult.errorCode}");
      return;
    }

    WakelockPlus.enable();

    // ✅ Default speaker ON (and mark that "user preference" is ON)
    isSpeakerOn = true;
    userEnabledSpeaker = true;
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);

    startTimer();

    // Keep speaker routing predictable for now. Proximity auto-switch can
    // force earpiece on some devices and make users think audio is missing.
    isProximitySupported = false;
    isObjectNear = false;
  }

  Future<bool> _requestMicrophonePermission() async {
    var hasMicPermission = false;
    await PermissionHandler.onGetMicrophonePermission(
      onGranted: () {
        hasMicPermission = true;
      },
      onDenied: () {
        hasMicPermission = false;
      },
    );
    return hasMicPermission;
  }

  int selectedStarIndex = -1;

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
      // isMicMute = Get.arguments["micMute"] ?? "";
      // isSpeakerOn = Get.arguments["speakerOn"] ?? "";
    }

    log("callId ::$callId");
    log("callerId ::$callerId");
    log("receiverId ::$receiverId");
    log("receiverName ::$receiverName");
    log("receiverImage ::$receiverImage");
    log("callerName ::$callerName");
    log("callerImage ::$callerImage");
    log("callType ::$callType");
    log("callMode ::$callMode");
    log("callerRole ::$callerRole");
    log("receiverRole ::$receiverRole");
    log("isSpeakerOn ::$isSpeakerOn");
    log("isMicMute ::$isMicMute");
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

  void startTimer() {
    startTime = DateTime.now();
    int elapsedSeconds = 0;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

    log("Mic Mute: $isMicMute");

    isMicMute = !isMicMute;
    ZegoExpressEngine.instance.muteMicrophone(isMicMute);

    update([Constant.idMicMute, Constant.idVideoCall]);
  }

  // void onSpeakerOn() {
  //   userEnabledSpeaker = true; // User manually enabled speaker
  //   isSpeakerOn = !isSpeakerOn;
  //   ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);
  //   log("🔊 Speaker turned ON by user");
  //   update([Constant.idSpeakerOpen, Constant.idVideoCall]);
  // }
  void onSpeakerOn() {
    isSpeakerOn = !isSpeakerOn;
    userEnabledSpeaker = isSpeakerOn;
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);
    log("🔊 Speaker toggled by user: $isSpeakerOn");
    update([Constant.idSpeakerOpen, Constant.idVideoCall]);
  }

  Future<void> createEngine() async {
    log("Voice Call Create Engine");
    final appId = int.tryParse(
        Database.settingApiModel?.data?.zegoAppId?.toString() ?? '');
    final appSign =
        Database.settingApiModel?.data?.zegoAppSignIn?.toString() ?? '';

    if (appId == null || appId <= 0 || appSign.isEmpty) {
      log("Voice Call Create Engine skipped: invalid app settings.");
      return;
    }

    try {
      await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
        appId,
        ZegoScenario.Default,
        appSign: kIsWeb ? null : appSign,
      ));
    } catch (e) {
      log("Voice Call Create Engine skipped/failed: $e");
    }
  }

  void startListenEvent() {
    Constant.storage.write("isVideoCall", true);

    ZegoExpressEngine.onRoomUserUpdate =
        (roomID, updateType, List<ZegoUser> userList) {
      log('onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');

      if (updateType == ZegoUpdateType.Add) {
        for (final user in userList) {
          roomUsersById[user.userID] = user;
        }
      } else {
        for (final user in userList) {
          roomUsersById.remove(user.userID);
          streamIdsByUserId.remove(user.userID);
          expertMutedUserIds.remove(user.userID);
        }
      }
      update([Constant.idVideoCall]);
    };

    ZegoExpressEngine.onRemoteCameraStateUpdate = (streamID, state) {
      log("Camera is :: $state");

      if (state == ZegoRemoteDeviceState.Open) {
        remoteVideoOff = false;
      } else {
        remoteVideoOff = true;
      }
      update([Constant.idVideoCall]);
    };

    ZegoExpressEngine.onRemoteMicStateUpdate = (streamID, state) {
      log("Mic Mute is :: $state");

      if (state == ZegoRemoteDeviceState.Mute) {
        remoteMicMute = true;
      } else {
        remoteMicMute = false;
      }
      update([Constant.idVideoCall]);
    };

    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      log('onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          if (stream.streamID == publishedStreamId) {
            continue;
          }
          roomUsersById[stream.user.userID] = stream.user;
          streamIdsByUserId[stream.user.userID] = stream.streamID;
          startPlayStream(stream.streamID, userID: stream.user.userID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);
          roomUsersById.remove(stream.user.userID);
          streamIdsByUserId.remove(stream.user.userID);
        }
      }
    };

    ZegoExpressEngine.onIMRecvCustomCommand = (roomID, fromUser, command) {
      _handleIncomingHostCommand(fromUser, command);
      _handleIncomingGroupChatCommand(fromUser, command);
    };

    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      log('onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
      log('onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };
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

  Future<void> startPlayStream(String streamID, {String? userID}) async {
    if (playingStreamIds.contains(streamID)) {
      return;
    }

    await ZegoExpressEngine.instance.startPlayingStream(streamID);

    if (userID != null && locallyMutedUserIds.contains(userID)) {
      await ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, true);
    }

    playingStreamIds.add(streamID);
    ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);
    log("Stream started playing for: $streamID");
    update([Constant.idVideoCall]);
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    playingStreamIds.remove(streamID);
    update([Constant.idVideoCall]);
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    // await logoutRoom();
    final user = ZegoUser(_resolvedZegoUserId(), _zegoUserName());
    final roomID = _resolvedRoomId();
    Utils.showLog('Resolved Zego roomID (voice): $roomID');

    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()
      ..isUserStatusNotify = true;

    return ZegoExpressEngine.instance
        .loginRoom(roomID, user, config: roomConfig)
        .then((ZegoRoomLoginResult loginRoomResult) async {
      log('loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
      if (loginRoomResult.errorCode == 0) {
        // Voice call is audio-only; keep camera disabled for stable publish/play.
        ZegoExpressEngine.instance.enableCamera(false);
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
    Utils.showLog('Publishing Zego streamID (voice): $publishedStreamId');
    return ZegoExpressEngine.instance.startPublishingStream(publishedStreamId!);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  bool get _isGroupSessionCall {
    final normalized = (callMode ?? '').toString().trim().toLowerCase();
    return normalized == 'group_session' ||
        normalized == 'group' ||
        normalized == 'live_group';
  }

  bool get isGroupSessionCall => _isGroupSessionCall;

  bool get isExpertController {
    if (!_isGroupSessionCall) {
      return false;
    }
    return Database.fetchLoginUserProfileModel?.user?.isListener == true;
  }

  List<ZegoUser> get manageableUsers {
    final selfId = _resolvedZegoUserId();
    return roomUsersById.values
        .where((user) => user.userID != selfId)
        .toList(growable: false);
  }

  bool isLocalUserAudioMuted(String userID) {
    return locallyMutedUserIds.contains(userID.trim());
  }

  bool isExpertUserAudioMuted(String userID) {
    return expertMutedUserIds.contains(userID.trim());
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
      log('Group live chat send failed (voice): $e');
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

  Future<void> setLocalUserAudioMuted(
    String userID, {
    required bool muted,
  }) async {
    final cleanUserId = userID.trim();
    if (cleanUserId.isEmpty || cleanUserId == _resolvedZegoUserId()) {
      return;
    }

    if (muted) {
      locallyMutedUserIds.add(cleanUserId);
    } else {
      locallyMutedUserIds.remove(cleanUserId);
    }

    final streamID = streamIdsByUserId[cleanUserId];
    if (streamID != null && streamID.isNotEmpty) {
      try {
        await ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, muted);
      } catch (e) {
        log('Local voice mute update failed: $e');
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Unable to update local audio');
        }
        return;
      }
    }

    if (Get.context != null) {
      Utils.showToast(
        Get.context!,
        muted ? 'Participant muted only for you' : 'Participant audio restored',
      );
    }
    update([Constant.idVideoCall]);
  }

  Future<void> hostMuteUserAudio(String userID, {required bool mute}) async {
    final sent = await _sendHostCommandToUser(
      userID,
      action: mute ? _actionMuteAudio : _actionUnmuteAudio,
    );

    if (!sent) {
      return;
    }

    final cleanUserId = userID.trim();
    if (mute) {
      expertMutedUserIds.add(cleanUserId);
    } else {
      expertMutedUserIds.remove(cleanUserId);
    }
    update([Constant.idVideoCall]);
  }

  Future<void> hostRemoveUser(String userID) async {
    final sent = await _sendHostCommandToUser(
      userID,
      action: _actionKickUser,
    );

    if (!sent) {
      return;
    }

    expertMutedUserIds.remove(userID.trim());
    update([Constant.idVideoCall]);
  }

  Future<bool> _sendHostCommandToUser(
    String targetUserId, {
    required String action,
  }) async {
    if (!isExpertController) {
      return false;
    }

    final cleanTarget = targetUserId.trim();
    if (cleanTarget.isEmpty || cleanTarget == _resolvedZegoUserId()) {
      return false;
    }

    final roomID = _resolvedRoomId();
    final fallbackName = roomUsersById[cleanTarget]?.userName ?? cleanTarget;
    final payload = jsonEncode({
      'type': _hostControlType,
      'action': action,
      'targetUserId': cleanTarget,
      'issuedAt': DateTime.now().millisecondsSinceEpoch,
    });

    try {
      final result = await ZegoExpressEngine.instance.sendCustomCommand(
        roomID,
        payload,
        <ZegoUser>[ZegoUser(cleanTarget, fallbackName)],
      );

      if (result.errorCode != 0 && Get.context != null) {
        Utils.showToast(Get.context!, 'Action failed (${result.errorCode})');
        return false;
      }

      return result.errorCode == 0;
    } catch (e) {
      log('Host command send failed (voice): $e');
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
        isMicMute = true;
        ZegoExpressEngine.instance.muteMicrophone(true);
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Expert muted your audio');
        }
        break;
      case _actionUnmuteAudio:
        forceAudioMutedByHost = false;
        isMicMute = false;
        ZegoExpressEngine.instance.muteMicrophone(false);
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Expert unmuted your audio');
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

    log('Host command applied in voice from ${fromUser.userID}: $action');
    update([Constant.idVideoCall, Constant.idMicMute]);
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

  senseProximity() async {
    Utils.showLog("111111111111111111111111");
    isProximitySupported = await ProximityScreenLock.isProximityLockSupported();
    Utils.showLog("2222222222222222222222222");

    if (isProximitySupported) {
      Utils.showLog("3333333333333333333333333333333");

      await ProximityScreenLock.setActive(true);
      Utils.showLog("444444444444444444444444444444");

      Utils.showLog("5555555555555555555555555555555555555");

      subsProximity = ProximityScreenLock.proximityStates.listen(
        (objectDetected) {
          log("🔥 Proximity detected on CALLER: $objectDetected");
          isObjectNear = objectDetected;

          if (objectDetected && isSpeakerOn) {
            isSpeakerOn = false;
            ZegoExpressEngine.instance.setAudioRouteToSpeaker(false);
            update([Constant.idSpeakerOpen, Constant.idVideoCall]);
          }
        },
        onError: (error) {
          log("❌ Proximity Stream Error: $error");
        },
        onDone: () {
          log("❌ Proximity Stream Closed");
        },
        cancelOnError: true,
      );
    }
  }

  // @override
  // void onClose() {
  //   stopListenEvent();
  //
  //   logoutRoom();
  //
  //   stopTimer();
  //   subsProximity?.cancel();
  //   ProximityScreenLock.setActive(false);
  //   isProximitySupported = false;
  //   isObjectNear = false;
  //   log("Proximity object detected audio/voice call controller dispose : $isObjectNear");
  //
  //   super.onClose();
  // }
  @override
  void onClose() {
    log("onClose");
    stopListenEvent();
    logoutRoom();
    WakelockPlus.disable();
    stopTimer();
    groupLiveChatInputController.dispose();

    // ✅ Properly cleanup proximity sensor
    subsProximity?.cancel();
    subsProximity = null;

    // ✅ Force deactivate proximity sensor and unlock screen
    _cleanupProximitySensor();

    super.onClose();
  }

// ✅ Add this helper method to properly cleanup proximity sensor
  Future<void> _cleanupProximitySensor() async {
    log("✅ Cleaning up proximity sensor");
    ProximityScreenLock.proximityStates.listen((objectDetected) async {
      log(objectDetected ? 'Object detected' : 'No object detected');
    });
    try {
      await ProximityScreenLock.setActive(false);
      log("✅ Proximity sensor deactivated in onClose");
      ProximityScreenLock.proximityStates.listen((objectDetected) async {
        log(objectDetected ? 'Object detected' : 'No object detected');
      });
      // if (isProximitySupported) {
      //   await ProximityScreenLock.setActive(false);
      //   log("✅ Proximity sensor deactivated in onClose");
      // }

      isProximitySupported = false;
      isObjectNear = false;
      userEnabledSpeaker = false;

      log("✅ Proximity cleanup completed");
    } catch (e) {
      log("❌ Error cleaning up proximity sensor: $e");
    }
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

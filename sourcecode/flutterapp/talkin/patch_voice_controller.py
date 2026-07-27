import re

file_path = "/Users/hammadqayyoom/Projects/Notisboard/sourcecode/flutterapp/talkin/lib/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart"
with open(file_path, "r") as f:
    content = f.read()

# Add _screenShareType and actions
if "_screenShareType" not in content:
    content = content.replace(
        "  static const String _actionKickUser = 'kick_user';",
        "  static const String _actionKickUser = 'kick_user';\n  static const String _screenShareType = 'screen_share';\n  static const String _actionScreenShareStarted = 'screen_share_started';\n  static const String _actionScreenShareStopped = 'screen_share_stopped';"
    )

# Add screen sharing state variables
if "bool isScreenSharing = false;" not in content:
    content = content.replace(
        "  bool isGroupChatSheetOpen = false;",
        "  bool isGroupChatSheetOpen = false;\n\n  // Screen Sharing\n  bool isScreenSharing = false;\n  bool remoteIsScreenSharing = false;\n  String remoteScreenSharerName = '';\n  DateTime? _screenShareStartTime;\n  int _screenShareDurationSeconds = 0;\n  Timer? _screenShareMaxDurationTimer;\n  final Map<String, int> remoteViewIdsByStream = <String, int>{};\n  final Map<String, Widget> remoteViewsByStream = <String, Widget>{};"
    )

# Update onIMRecvCustomCommand
if "_handleIncomingScreenShareCommand" not in content:
    content = content.replace(
        "      _handleIncomingGroupChatCommand(fromUser, command);",
        "      _handleIncomingGroupChatCommand(fromUser, command);\n      _handleIncomingScreenShareCommand(fromUser, command);"
    )

# Update startPlayStream to support canvas
old_start_play = """  Future<void> startPlayStream(String streamID, {String? userID}) async {
    if (playingStreamIds.contains(streamID)) {
      return;
    }

    await ZegoExpressEngine.instance.startPlayingStream(streamID);"""

new_start_play = """  Future<void> startPlayStream(String streamID, {String? userID}) async {
    if (playingStreamIds.contains(streamID)) {
      return;
    }

    if (remoteViewsByStream.containsKey(streamID)) {
      return;
    }

    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewIdsByStream[streamID] = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: remoteIsScreenSharing ? ZegoViewMode.AspectFit : ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }).then((canvasViewWidget) {
      if (canvasViewWidget == null) {
        return;
      }
      remoteViewsByStream[streamID] = canvasViewWidget;
      remoteView = canvasViewWidget; // For 1-to-1 fallback

      if (userID != null && locallyMutedUserIds.contains(userID)) {
        ZegoExpressEngine.instance.mutePlayStreamAudio(streamID, true);
      }
      playingStreamIds.add(streamID);
      ZegoExpressEngine.instance.setAudioRouteToSpeaker(isSpeakerOn);
      log("Stream started playing for: $streamID");
      update([Constant.idVideoCall]);
    });"""

content = content.replace(old_start_play, new_start_play)

# Add stop logic to stopPlayStream
old_stop_play = """  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    playingStreamIds.remove(streamID);
    update([Constant.idVideoCall]);
  }"""

new_stop_play = """  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    playingStreamIds.remove(streamID);
    
    final viewID = remoteViewIdsByStream.remove(streamID);
    if (viewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(viewID);
    }
    remoteViewsByStream.remove(streamID);
    if (remoteViewsByStream.isEmpty) {
      remoteView = null;
    }

    update([Constant.idVideoCall]);
  }"""

content = content.replace(old_stop_play, new_stop_play)


# Add the new methods at the end of the class before the last closing brace
screen_share_methods = """
  // ==========================================
  // Screen Sharing Methods
  // ==========================================

  bool get canScreenShare {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) return true;
    return false;
  }

  int get screenShareMaxDurationMinutes {
    final cfg = Database.settingApiModel?.data;
    if (cfg == null) return 15;
    return int.tryParse(cfg.callMaxTime ?? '') ?? 15;
  }

  Future<void> toggleScreenShare() async {
    if (isScreenSharing) {
      await _stopScreenShare();
    } else {
      await _startScreenShare();
    }
  }

  Future<void> _startScreenShare() async {
    if (!canScreenShare) {
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Screen sharing is not supported on this device.');
      }
      return;
    }

    try {
      if (Platform.isAndroid) {
        // Need to check for flutter_background or foreground service if present
        // Since we are in an audio call, we might already have it, but for screen share Android requires a foreground service with media projection.
        // We will just try starting screen capture on Main channel.
      }

      ZegoExpressEngine.instance.setVideoSource(ZegoVideoSourceType.ScreenCapture, channel: ZegoPublishChannel.Main);

      isScreenSharing = true;
      _screenShareStartTime = DateTime.now();

      final maxMinutes = screenShareMaxDurationMinutes;
      if (maxMinutes > 0) {
        _screenShareMaxDurationTimer?.cancel();
        _screenShareMaxDurationTimer = Timer(
          Duration(minutes: maxMinutes),
          () {
            if (isScreenSharing) {
              if (Get.context != null) {
                Utils.showToast(Get.context!, 'Screen sharing ended (max duration reached).');
              }
              _stopScreenShare();
            }
          },
        );
      }

      await _sendScreenShareCommand(_actionScreenShareStarted);
      
      // Update canvas to AspectFit for our own preview if needed, but audio call has no local preview usually.
      
      update([Constant.idVideoCall]);
    } catch (e) {
      log('Failed to start screen sharing: $e');
      isScreenSharing = false;
      ZegoExpressEngine.instance.setVideoSource(ZegoVideoSourceType.None, channel: ZegoPublishChannel.Main);
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Failed to start screen sharing.');
      }
      update([Constant.idVideoCall]);
    }
  }

  Future<void> _stopScreenShare() async {
    try {
      ZegoExpressEngine.instance.setVideoSource(ZegoVideoSourceType.None, channel: ZegoPublishChannel.Main);
      
      isScreenSharing = false;
      if (_screenShareStartTime != null) {
        _screenShareDurationSeconds += DateTime.now().difference(_screenShareStartTime!).inSeconds;
      }
      _screenShareStartTime = null;
      _screenShareMaxDurationTimer?.cancel();
      _screenShareMaxDurationTimer = null;

      await _sendScreenShareCommand(_actionScreenShareStopped);
      update([Constant.idVideoCall]);

    } catch (e) {
      log('Failed to stop screen sharing: $e');
    }
  }

  Future<void> _sendScreenShareCommand(String action) async {
    if (!_isGroupSessionCall) {
      final payload = jsonEncode({
        'type': _screenShareType,
        'action': action,
        'sharerName': _zegoUserName(),
      });
      await ZegoExpressEngine.instance.sendCustomCommand(_resolvedRoomId(), payload, []);
      return;
    }

    final recipients = roomUsersById.values
        .where((user) => user.userID != _resolvedZegoUserId())
        .toList(growable: false);
    if (recipients.isEmpty) return;

    final payload = jsonEncode({
      'type': _screenShareType,
      'action': action,
      'sharerName': _zegoUserName(),
    });

    await ZegoExpressEngine.instance.sendCustomCommand(_resolvedRoomId(), payload, recipients);
  }

  void _handleIncomingScreenShareCommand(ZegoUser fromUser, String command) {
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(command);
      if (decoded is! Map<String, dynamic>) return;
      payload = decoded;
    } catch (_) {
      return;
    }

    if ((payload['type'] ?? '').toString() != _screenShareType) return;

    final action = (payload['action'] ?? '').toString().trim();
    final sharerName = (payload['sharerName'] ?? fromUser.userName).toString().trim();

    switch (action) {
      case _actionScreenShareStarted:
        remoteIsScreenSharing = true;
        remoteScreenSharerName = sharerName.isNotEmpty ? sharerName : 'Participant';
        
        final streamId = streamIdsByUserId[fromUser.userID];
        if (streamId != null) {
          final viewId = remoteViewIdsByStream[streamId];
          if (viewId != null) {
            ZegoCanvas canvas = ZegoCanvas(viewId, viewMode: ZegoViewMode.AspectFit);
            ZegoExpressEngine.instance.startPlayingStream(streamId, canvas: canvas);
          }
        }

        update([Constant.idVideoCall]);
        if (Get.context != null) {
          Utils.showToast(Get.context!, '$remoteScreenSharerName started sharing their screen.');
        }
        break;
      case _actionScreenShareStopped:
        remoteIsScreenSharing = false;
        remoteScreenSharerName = '';

        final stoppedStreamId = streamIdsByUserId[fromUser.userID];
        if (stoppedStreamId != null) {
          final viewId = remoteViewIdsByStream[stoppedStreamId];
          if (viewId != null) {
            ZegoCanvas canvas = ZegoCanvas(viewId, viewMode: ZegoViewMode.AspectFill);
            ZegoExpressEngine.instance.startPlayingStream(stoppedStreamId, canvas: canvas);
          }
        }

        update([Constant.idVideoCall]);
        if (Get.context != null) {
          Utils.showToast(Get.context!, 'Screen sharing stopped.');
        }
        break;
    }
  }

"""

if "_startScreenShare" not in content:
    content = content[:content.rfind("}")] + screen_share_methods + "\n}\n"

with open(file_path, "w") as f:
    f.write(content)

import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/socket/socket_emit.dart';
import 'package:notisboard/socket/socket_service.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:notisboard/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';
import 'package:notisboard/ui/host_flow/host_personal_chat_screen/model/host_personal_chat_model.dart';
import 'package:notisboard/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:notisboard/ui/common/session_booking/session_booking_service.dart';
import 'package:notisboard/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:notisboard/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:notisboard/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
import 'package:notisboard/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/socket_events.dart';
import 'package:notisboard/utils/socket_params.dart';
import 'package:notisboard/utils/utils.dart';

import '../services/notification_service/notification_services.dart';

class SocketListen {
  static final Map<String, String> _latestMessageIdPerChat = {};
  static Timer? _seenEmitTimer;
  static bool _listenersAttached = false;
  static bool _connectHookAttached = false;
  static int? _socketIdentity;

  static Future<void> _reportSessionCallOutcomeIfNeeded(
    dynamic data, {
    required String outcome,
  }) async {
    if (data is! Map) {
      return;
    }

    final bookingId = (data['bookingId'] ?? '').toString().trim();
    final sessionId = (data['sessionId'] ?? '').toString().trim();

    if (bookingId.isEmpty || sessionId.isEmpty) {
      return;
    }

    final response = await SessionBookingService.reportSessionCallOutcome(
      bookingId: bookingId,
      sessionId: sessionId,
      outcome: outcome,
    );

    Utils.showLog(
        'Session call outcome reported => outcome: $outcome, bookingId: $bookingId, status: ${response['status']}');
  }

  static void _attachCallAndChatListeners() {
    if (socket == null) return;

    // Prevent duplicate handlers on reconnect / repeated register calls.
    socket?.off(SocketEvents.sendMessage);
    socket?.off(SocketEvents.markMessageSeen);
    socket?.off(SocketEvents.callOutgoingRinging);
    socket?.off(SocketEvents.outGoingCall);
    socket?.off(SocketEvents.incomingCall);
    socket?.off(SocketEvents.callResponseProcessed);
    socket?.off(SocketEvents.callDeclined);
    socket?.off(SocketEvents.callAnswered);
    socket?.off(SocketEvents.callTimedOut);
    socket?.off(SocketEvents.callEnded);
    socket?.off(SocketEvents.callerCallCut);
    socket?.off(SocketEvents.callTerminated);
    socket?.off(SocketEvents.notEnoughCoins);
    socket?.off(SocketEvents.callCoinsDeducted);
    socket?.off(SocketEvents.callCutData);
    
    // Recording
    socket?.off(SocketEvents.requestRecordingConsent);
    socket?.off(SocketEvents.recordingConsentResponse);
    socket?.off(SocketEvents.recordingConsentDenied);
    socket?.off(SocketEvents.recordingStarted);
    socket?.off(SocketEvents.recordingStopped);
    socket?.off(SocketEvents.reportRecordingComplete);
    socket?.off(SocketEvents.recordingSaved);
    socket?.off(SocketEvents.recordingEligibilityError);

    socket?.on(SocketEvents.sendMessage, handleSendMessage);
    socket?.on(SocketEvents.markMessageSeen, handleMarkMessageSeen);
    socket?.on(SocketEvents.callOutgoingRinging, handleCallOutgoingRinging);
    socket?.on(SocketEvents.outGoingCall, handleOutGoingCall);
    socket?.on(SocketEvents.incomingCall, handleIncomingCall);
    socket!.on(SocketEvents.callResponseProcessed, handleCallResponseProcessed);
    socket!.on(SocketEvents.callDeclined, handleCallDeclined);
    socket!.on(SocketEvents.callAnswered, handleCallAnswered);
    socket!.on(SocketEvents.callTimedOut, handleCallTimedOut);
    socket!.on(SocketEvents.callEnded, handleCallEnded);
    socket!.on(SocketEvents.callerCallCut, handleCallRejected);
    socket!.on(SocketEvents.callTerminated, handleCallTerminated);
    socket?.on(SocketEvents.notEnoughCoins, handleNotEnoughCoins);
    socket?.on(SocketEvents.callCoinsDeducted, handleCallCoinsDeducted);
    socket?.on(SocketEvents.callCutData, handleCallCutData);

    // Recording
    socket?.on(SocketEvents.requestRecordingConsent, handleRequestRecordingConsent);
    socket?.on(SocketEvents.recordingConsentResponse, handleRecordingConsentResponse);
    socket?.on(SocketEvents.recordingConsentDenied, handleRecordingConsentDenied);
    socket?.on(SocketEvents.recordingStarted, handleRecordingStarted);
    socket?.on(SocketEvents.recordingStopped, handleRecordingStopped);
    socket?.on(SocketEvents.reportRecordingComplete, handleReportRecordingComplete);
    socket?.on(SocketEvents.recordingSaved, handleRecordingSaved);
    socket?.on(SocketEvents.recordingEligibilityError, handleRecordingEligibilityError);

    _listenersAttached = true;
    Utils.showLog("Socket listeners attached successfully.");
  }

  static void registerListeners() {
    if (socket == null) return;

    final currentSocketIdentity = socket.hashCode;
    if (_socketIdentity != currentSocketIdentity) {
      _socketIdentity = currentSocketIdentity;
      _listenersAttached = false;
      _connectHookAttached = false;
    }

    // Always attach on current connection state.
    _attachCallAndChatListeners();

    // Re-attach on any future reconnect as well.
    if (!_connectHookAttached) {
      socket?.on("connect", (_) {
        Utils.showLog("Socket connected, re-registering listeners...");
        _attachCallAndChatListeners();
      });
      _connectHookAttached = true;
    }

    if (!_listenersAttached) {
      Utils.showLog("Socket listeners were not attached yet, retrying...");
      _attachCallAndChatListeners();
    }
  }

  static void handleSendMessage(dynamic message) {
    Utils.showLog("Received messageDispatched: $message");

    try {
      final Map<String, dynamic> data = message['data'];
      final String chatTopicId = data['chatTopicId'] ?? '';

      if (Get.isRegistered<HostPersonalChatScreenController>()) {
        final hostController = Get.find<HostPersonalChatScreenController>();
        if (chatTopicId == hostController.chatTopicId) {
          final newMsg = ListenerChat.fromJson(data);

          if (data["senderId"] ==
                  Database.fetchListenerProfileModel?.data?.id &&
              data['messageType'] == 3) {
            hostController.oldChatListener.removeAt(0);
          }

          hostController.isLoadingAudio = false;
          hostController.update([Constant.idGetOldChat]);

          // hostController.oldChatListener.insert(0, newMsg);
          // Try to find and replace the optimistic message
          final index = hostController.oldChatListener.indexWhere((msg) =>
                  msg.senderId == Database.loginUserId &&
                  msg.message == newMsg.message &&
                  msg.id?.length == 13 // temporary ID is a timestamp
              );

          if (index != -1) {
            hostController.oldChatListener[index] = newMsg;
          } else {
            hostController.oldChatListener.insert(0, newMsg);
          }

          hostController.onScrollDown();
          hostController.update([Constant.idGetOldChat]);

          if (Get.currentRoute == AppRoutes.hostPersonalChatScreen ||
              Get.currentRoute == AppRoutes.personalChatScreen) {
            final String messageId =
                message['messageId']; // ✅ Extract messageId

            if (data["senderId"] !=
                    Database.fetchListenerProfileModel?.data?.id &&
                data['receiverId'] ==
                    Database.fetchListenerProfileModel?.data?.id) {
              // Future.delayed(const Duration(seconds: 1), () {
              //   Utils.showLog("Message seen event");
              //   SocketEmit.onMessageSeen({
              //     SocketParams.messageId: messageId,
              //     SocketParams.senderId: data["senderId"],
              //   });
              // });

              _latestMessageIdPerChat[chatTopicId] = messageId;

              // Cancel previous timer if running
              _seenEmitTimer?.cancel();

              // Start a new short timer to emit only once after all messages received
              _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
                final latestMsgId = _latestMessageIdPerChat[chatTopicId];
                if (latestMsgId != null) {
                  Utils.showLog(
                      "🔥 Emitting seen for last messageId: $latestMsgId");

                  SocketEmit.onMessageSeen({
                    SocketParams.messageId: latestMsgId,
                    SocketParams.senderId: data["senderId"],
                  });

                  _latestMessageIdPerChat
                      .remove(chatTopicId); // Clear after use
                }
              });
            } else {
              Utils.showLog("Message not for current user");
            }
          }
          return;
        }
      }

      if (Get.isRegistered<PersonalChatScreenController>()) {
        final userController = Get.find<PersonalChatScreenController>();
        if (chatTopicId == userController.chatTopicId) {
          final newMsg = PersonalChat.fromJson(data);

          if (data["senderId"] == Database.loginUserId &&
              data['messageType'] == 3) {
            userController.oldChat.removeAt(0);
          }

          userController.isLoadingAudio = false;
          userController.update([Constant.idGetOldChat]);

          // userController.oldChat.insert(0, newMsg);

          // Try to find and replace the optimistic message
          final index = userController.oldChat.indexWhere((msg) =>
                  msg.senderId == Database.loginUserId &&
                  msg.message == newMsg.message &&
                  msg.id?.length == 13 // temporary ID is a timestamp
              );

          if (index != -1) {
            userController.oldChat[index] = newMsg;
          } else {
            userController.oldChat.insert(0, newMsg);
          }

          userController.onScrollDown();
          userController.update([Constant.idGetOldChat]);

          if (Get.currentRoute == AppRoutes.hostPersonalChatScreen ||
              Get.currentRoute == AppRoutes.personalChatScreen) {
            final String messageId =
                message['messageId']; // ✅ Extract messageId

            if (data["senderId"] !=
                    Database.fetchLoginUserProfileModel?.user?.id &&
                data['receiverId'] ==
                    Database.fetchLoginUserProfileModel?.user?.id) {
              // Future.delayed(const Duration(seconds: 1), () {
              //   SocketEmit.onMessageSeen({
              //     SocketParams.messageId: messageId,
              //     SocketParams.senderId: data["senderId"],
              //   });
              // });

              _latestMessageIdPerChat[chatTopicId] = messageId;

              // Cancel previous timer if running
              _seenEmitTimer?.cancel();

              // Start a new short timer to emit only once after all messages received
              _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
                final latestMsgId = _latestMessageIdPerChat[chatTopicId];
                if (latestMsgId != null) {
                  Utils.showLog(
                      "🔥 Emitting seen for last messageId: $latestMsgId");

                  SocketEmit.onMessageSeen({
                    SocketParams.messageId: latestMsgId,
                    SocketParams.senderId: data["senderId"],
                  });

                  _latestMessageIdPerChat
                      .remove(chatTopicId); // Clear after use
                }
              });
            } else {
              Utils.showLog("Message not for current user");
            }
          }

          return;
        }
      }

      Utils.showLog(" Message not for current chat topic");
    } catch (e) {
      Utils.showLog(" Error parsing socket message: $e");
    }
  }

  static void handleMarkMessageSeen(dynamic data) {
    Utils.showLog("Received markMessageSeen: $data");
    /*
        if (Get.isRegistered<HostPersonalChatScreenController>()) {
          final hostController = Get.find<HostPersonalChatScreenController>();
          Utils.showLog("hostController.isMsgSeen111: ${hostController.isMsgSeen}");
          hostController.isMsgSeen = true;
          Utils.showLog("hostController.isMsgSeen222: ${hostController.isMsgSeen}");

          hostController.update();
          Utils.showLog("hostController.isMsgSeen33: ${hostController.isMsgSeen}");
        }
        if (Get.isRegistered<PersonalChatScreenController>()) {
          final Controller = Get.find<PersonalChatScreenController>();
          Utils.showLog("hostController.isMsgSeen111: ${Controller.isMsgSeen}");
          Controller.isMsgSeen = true;
          Utils.showLog("hostController.isMsgSeen222: ${Controller.isMsgSeen}");

          Controller.update();
          Utils.showLog("hostController.isMsgSeen33: ${Controller.isMsgSeen}");
        }
    */
  }

  // static void handleMarkMessageSeen(dynamic data) {
  //   Utils.showLog("Received markMessageSeen: $data");
  //
  //   try {
  //     final parsed = jsonDecode(data);
  //     final messageId = parsed['messageId'];
  //
  //     if (Get.isRegistered<PersonalChatScreenController>()) {
  //       final controller = Get.find<PersonalChatScreenController>();
  //
  //       for (var msg in controller.oldChat) {
  //         if (msg.senderId == Database.loginUserId) {
  //           msg.isRead = true;
  //         }
  //       }
  //
  //       controller.update([Constant.idGetOldChat]);
  //     }
  //   } catch (e) {
  //     Utils.showLog("Error in markMessageSeen handler: $e");
  //   }
  // }

  /// when caller call then caller this event listen
  static void handleOutGoingCall(dynamic data) {
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
    Utils.showLog("Socket Listen => callEstablished event: $data");
    if (data['callType'] == "audio") {
      Get.toNamed(AppRoutes.outgoingAudioCallScreen, arguments: data);
    } else {
      Get.toNamed(AppRoutes.outgoingCallScreen, arguments: data);
    }
  }

  /// when caller call then receiver this event listen
  static Future<void> handleIncomingCall(dynamic data) async {
    Utils.showLog("Socket Listen => incomingCall event: $data");

    Get.toNamed(AppRoutes.incomingCallScreen, arguments: data);
  }

  /// If any error like busy, caller or receiver not found then listen always in callOutgoingRinging event
  static void handleCallOutgoingRinging(dynamic data) {
    Utils.showLog(
        "Socket Listen => callOutgoingRinging (error or status): $data");
    final message = data is Map
        ? (data['message']?.toString() ?? 'Unable to start call right now.')
        : data.toString();
    Utils.showToast(Get.context, message);
  }

  /// receiver call cut listen this event
  static void handleCallDeclined(dynamic data) {
    Utils.showLog("Socket Listen => callDeclined event: $data");

    final callerRole = (data is Map ? (data['callerRole'] ?? '') : '')
        .toString()
        .trim()
        .toLowerCase();
    final receiverRole = (data is Map ? (data['receiverRole'] ?? '') : '')
        .toString()
        .trim()
        .toLowerCase();

    if (callerRole == 'user' && receiverRole == 'listener') {
      _reportSessionCallOutcomeIfNeeded(data, outcome: 'expert_no_answer');
    } else if (callerRole == 'listener' && receiverRole == 'user') {
      _reportSessionCallOutcomeIfNeeded(data, outcome: 'user_no_answer');
    }

    if (Get.currentRoute == AppRoutes.outgoingCallScreen ||
        Get.currentRoute == AppRoutes.incomingCallScreen ||
        Get.currentRoute == AppRoutes.outgoingAudioCallScreen) {
      log(" <<<<<<<<<<<<<<<<<<<<<<<<< ${Get.currentRoute}");
      Get.back();
    }
  }

  /// caller call and receiver call answer then this event listen
  static void handleCallAnswered(dynamic data) {
    Utils.showLog("Socket Listen => callAnswered event: $data");

    final updatedUserCredits =
        data['remainingSessionCredits'] ?? data['updatedUserSessionCredits'];
    if (updatedUserCredits != null) {
      Database.onSetUserCoin(updatedUserCredits.toString());

      if (Get.isRegistered<HomeScreenController>()) {
        Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
      }
    }

    final updatedListenerBalance = data['updatedListenerCoinBalance'] ??
        data['updatedExpertEarningsBalance'];
    if (updatedListenerBalance != null) {
      Database.onSetListenerCoin(updatedListenerBalance.toString());

      if (Get.isRegistered<HostHomeScreenController>()) {
        Get.find<HostHomeScreenController>().update([Constant.idCoinUpdate]);
      }
    }

    if (Get.currentRoute == AppRoutes.voiceCallScreen ||
        Get.currentRoute == AppRoutes.videoCallScreen) {
      Utils.showLog("Call screen already open, skipping duplicate navigation.");
      return;
    }

    if (Get.currentRoute == AppRoutes.outgoingCallScreen ||
        Get.currentRoute == AppRoutes.incomingCallScreen ||
        Get.currentRoute == AppRoutes.outgoingAudioCallScreen) {
      Get.back();
    }

    // Utils.showToast(Get.context!, data['message']);
    // if (Get.isRegistered<OutgoingCallController>()) {
    Utils.showLog("ooooooooooooooooooooooooooo");

    if (data['callType'] == "audio") {
      // if (!Get.isRegistered<OutgoingCallController>()) {
      //   Get.put<OutgoingCallController>(OutgoingCallController());
      // }
      // final controller = Get.find<OutgoingCallController>();

      Utils.showLog("vvvvvvvvvvvvvvvvvvvvvvvvvv");

      Get.toNamed(AppRoutes.voiceCallScreen, arguments: {
        "callerId": data['callerId'],
        "receiverId": data['receiverId'],
        "callType": data['callType'],
        "callerRole": data['callerRole'],
        "receiverRole": data['receiverRole'],
        "callId": data['callId'],
        "receiverName": data['receiverName'],
        "callerfullName": data['callerfullName'],
        "callerName": data['callerName'],
        "receiverImage": data['receiverImage'],
        "callerImage": data['callerImage'],
        "isAccept": data['isAccept'],
        "callMode": data['callMode'],
        // "micMute": controller.micMute,
        // "micMute": controller.micMute,
        // "speakerOn": controller.isSpeakerOn,
      });
    } else {
      Get.toNamed(AppRoutes.videoCallScreen, arguments: data);
    }
    // }
  }

  /// when caller call then Invalid caller, receiver, or call history then listen this event
  static void handleCallResponseProcessed(dynamic data) {
    Utils.showLog("Socket Listen => callResponseProcessed event: $data");
    final message = data is Map
        ? (data['message']?.toString() ?? 'Call response processed.')
        : data.toString();
    Utils.showToast(Get.context, message);
  }

  /// if callId not match then listen also in callTimedOut ( to receiver )
  static void handleCallTimedOut(dynamic data) {
    Utils.showLog("Socket Listen => callTimedOut event: $data");
    // Utils.showToast(Get.context!, data['message']);
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
  }

  /// when caller cut call then this event listen
  // static void handleCallEnded(dynamic data) {
  //   Utils.showLog("Socket Listen => callEnded event: $data");
  //   if (Get.currentRoute == AppRoutes.incomingCallScreen) {
  //     log("***************************${Get.currentRoute == AppRoutes.incomingCallScreen}");
  //     Get.back();
  //   }
  // }

  /// when caller cut call then this event listen
  static void handleCallEnded(dynamic data) {
    Utils.showLog("Socket Listen => callEnded event: $data");

    // Dismiss call notification
    NotificationServices.dismissCallNotification();

    if (Get.currentRoute == AppRoutes.incomingCallScreen) {
      log("***************************${Get.currentRoute == AppRoutes.incomingCallScreen}");
      Get.back();
    }
  }

  /// if Invalid caller, receiver, or call history then listen also in callRejected event
  static void handleCallRejected(dynamic data) {
    Utils.showLog("Socket Listen => callRejected event: $data");
  }

  static Future<void> handleCallTerminated(dynamic data) async {
    UserCoinModel? userCoinModel;
    ListenerCoinModel? listenerCoinModel;
    Utils.showLog("Socket Listen => callTerminated event: $data");
    _reportSessionCallOutcomeIfNeeded(data, outcome: 'connected');
    VoiceCallController? voiceController;
    VideoCallController? videoController;
    if (Get.currentRoute == AppRoutes.voiceCallScreen) {
      if (Get.isRegistered<VoiceCallController>()) {
        voiceController = Get.find<VoiceCallController>();
      }
    } else if (Get.currentRoute == AppRoutes.videoCallScreen) {
      if (Get.isRegistered<VideoCallController>()) {
        videoController = Get.find<VideoCallController>();
      }
    }
    final callerRole = data['callerRole'];

    // ✅ First, properly cleanup proximity sensor and screen lock
    try {
      await ProximityScreenLock.setActive(false);
      voiceController?.isProximitySupported = false;
      voiceController?.isObjectNear = false;
      voiceController?.userEnabledSpeaker = false;
      log("✅ Proximity sensor deactivated and screen unlocked");
    } catch (e) {
      log("❌ Error deactivating proximity sensor: $e");
    }

    // ✅ Stop recording and upload BEFORE navigating away
    if (voiceController != null && voiceController.isRecordingActive) {
      try {
        await voiceController.stopRecordingAndUpload();
        log("✅ Voice recording stopped and uploaded from handleCallTerminated");
      } catch (e) {
        log("❌ Error stopping voice recording in handleCallTerminated: $e");
      }
    }
    if (videoController != null && videoController.isRecordingActive) {
      try {
        await videoController.stopRecordingAndUpload();
        log("✅ Video recording stopped and uploaded from handleCallTerminated");
      } catch (e) {
        log("❌ Error stopping video recording in handleCallTerminated: $e");
      }
    }

    if (Get.currentRoute == AppRoutes.videoCallScreen ||
        Get.currentRoute == AppRoutes.voiceCallScreen) {
      // Close any open overlays (anonymous mode panel, etc.) before navigating back
      while (Get.isOverlaysOpen) {
        Get.back();
      }
      Get.back();
    }

    if (Database.fetchLoginUserProfileModel?.user?.isListener == false &&
        callerRole == "user") {
      Get.toNamed(AppRoutes.callCutScreen, arguments: data);
    }

    userCoinModel = await UserCoinApi.callApi();
    if (userCoinModel?.status == true) {
      Database.onSetUserCoin((userCoinModel?.coin ?? 0).toString());
    }

    Utils.showLog(
        "user session credit listen ::::::::::::::::::${userCoinModel?.coin}");
    Utils.showLog(
        "user session credit listen ::::::::::::::::::${Database.userCoin}");

    if (Get.isRegistered<HostHomeScreenController>()) {
      final hostHomeScreenController = Get.find<HostHomeScreenController>();
      hostHomeScreenController.isCoinLoading = true;
      hostHomeScreenController.update([Constant.idCoinUpdate]);
      listenerCoinModel = await HostCoinApi.callApi();
      if (listenerCoinModel?.status == true) {
        Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
      }
      hostHomeScreenController.isCoinLoading = false;
      hostHomeScreenController.update([Constant.idCoinUpdate]);
    }

    if (Get.isRegistered<HomeScreenController>()) {
      Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
    }
  }

  static void handleNotEnoughCoins(dynamic data) {
    Utils.showLog("Socket Listen => handleNotEnoughSessionCredits: $data");
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
    if (Get.isRegistered<VoiceCallController>()) {
      final voiceCallController = Get.find<VoiceCallController>();

      SocketEmit.emitCallTerminated(
        callerId: voiceCallController.callerId.toString(),
        receiverId: voiceCallController.receiverId.toString(),
        callId: voiceCallController.callId.toString(),
        callType: voiceCallController.callType.toString(),
        callMode: voiceCallController.callMode.toString(),
        callerRole: voiceCallController.callerRole.toString(),
        receiverRole: voiceCallController.receiverRole.toString(),
        receiverName: voiceCallController.receiverName.toString(),
        receiverImage: voiceCallController.receiverImage.toString(),
      );
    }
    final errorMessage = data is Map
        ? (data['message']?.toString() ??
            "Insufficient session credits for this call.")
        : data.toString();

    Utils.showToast(Get.context, errorMessage);
  }

  /// if Invalid callerRole or receiverRole  or Caller, Receiver, or CallHistory not found then listen also in coinDeductionError
  static void handleCallCoinsDeducted(dynamic data) {
    Utils.showLog("Socket Listen => callSessionCreditsDeducted: $data");
    final message = data is Map
        ? (data['message']?.toString() ??
            'Session credits update could not be processed.')
        : data.toString();
    Utils.showToast(Get.context, message);
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
  }

  /// call cut data listen this event
  static void handleCallCutData(dynamic data) {
    try {
      Utils.showLog("Socket Listen => callCutData: $data");

      // Inject if not already present
      if (!Get.isRegistered<CallCutController>()) {
        Get.put(CallCutController());
      }

      Get.find<CallCutController>().setCallCutData(data);
    } catch (e, st) {
      Utils.showLog("❌ Error in handleCallCutData: $e\n$st");
    }
  }

  static void handleRequestRecordingConsent(dynamic data) {
    Utils.showLog("Socket Listen => handleRequestRecordingConsent: $data");
    if (Get.isRegistered<VoiceCallController>()) {
      Get.find<VoiceCallController>().onRequestRecordingConsent(data);
    }
    if (Get.isRegistered<VideoCallController>()) {
      Get.find<VideoCallController>().onRequestRecordingConsent(data);
    }
  }

  static void handleRecordingConsentResponse(dynamic data) {
    Utils.showLog("Socket Listen => handleRecordingConsentResponse: $data");
    if (Get.isRegistered<VoiceCallController>()) {
      Get.find<VoiceCallController>().onRecordingConsentResponse(data);
    }
    if (Get.isRegistered<VideoCallController>()) {
      Get.find<VideoCallController>().onRecordingConsentResponse(data);
    }
  }

  static void handleRecordingConsentDenied(dynamic data) {
    Utils.showLog("Socket Listen => handleRecordingConsentDenied: $data");
    if (Get.isRegistered<VoiceCallController>()) {
      Get.find<VoiceCallController>().onRecordingConsentResponse({'isAccepted': false, ...?data});
    }
    if (Get.isRegistered<VideoCallController>()) {
      Get.find<VideoCallController>().onRecordingConsentResponse({'isAccepted': false, ...?data});
    }
  }

  static void handleRecordingStarted(dynamic data) {
    Utils.showLog("Socket Listen => handleRecordingStarted: $data");
    if (Get.isRegistered<VoiceCallController>()) {
      Get.find<VoiceCallController>().onRecordingStarted(data);
    }
    if (Get.isRegistered<VideoCallController>()) {
      Get.find<VideoCallController>().onRecordingStarted(data);
    }
  }

  static void handleRecordingStopped(dynamic data) {
    Utils.showLog("Socket Listen => handleRecordingStopped: $data");
    if (Get.isRegistered<VoiceCallController>()) {
      Get.find<VoiceCallController>().onRecordingStopped(data);
    }
    if (Get.isRegistered<VideoCallController>()) {
      Get.find<VideoCallController>().onRecordingStopped(data);
    }
  }

  static void handleReportRecordingComplete(dynamic data) {
    Utils.showLog("Socket Listen => handleReportRecordingComplete: $data");
  }

  static void handleRecordingSaved(dynamic data) {
    Utils.showLog("Socket Listen => handleRecordingSaved: $data");
    if (Get.context != null) {
      Utils.showToast(Get.context!, "Recording saved successfully.");
    }
  }

  static void handleRecordingEligibilityError(dynamic data) {
    Utils.showLog("Socket Listen => handleRecordingEligibilityError: $data");
    final message = data?['message'] ?? "Recording is not available. Both participants need an active subscription.";
    if (Get.context != null) {
      Utils.showToast(Get.context!, message);
    }
    if (Get.isRegistered<VoiceCallController>()) {
      final ctrl = Get.find<VoiceCallController>();
      ctrl.isRecordingConsentPending = false;
      ctrl.update([Constant.idVideoCall]);
    }
    if (Get.isRegistered<VideoCallController>()) {
      final ctrl = Get.find<VideoCallController>();
      ctrl.isRecordingConsentPending = false;
      ctrl.update([Constant.idVideoCall]);
    }
  }
}

class CallCutDataStorage {
  static String? callId;
  static String? date;
  static String? balanceUsed;
  static String? duration;
}

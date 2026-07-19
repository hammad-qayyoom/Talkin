import 'package:get/get.dart';
import 'package:notisboard/socket/socket_listen.dart';
import 'package:notisboard/socket/socket_service.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/socket_events.dart';
import 'package:notisboard/utils/socket_params.dart';
import 'package:notisboard/utils/utils.dart';

class SocketEmit {
  static Future<bool> _ensureSocketReady() async {
    final connected = await SocketService.ensureConnected();
    if (!connected || socket == null || socket?.connected != true) {
      Utils.showLog("Socket Not Connected!!");
      if (Get.context != null) {
        Utils.showToast(
          Get.context,
          "Connection issue. Please check internet and try again.",
        );
      }
      return false;
    }
    SocketListen.registerListeners();
    return true;
  }

  static void sendMessage(Map<String, dynamic> message) {
    if (socket != null && socket?.connected == true) {
      socket?.emit(SocketEvents.sendMessage, message);
      Utils.showLog("Emitting message: $message");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  static void onMessageSeen(Map<String, dynamic> data) async {
    // final data = jsonEncode({
    //   SocketParams.messageId: messageId,
    //   SocketParams.senderId: senderId,
    // });

    if (socket != null && socket?.connected == true) {
      socket?.emit(SocketEvents.markMessageSeen, data);
      Utils.showLog("Socket Emit => Message Seen: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// private video & audio call button onTap first this event emit
  static Future<bool> emitCallOutgoingRinging({
    required String callerId,
    required String receiverId,
    required String callType,
    required String callerRole,
    required String receiverRole,
    required String receiverName,
    required String receiverImage,
    required String callerName,
    required String callerImage,
    String? sessionId,
    String? bookingId,
  }) async {
    final ready = await _ensureSocketReady();
    if (!ready) {
      return false;
    }

    final data = {
      SocketParams.callerId: callerId,
      SocketParams.receiverId: receiverId,
      SocketParams.callType: callType,
      SocketParams.callerRole: callerRole,
      SocketParams.receiverRole: receiverRole,
      SocketParams.receiverName: receiverName,
      SocketParams.receiverImage: receiverImage,
      SocketParams.callerName: callerName,
      SocketParams.callerImage: callerImage,
      if ((sessionId ?? '').trim().isNotEmpty)
        SocketParams.sessionId: sessionId,
      if ((bookingId ?? '').trim().isNotEmpty)
        SocketParams.bookingId: bookingId,
    };
    socket?.emit(SocketEvents.callOutgoingRinging, data);
    Utils.showLog("Socket Emit => callOutgoingRinging: $data");
    return true;
  }

  ///when caller accept call then this event  emit
  static Future<bool> emitCallResponseProcessed({
    required String callerId,
    required String receiverId,
    required String callId,
    required bool isAccept,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
    required String receiverName,
    required String receiverImage,
    required String callerName,
    required String callerImage,
    String? sessionId,
    String? bookingId,
  }) async {
    final ready = await _ensureSocketReady();
    if (!ready) {
      return false;
    }

    final data = {
      SocketParams.callerId: callerId,
      SocketParams.receiverId: receiverId,
      SocketParams.callType: callType,
      SocketParams.callerRole: callerRole,
      SocketParams.receiverRole: receiverRole,
      SocketParams.callId: callId,
      SocketParams.receiverName: receiverName,
      SocketParams.receiverImage: receiverImage,
      SocketParams.callerName: callerName,
      SocketParams.callerImage: callerImage,
      SocketParams.isAccept: isAccept,
      SocketParams.callMode: callMode,
      if ((sessionId ?? '').trim().isNotEmpty)
        SocketParams.sessionId: sessionId,
      if ((bookingId ?? '').trim().isNotEmpty)
        SocketParams.bookingId: bookingId,
    };
    socket!.emit(SocketEvents.callResponseProcessed, data);
    Utils.showLog("Socket Emit => callResponseProcessed: $data");
    return true;
  }

  /// when caller cut call then this event emit
  static void emitCallerCallCut({
    required String callerId,
    required String receiverId,
    required String callId,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
    String? sessionId,
    String? bookingId,
  }) {
    if (socket != null && socket!.connected) {
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callId: callId,
        SocketParams.callType: callType,
        SocketParams.callMode: callMode,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
        if ((sessionId ?? '').trim().isNotEmpty)
          SocketParams.sessionId: sessionId,
        if ((bookingId ?? '').trim().isNotEmpty)
          SocketParams.bookingId: bookingId,
      };
      socket!.emit(SocketEvents.callerCallCut, data);
      Utils.showLog("Socket Emit => callRejected: $data");
      // Get.toNamed(AppRoutes.callCutScreen);
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// join call both and cut call then emit this event
  static void emitCallTerminated({
    required String callerId,
    required String receiverId,
    required String callId,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
    required String receiverName,
    required String receiverImage,
    String? sessionId,
    String? bookingId,
  }) async {
    if (socket != null && socket!.connected) {
      UserCoinModel? userCoinModel;
      ListenerCoinModel? listenerCoinModel;
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callType: callType,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
        SocketParams.callId: callId,
        SocketParams.callMode: callMode,
        SocketParams.receiverName: receiverName,
        SocketParams.receiverImage: receiverImage,
        if ((sessionId ?? '').trim().isNotEmpty)
          SocketParams.sessionId: sessionId,
        if ((bookingId ?? '').trim().isNotEmpty)
          SocketParams.bookingId: bookingId,
      };
      socket!.emit(SocketEvents.callTerminated, data);
      userCoinModel = await UserCoinApi.callApi();
      if (userCoinModel?.status == true) {
        Database.onSetUserCoin((userCoinModel?.coin ?? 0).toString());
      }

      listenerCoinModel = await HostCoinApi.callApi();
      if (listenerCoinModel?.status == true) {
        Database.onSetListenerCoin((listenerCoinModel?.coin ?? 0).toString());
      }

      Utils.showLog(
          "user session credit emit ::::::::::::::::::::::::${Database.userCoin}");
      Utils.showLog(
          "user session credit emit ::::::::::::::::::::::::${userCoinModel?.coin.toString()}");

      Utils.showLog(
          "listener session credit emit ::::::::::::::::::::::::${Database.listenerCoin}");
      Utils.showLog(
          "listener session credit emit ::::::::::::::::::::::::${(listenerCoinModel?.coin ?? 0).toString()}");

      if (Get.isRegistered<HomeScreenController>()) {
        Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
      }
      // Get.find<VideoCallController>().update([Constant.idCoinUpdate]);

      Utils.showLog("Socket Emit => callTerminated: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// session credit deduction call
  static void callCoinsDeducted({
    required String callerId,
    required String receiverId,
    required String callId,
    required String callType,
    required String callMode,
    required String callerRole,
    required String receiverRole,
    // required String receiverName,
    // required String receiverImage,
    // required String callerName,
    // required String callerImage,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        SocketParams.callerId: callerId,
        SocketParams.receiverId: receiverId,
        SocketParams.callId: callId,
        SocketParams.callType: callType,
        SocketParams.callMode: callMode,
        SocketParams.callerRole: callerRole,
        SocketParams.receiverRole: receiverRole,
      };
      socket?.emit(SocketEvents.callCoinsDeducted, data);
      Utils.showLog(
          "Socket Emit => session credit deduction callCoinsDeducted: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  /// Recording mutual consent events
  static void emitRequestRecordingConsent({
    required String callId,
    required String callerId,
    required String receiverId,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        'callId': callId,
        'callerId': callerId,
        'receiverId': receiverId,
        'requesterId': Database.loginUserId,
      };
      socket?.emit(SocketEvents.requestRecordingConsent, data);
      Utils.showLog("Socket Emit => requestRecordingConsent: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  static void emitRecordingConsentResponse({
    required String callId,
    required String callerId,
    required String receiverId,
    required bool isAccepted,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        'callId': callId,
        'callerId': callerId,
        'receiverId': receiverId,
        'responderId': Database.loginUserId,
        'isAccepted': isAccepted,
      };
      socket?.emit(SocketEvents.recordingConsentResponse, data);
      Utils.showLog("Socket Emit => recordingConsentResponse: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  static void emitStopRecording({
    required String callId,
    required String callerId,
    required String receiverId,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        'callId': callId,
        'callerId': callerId,
        'receiverId': receiverId,
      };
      socket?.emit(SocketEvents.recordingStopped, data);
      Utils.showLog("Socket Emit => recordingStopped: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }

  static void emitReportRecordingComplete({
    required String callId,
    required String userId,
    required String expertId,
    required String callType,
    required String cloudStorageUrl,
    int fileSizeBytes = 0,
    int durationSeconds = 0,
    String? bookingId,
  }) {
    if (socket != null && socket?.connected == true) {
      final data = {
        'callId': callId,
        'userId': userId,
        'expertId': expertId,
        'callType': callType,
        'cloudStorageUrl': cloudStorageUrl,
        'fileSizeBytes': fileSizeBytes,
        'durationSeconds': durationSeconds,
        if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
      };
      socket?.emit(SocketEvents.reportRecordingComplete, data);
      Utils.showLog("Socket Emit => reportRecordingComplete: $data");
    } else {
      Utils.showLog("Socket Not Connected!!");
    }
  }
}

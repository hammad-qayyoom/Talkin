import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/socket/socket_service.dart';
import 'package:notisboard/ui/common/premium_content/purchase_request_sheet.dart';
import 'package:notisboard/utils/socket_events.dart';
import 'package:notisboard/utils/utils.dart';

class PremiumContentSocketHandler {
  static final PremiumContentSocketHandler _instance = PremiumContentSocketHandler._internal();
  factory PremiumContentSocketHandler() => _instance;
  PremiumContentSocketHandler._internal();

  Function(Map<String, dynamic>)? onPurchaseRequestReceived;
  Function(Map<String, dynamic>)? onPurchaseRequestSent;
  Function(Map<String, dynamic>)? onPurchaseCompleted;
  Function(Map<String, dynamic>)? onPurchaseFailed;
  Function(Map<String, dynamic>)? onPurchaseDeclined;

  bool _listenersRegistered = false;

  void registerListeners() {
    if (_listenersRegistered) return;
    _listenersRegistered = true;

    socket?.on(SocketEvents.purchaseRequestReceived, _handlePurchaseRequestReceived);
    socket?.on(SocketEvents.purchaseRequestSent, _handlePurchaseRequestSent);
    socket?.on(SocketEvents.purchaseCompleted, _handlePurchaseCompleted);
    socket?.on(SocketEvents.purchaseFailed, _handlePurchaseFailed);
    socket?.on(SocketEvents.purchaseDeclined, _handlePurchaseDeclined);

    Utils.showLog("[PremiumContent] Socket listeners registered");
  }

  void unregisterListeners() {
    socket?.off(SocketEvents.purchaseRequestReceived, _handlePurchaseRequestReceived);
    socket?.off(SocketEvents.purchaseRequestSent, _handlePurchaseRequestSent);
    socket?.off(SocketEvents.purchaseCompleted, _handlePurchaseCompleted);
    socket?.off(SocketEvents.purchaseFailed, _handlePurchaseFailed);
    socket?.off(SocketEvents.purchaseDeclined, _handlePurchaseDeclined);
    _listenersRegistered = false;
    Utils.showLog("[PremiumContent] Socket listeners unregistered");
  }

  void _handlePurchaseRequestReceived(dynamic data) {
    Utils.showLog("[PremiumContent] Purchase request received: $data");
    Map<String, dynamic>? mapData;
    if (data is Map) {
      mapData = Map<String, dynamic>.from(data);
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      mapData = Map<String, dynamic>.from(data.first);
    }

    if (mapData != null) {
      final requestData = mapData;
      onPurchaseRequestReceived?.call(requestData);
      if (Get.context != null) {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PurchaseRequestSheet(requestData: requestData),
        );
      }
    }
  }

  void _handlePurchaseRequestSent(dynamic data) {
    Utils.showLog("[PremiumContent] Purchase request sent confirmation: $data");
    Map<String, dynamic>? mapData;
    if (data is Map) {
      mapData = Map<String, dynamic>.from(data);
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      mapData = Map<String, dynamic>.from(data.first);
    }

    if (mapData != null) {
      onPurchaseRequestSent?.call(mapData);
      if (Get.context != null) {
        Utils.showToast(Get.context!, "Purchase request sent to user.");
      }
    }
  }

  void _handlePurchaseCompleted(dynamic data) {
    Utils.showLog("[PremiumContent] Purchase completed: $data");
    Map<String, dynamic>? mapData;
    if (data is Map) {
      mapData = Map<String, dynamic>.from(data);
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      mapData = Map<String, dynamic>.from(data.first);
    }

    if (mapData != null) {
      onPurchaseCompleted?.call(mapData);
      if (Get.context != null) {
        Utils.showToast(Get.context!, "Payment successful! Content downloaded.");
      }
    }
  }

  void _handlePurchaseFailed(dynamic data) {
    Utils.showLog("[PremiumContent] Purchase failed: $data");
    Map<String, dynamic>? mapData;
    if (data is Map) {
      mapData = Map<String, dynamic>.from(data);
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      mapData = Map<String, dynamic>.from(data.first);
    }

    if (mapData != null) {
      onPurchaseFailed?.call(mapData);
      if (Get.context != null) {
        final message = mapData['reason']?.toString() ?? mapData['message']?.toString() ?? "Purchase failed.";
        Utils.showToast(Get.context!, message);
      }
    }
  }

  void _handlePurchaseDeclined(dynamic data) {
    Utils.showLog("[PremiumContent] Purchase declined: $data");
    Map<String, dynamic>? mapData;
    if (data is Map) {
      mapData = Map<String, dynamic>.from(data);
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      mapData = Map<String, dynamic>.from(data.first);
    }

    if (mapData != null) {
      onPurchaseDeclined?.call(mapData);
      if (Get.context != null) {
        Utils.showToast(Get.context!, "Purchase declined by user.");
      }
    }
  }

  // ─── Emit Methods ───

  static void sendPurchaseRequest({
    required String sessionId,
    required String contentId,
    int? customPrice,
  }) {
    if (socket != null) {
      final data = <String, dynamic>{
        'sessionId': sessionId,
        'contentId': contentId,
      };
      if (customPrice != null) data['customPrice'] = customPrice;
      socket?.emit(SocketEvents.sendPurchaseRequest, data);
      Utils.showLog("[PremiumContent] Emitted sendPurchaseRequest");
    }
  }

  static void acceptPurchaseRequest(String purchaseId) {
    if (socket != null) {
      socket?.emit(SocketEvents.acceptPurchaseRequest, {
        'purchaseId': purchaseId,
      });
      Utils.showLog("[PremiumContent] Emitted acceptPurchaseRequest");
    }
  }

  static void declinePurchaseRequest(String purchaseId) {
    if (socket != null) {
      socket?.emit(SocketEvents.declinePurchaseRequest, {
        'purchaseId': purchaseId,
      });
      Utils.showLog("[PremiumContent] Emitted declinePurchaseRequest");
    }
  }
}

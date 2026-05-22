import 'dart:developer';
import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

io.Socket? socket;

class SocketService {
  static String? _activeSocketUserId;
  static Future<bool>? _pendingEnsureConnection;

  io.Socket? getSocket() => socket;

  static String _resolveSocketUserId() {
    final isListener =
        Database.fetchLoginUserProfileModel?.user?.isListener == true;
    if (!isListener) {
      return Database.loginUserId.trim();
    }

    final candidates = <String>[
      (Database.fetchListenerProfileModel?.data?.id ?? '').toString().trim(),
      (Database.fetchLoginUserProfileModel?.user?.listenerId ?? '')
          .toString()
          .trim(),
      Database.loginListenerId.trim(),
      Database.loginUserId.trim(),
    ];

    for (final candidate in candidates) {
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }

    return '';
  }

  static Future<void> socketDisConnect() async {
    socket?.disconnect();
    _activeSocketUserId = null;
    socket?.onDisconnect(
      (data) => Utils.showLog(
          "Socket Listen => Socket Disconnected Called : ${socket?.id}"),
    );
  }

  static Future<void> socketConnect() async {
    log("listener id :::::: ${Database.fetchListenerProfileModel?.data?.id}");
    log("user id :::::: ${Database.loginUserId}");

    try {
      final socketUserId = _resolveSocketUserId();

      if (socketUserId.trim().isEmpty) {
        Utils.showLog("Socket connect skipped: empty socket user id.");
        return;
      }

      final alreadyForSameUser = _activeSocketUserId == socketUserId;
      if (alreadyForSameUser && socket != null) {
        if (socket!.connected) {
          Utils.showLog("Socket already connected for user: $socketUserId");
          return;
        }

        socket!.connect();
        Utils.showLog("Socket reconnect requested for user: $socketUserId");
        return;
      }

      // Reset stale socket when identity changes.
      if (socket != null && _activeSocketUserId != socketUserId) {
        try {
          socket?.disconnect();
          socket?.dispose();
        } catch (_) {}
      }

      socket = io.io(
        Api.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(12)
            .setReconnectionDelay(800)
            .setReconnectionDelayMax(4000)
            .setTimeout(12000)
            .setQuery({
              "globalRoom": "globalRoom:$socketUserId",
            })
            .build(),
      );
      _activeSocketUserId = socketUserId;

      socket?.connect();

      socket?.onConnect((_) {
        Utils.showLog("Socket Listen => Socket Connected : ${socket?.id}");
      });

      socket?.on("error", (error) {
        Utils.showLog("Socket Listen => Socket Error : $error");
      });

      socket?.on("connect_error", (error) {
        Utils.showLog("Socket Listen => Socket Connection Error : $error");
      });

      socket?.on("connect_timeout", (timeout) {
        Utils.showLog("Socket Listen => Socket Connection Timeout : $timeout");
      });

      socket?.on("disconnect", (reason) {
        Utils.showLog("Socket Listen => Socket Disconnected : $reason");
      });

      Utils.showLog("Socket Listen => Socket Connected : ${socket?.connected}");
    } catch (e) {
      Utils.showLog("Socket Listen => Socket Connection Error: $e");
    }
  }

  static Future<bool> ensureConnected({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final targetSocketUserId = _resolveSocketUserId();
    final socketIdentityChanged = targetSocketUserId.isNotEmpty &&
        _activeSocketUserId != targetSocketUserId;

    if (socket != null && socket!.connected && !socketIdentityChanged) {
      return true;
    }

    if (_pendingEnsureConnection != null) {
      return _pendingEnsureConnection!;
    }

    final completer = Completer<bool>();
    _pendingEnsureConnection = completer.future;

    try {
      await socketConnect();

      if (socket != null && socket!.connected) {
        completer.complete(true);
        return true;
      }

      if (socket == null) {
        completer.complete(false);
        return false;
      }

      void onConnect(dynamic _) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }

      void onConnectError(dynamic error) {
        Utils.showLog("Socket ensureConnected error: $error");
      }

      socket!.on('connect', onConnect);
      socket!.on('connect_error', onConnectError);
      socket!.on('connect_timeout', onConnectError);

      socket!.connect();

      final isConnected = await completer.future
          .timeout(timeout, onTimeout: () => socket?.connected == true);

      socket!.off('connect', onConnect);
      socket!.off('connect_error', onConnectError);
      socket!.off('connect_timeout', onConnectError);

      return isConnected;
    } catch (error) {
      Utils.showLog("Socket ensureConnected failed: $error");
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return false;
    } finally {
      _pendingEnsureConnection = null;
    }
  }
}

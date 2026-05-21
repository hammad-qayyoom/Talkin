library;

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notisboard/firebase_options.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/dialog/app_restart_dialog.dart';
import 'package:notisboard/main.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/permission_handler/permission_handler.dart';
import 'package:notisboard/socket/socket_emit.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';

class NotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static void _navigateWhenAppReady(Map<String, dynamic> data) {
    Future<void>(() async {
      for (int i = 0; i < 10; i++) {
        if (Get.context != null || Get.key.currentContext != null) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }

      if (Get.context == null && Get.key.currentContext == null) {
        Utils.showLog(
          "Notification navigation skipped: app navigator context unavailable.",
        );
        return;
      }

      onHandleNotificationNavigation(data);
    });
  }

  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call Channel',
          channelDescription: 'Channel for incoming call notifications',
          defaultColor: Colors.green,
          importance: NotificationImportance.Max,
          locked: true,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Channel',
          channelDescription: 'Channel for chat notifications',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onAwesomeNotificationActionReceived,
    );

    await messaging.setAutoInitEnabled(true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onAwesomeNotificationActionReceived(
    ReceivedAction receivedAction,
  ) async {
    Utils.showLog(
      "Awesome notification action received: ${receivedAction.buttonKeyPressed}",
    );

    if (receivedAction.payload == null || receivedAction.payload!.isEmpty) {
      return;
    }

    final data = receivedAction.payload!;

    if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      await AwesomeNotifications().dismiss(receivedAction.id!);
      _navigateWhenAppReady(data);

      PermissionHandler.onGetCameraPermission(
        onGranted: () {
          PermissionHandler.onGetMicrophonePermission(
            onGranted: () async {
              SocketEmit.emitCallResponseProcessed(
                callerId: data['callerId']!,
                receiverId: data['receiverId']!,
                callId: data['callId']!,
                isAccept: true,
                callType: data['callType'] ?? 'audio',
                callMode: data['callMode'] ?? 'private',
                callerRole: data['callerRole'] ?? '',
                receiverRole: data['receiverRole'] ?? '',
                receiverName: data['receiverName'] ?? '',
                receiverImage: data['receiverImage'] ?? '',
                callerName: data['callerfullName'] ?? '',
                callerImage: data['callerImage'] ?? '',
              );
            },
          );
        },
      );
      return;
    }

    if (receivedAction.buttonKeyPressed == 'DECLINE') {
      await AwesomeNotifications().dismiss(receivedAction.id!);
      SocketEmit.emitCallResponseProcessed(
        callerId: data['callerId']!,
        receiverId: data['receiverId']!,
        callId: data['callId']!,
        isAccept: false,
        callType: data['callType'] ?? 'audio',
        callMode: data['callMode'] ?? 'private',
        callerRole: data['callerRole'] ?? '',
        receiverRole: data['receiverRole'] ?? '',
        receiverName: data['receiverName'] ?? '',
        receiverImage: data['receiverImage'] ?? '',
        callerName: data['callerfullName'] ?? '',
        callerImage: data['callerImage'] ?? '',
      );
      return;
    }

    Utils.showLog("handle notification navigation");
    _navigateWhenAppReady(data);
  }

  static void onHandleNotificationNavigation(Map<String, dynamic> data) {
    if (data["type"] == "CHAT") {
      if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
        Get.toNamed(
          AppRoutes.personalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
            data['ratePrivateAudioCall'],
            data['ratePrivateVideoCall'],
            data['isFake'] ?? false,
            data['video'],
            data['isAvailableForPrivateVideoCall'],
            data['isAvailableForPrivateAudioCall'],
          ],
        );
      } else {
        Get.toNamed(
          AppRoutes.hostPersonalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
          ],
        );
      }
      return;
    }

    if (data["type"] == "missed_call") {
      Get.toNamed(AppRoutes.profileDetailScreenView,
          arguments: data['callerId']);
      return;
    }

    if (data["type"] == "callIncoming") {
      if (Get.currentRoute == AppRoutes.incomingCallScreen) {
        return;
      }

      Get.toNamed(
        AppRoutes.incomingCallScreen,
        arguments: {
          'callerId': data['callerId'],
          'receiverId': data['receiverId'],
          'callerImage': data['callerImage'],
          'callernickName': data['callernickName'],
          'callerfullName': data['callerfullName'],
          'receiverName': data['receiverName'],
          'receiverImage': data['receiverImage'],
          'callId': data['callId'],
          'receiverRole': data['receiverRole'],
          'callMode': data['callMode'],
          'callType': data['callType'],
          'callerRole': data['callerRole'],
          'sessionId': data['sessionId'],
          'bookingId': data['bookingId'],
          'channel': data['channel'],
        },
      );
    }
  }

  static Future<void> showAwesomeNotification(RemoteMessage message) async {
    Utils.showLog("show awesome notification AAA");

    final String type = message.data['type'] ?? '';
    String channelKey = 'chat_channel';
    NotificationCategory category = NotificationCategory.Message;
    List<NotificationActionButton> actions = [];

    if (currentAppLifecycleState != AppLifecycleState.resumed &&
        type == 'callIncoming') {
      channelKey = 'call_channel';
      category = NotificationCategory.Call;
      actions = [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'Accept',
          color: Colors.green,
        ),
        NotificationActionButton(
          key: 'DECLINE',
          label: 'Decline',
          color: Colors.red,
        ),
      ];
    }

    final randomNumber = Random();
    final resultOne = randomNumber.nextInt(2000);
    var resultTwo = randomNumber.nextInt(100);
    if (resultTwo >= resultOne) {
      resultTwo += 1;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: resultTwo,
        channelKey: channelKey,
        title: message.data['title'] ??
            message.notification?.title ??
            'Notification',
        body: message.data['body'] ??
            message.notification?.body ??
            'You have a new message',
        category: category,
        icon: 'resource://mipmap/ic_notification',
        payload:
            message.data.map((k, v) => MapEntry(k.toString(), v.toString())),
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: channelKey == 'call_channel',
        fullScreenIntent: channelKey == 'call_channel',
        criticalAlert: channelKey == 'call_channel',
        autoDismissible: channelKey != 'call_channel',
        locked: channelKey == 'call_channel',
        timeoutAfter:
            channelKey == 'call_channel' ? const Duration(seconds: 45) : null,
      ),
      actionButtons: actions,
    );
  }

  static Future<void> firebaseInit() async {
    Utils.showLog("notification firebase init");

    FirebaseMessaging.onMessage.listen((message) {
      Utils.showLog(
          "Notification service firebase init => $currentAppLifecycleState");
      Utils.showLog("Notification AAA => ${message.data}");
      Utils.showLog("Notification => ${message.data["type"]}");

      if (currentAppLifecycleState == AppLifecycleState.resumed) {
        if ((Get.currentRoute == AppRoutes.personalChatScreen ||
                Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
            message.data["type"] == "CHAT") {
          Utils.showLog(
              "User is already on a chat screen. Suppressing notification.");
        } else if (message.data['type'] == 'expert_verified') {
          Get.dialog(
            barrierDismissible: false,
            barrierColor: AppColors.black.withValues(alpha: 0.8),
            Dialog(
              backgroundColor: AppColors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              child: const AppRestartDialog(),
            ),
          );
        } else if (message.data['type'] != "callIncoming") {
          showAwesomeNotification(message);
        }
      } else if (currentAppLifecycleState == AppLifecycleState.paused) {
        if (message.data['type'] != "callIncoming") {
          showAwesomeNotification(message);
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(backgroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Utils.showLog("App opened from notification: ${message.data}");
      _navigateWhenAppReady(message.data);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Utils.showLog(
        "App launched from terminated state notification: ${initialMessage.data}",
      );
      _navigateWhenAppReady(initialMessage.data);
    }
  }

  static Future<void> dismissCallNotification() async {
    try {
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey('call_channel');
      Utils.showLog("✅ Call notifications dismissed successfully");
    } catch (e) {
      Utils.showLog("❌ Error dismissing call notifications: $e");
    }
  }
}

@pragma('vm:entry-point')
Future<void> backgroundNotification(RemoteMessage message) async {
  Utils.showLog("background notification AAA");
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {}
  await NotificationServices.showAwesomeNotification(message);
}

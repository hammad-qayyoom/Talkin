import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/utils.dart';

class PermissionHandler {
  static Future<void> notificationPermissions() async {
    await Permission.notification.request();
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
  }

  static Future<void> microphonePermissions() async {
    await Permission.notification.request();
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
  }

  static Future<void> onGetCameraPermission({
    required Callback onGranted,
    Callback? onDenied,
  }) async {
    try {
      PermissionStatus status = await Permission.camera.request();

      if (status == PermissionStatus.granted) {
        log("Camera Permission Granted");
        onGranted.call();
        return;
      }

      if (status == PermissionStatus.denied ||
          status == PermissionStatus.restricted) {
        Utils.showToast(Get.context, "Please allow camera permission.");
        onDenied?.call();
      } else if (status == PermissionStatus.permanentlyDenied ||
          status == PermissionStatus.limited) {
        _showSettingsDialog("Camera permission is required. Please enable it in App Settings.");
        onDenied?.call();
      } else {
        onDenied?.call();
      }
    } catch (e) {
      Utils.showToast(
        Get.context,
        "Camera permission check failed. Please try again.",
      );
      onDenied?.call();
      log("Camera Permission Failed => $e");
    }
  }

  static Future<void> onGetMicrophonePermission({
    required Callback onGranted,
    Callback? onDenied,
  }) async {
    try {
      PermissionStatus status = await Permission.microphone.request();

      if (status == PermissionStatus.granted) {
        log("microphone Permission Granted");
        onGranted.call();
        return;
      }

      if (status == PermissionStatus.denied ||
          status == PermissionStatus.restricted) {
        Utils.showToast(Get.context, "Please allow microphone permission.");
        onDenied?.call();
      } else if (status == PermissionStatus.permanentlyDenied ||
          status == PermissionStatus.limited) {
        _showSettingsDialog("Microphone permission is required. Please enable it in App Settings.");
        onDenied?.call();
      } else {
        onDenied?.call();
      }
    } catch (e) {
      Utils.showToast(
        Get.context,
        "Microphone permission check failed. Please try again.",
      );
      onDenied?.call();
      log("microphone Permission Failed => $e");
    }
  }

  // static Future<void> cameraPermissions() async {
  //   await Permission.camera.request();
  //   await Permission.camera.isDenied.then((value) {
  //     if (value) {
  //       Permission.camera.request();
  //     }
  //   });
  // }

  static Future<void> storagePermissions() async {
    await Permission.storage.request();
    await Permission.storage.isDenied.then((value) {
      if (value) {
        Permission.storage.request();
      }
    });
  }

  static void _showSettingsDialog(String message) {
    if (Get.context == null) return;
    Get.defaultDialog(
      title: "Permission Required",
      middleText: message,
      textConfirm: "Open Settings",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        openAppSettings();
      },
      onCancel: () {},
    );
  }
}

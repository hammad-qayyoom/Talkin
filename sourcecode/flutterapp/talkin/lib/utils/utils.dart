import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:clipboard/clipboard.dart';

import 'app_color.dart';

class Utils {
  static const sandboxVerifyReceiptUrl = false;

  static RxBool isAppOpen = false.obs;
  static String? playStoreId = "com.notisboard.mobile";
  static String? appStoreId = "6747668315";

  // /// =================== Toast =================== ///
  // static showToast(BuildContext context, String msg, {ToastGravity gravity = ToastGravity.BOTTOM}) {
  //   return Fluttertoast.showToast(
  //     msg: msg,
  //     toastLength: Toast.LENGTH_LONG,
  //     gravity: gravity,
  //     backgroundColor: AppColors.appColor,
  //     textColor: AppColors.white,
  //     fontSize: 15,
  //   );
  // }

  /// =================== Toast =================== ///
  static showToast(
    BuildContext? context,
    String msg, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_LONG, // default to 2 sec
  }) {
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: AppColors.appColor,
      textColor: AppColors.white,
      fontSize: 15,
    );
  }

  /// =================== Current Focus Node =================== ///
  static currentFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  static String formatDateToApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatShortDate(DateTime date) {
    return "${date.day}/${date.month}";
  }
  // /// =================== Lunch URL =================== ///
  // static Future<void> launchURL(String value) async {
  //   var url = Uri.parse(value);
  //   if (await canLaunchUrl(url)) {
  //     launchUrl(url);
  //   } else {
  //     Utils.showToast(Get.context!, "Web page can't loaded");
  //     throw "Cannot load the page";
  //   }
  // }

  // /// =================== Clipboard (Copy Text) =================== ///
  // static copyText(String text) {
  //   FlutterClipboard.copy(text);
  // }

  /// =================== Console Log =================== ///
  static showLog(String text) {
    debugPrint(text);
  }

  // static void showLoading({String? message}) {
  //   Get.dialog(
  //     WillPopScope(
  //       onWillPop: () async => false,
  //       child: Center(
  //         child: CircularProgressIndicator(),
  //       ),
  //     ),
  //     barrierDismissible: false,
  //   );
  // }

  // static void hideLoading() {
  //   if (Get.isDialogOpen!) {
  //     Get.back();
  //   }
  // }

  static void onChangeStatusBar({
    required Brightness brightness,
    int? delay,
  }) {
    showLog("Change Status Bar => Brightness => $brightness => $delay");
    Future.delayed(
      Duration(milliseconds: delay ?? 0),
      () => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: brightness,
        ),
      ),
    );
  }

  /// =================== Clipboard (Copy Text) =================== ///
  static copyText(String text) {
    FlutterClipboard.copy(text);
  }

  static void showConfirmationSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = 'Cancel',
    IconData icon = Icons.info_outline_rounded,
    Color? confirmBackgroundColor,
    Duration duration = const Duration(seconds: 6),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final laneWidth = screenWidth >= 760 ? 860.0 : screenWidth;
    final sideInset =
        ((screenWidth - laneWidth) / 2).clamp(0.0, double.infinity).toDouble();
    final bottomPadding = MediaQuery.of(context).padding.bottom + 8;
    final resolvedConfirmColor =
        confirmBackgroundColor ?? AppColors.redesignBrandDark;
    final resolvedAccent = resolvedConfirmColor == AppColors.redesignBrandDark
        ? AppColors.redesignBrandRed
        : resolvedConfirmColor;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        duration: duration,
        margin: EdgeInsets.fromLTRB(
          sideInset + 14,
          0,
          sideInset + 14,
          bottomPadding,
        ),
        content: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: resolvedAccent.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 21,
                      color: resolvedAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.redesignBrandDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.redesignMutedText,
                            height: 1.28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: AppColors.redesignBrandDark,
                        backgroundColor: AppColors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: resolvedConfirmColor,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showInfoSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.info_outline_rounded,
    String actionText = 'OK',
    VoidCallback? onAction,
    Color? accentColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final laneWidth = screenWidth >= 760 ? 860.0 : screenWidth;
    final sideInset =
        ((screenWidth - laneWidth) / 2).clamp(0.0, double.infinity).toDouble();
    final bottomPadding = MediaQuery.of(context).padding.bottom + 8;
    final resolvedAccent = accentColor ?? AppColors.redesignBrandRed;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        duration: duration,
        margin: EdgeInsets.fromLTRB(
          sideInset + 14,
          0,
          sideInset + 14,
          bottomPadding,
        ),
        content: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: resolvedAccent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 21,
                      color: resolvedAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.redesignBrandDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.redesignMutedText,
                            height: 1.28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: onAction == null
                    ? ElevatedButton(
                        onPressed: messenger.hideCurrentSnackBar,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: resolvedAccent,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          actionText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: messenger.hideCurrentSnackBar,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                side: BorderSide(
                                    color: AppColors.redesignSoftBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                foregroundColor: AppColors.redesignBrandDark,
                                backgroundColor: AppColors.white,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                messenger.hideCurrentSnackBar();
                                onAction.call();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: const Size.fromHeight(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: resolvedAccent,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                actionText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension HeightExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
}

extension WidthExtension on num {
  SizedBox get width => SizedBox(width: toDouble());
}

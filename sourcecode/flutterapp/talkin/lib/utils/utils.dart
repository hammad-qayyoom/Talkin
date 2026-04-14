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
  static String? playStoreId = "com.incodes.talkin";
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
    BuildContext context,
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

    final bottomPadding = MediaQuery.of(context).padding.bottom + 12;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        margin: EdgeInsets.fromLTRB(14, 0, 14, bottomPadding),
        content: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 10),
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
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: AppColors.redesignAccentSoftBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: AppColors.redesignBrandRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.redesignBrandDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.redesignMutedText,
                            height: 1.35,
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
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          messenger.hideCurrentSnackBar();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.redesignSoftBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          messenger.hideCurrentSnackBar();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: confirmBackgroundColor ??
                              AppColors.redesignBrandDark,
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
                  ),
                ],
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

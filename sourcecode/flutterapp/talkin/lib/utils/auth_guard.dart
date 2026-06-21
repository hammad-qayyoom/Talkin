import 'package:notisboard/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';

class AuthGuard {
  static bool get hasAuthenticatedAccount =>
      Database.isLogin &&
      Database.loginUserFirebaseId.trim().isNotEmpty &&
      Database.loginUserId.trim().isNotEmpty;

  static bool get isGuest => !hasAuthenticatedAccount;

  static bool requireLogin({
    String message = 'Please log in to continue.',
  }) {
    if (!isGuest) {
      return true;
    }

    showLoginPrompt(message: message);
    return false;
  }

  static Future<void> showLoginPrompt({
    String message = 'Please log in to continue.',
  }) async {
    if (Get.isDialogOpen == true) {
      return;
    }

    final context = Get.context;
    if (context == null) {
      Get.toNamed(AppRoutes.main);
      return;
    }

    await Get.dialog<void>(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: LayoutBuilder(
          builder: (context, _) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            final isTablet = screenWidth >= 760;
            final maxDialogWidth = screenWidth >= 1200 ? 560.0 : 500.0;
            final horizontalPadding = isTablet ? 22.0 : 20.0;
            final titleSize = isTablet ? 20.0 : 18.0;
            final bodySize = isTablet ? 14.0 : 13.0;
            final buttonFontSize = isTablet ? 15.0 : 14.0;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxDialogWidth,
                minWidth: isTablet ? 420 : 280,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  18,
                  horizontalPadding,
                  16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: AppColors.redesignAccentSoftBg,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.redesignBrandRed,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            EnumLocale.txtLoginRequired.name.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: titleSize,
                              fontColor: AppColors.redesignBrandDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: bodySize,
                        fontColor: AppColors.redesignMutedText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: Get.back,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.redesignSoftBorder),
                              foregroundColor: AppColors.redesignBrandDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              EnumLocale.txtNotNow.name.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: buttonFontSize,
                                fontColor: AppColors.redesignBrandDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.toNamed(AppRoutes.main);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.redesignBrandDark,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              EnumLocale.txtLogin.name.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: buttonFontSize,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: true,
    );
  }
}

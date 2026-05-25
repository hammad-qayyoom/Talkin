import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReviewService {
  AppReviewService._();

  static final GetStorage _box = GetStorage();
  static final InAppReview _inAppReview = InAppReview.instance;

  static const String _kCompletedActionCount = 'app_review_completed_action_count';
  static const String _kLastPromptAt = 'app_review_last_prompt_at';
  static const String _kIsPermanentlyDismissed = 'app_review_is_permanently_dismissed';
  static const String _kHasRated = 'app_review_has_rated';

  static const int _minActionsBeforePrompt = 1;
  static const int _coolDownDays = 14;

  static Future<void> trackPositiveAction({required String source}) async {
    if (_isOptedOut) {
      Utils.showLog('ReviewPrompt skipped($source): user opted out/rated.');
      return;
    }

    final actions = (_box.read(_kCompletedActionCount) ?? 0) as int;
    final next = actions + 1;
    await _box.write(_kCompletedActionCount, next);
    Utils.showLog('ReviewPrompt action tracked($source): $next');

    if (!await _canShowPrompt()) return;
    await _showReviewPrompt();
  }

  static bool get _isOptedOut =>
      (_box.read(_kIsPermanentlyDismissed) ?? false) == true ||
      (_box.read(_kHasRated) ?? false) == true;

  static Future<bool> _canShowPrompt() async {
    if (_isOptedOut) return false;

    final actions = (_box.read(_kCompletedActionCount) ?? 0) as int;
    if (actions < _minActionsBeforePrompt) {
      return false;
    }

    final lastPromptEpoch = (_box.read(_kLastPromptAt) ?? 0) as int;
    if (lastPromptEpoch <= 0) return true;

    final lastPrompt = DateTime.fromMillisecondsSinceEpoch(lastPromptEpoch);
    final nextAllowed = lastPrompt.add(const Duration(days: _coolDownDays));
    return DateTime.now().isAfter(nextAllowed);
  }

  static Future<void> _showReviewPrompt() async {
    await _box.write(_kLastPromptAt, DateTime.now().millisecondsSinceEpoch);

    if (Get.isDialogOpen == true) {
      return;
    }

    await Get.dialog<void>(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enjoying Notisboard?',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please take a moment to rate us. Your feedback helps us improve.',
                style: AppFontStyle.fontStyleW500(
                  fontSize: 14,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _textActionButton(
                      label: 'No Thanks',
                      onTap: () async {
                        await _box.write(_kIsPermanentlyDismissed, true);
                        Get.back();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _textActionButton(
                      label: 'Maybe Later',
                      onTap: Get.back,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redesignBrandDark,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Get.back();
                    await _requestNativeOrFallback();
                  },
                  child: Text(
                    'Rate Now',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 15,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static Widget _textActionButton({required String label, required VoidCallback onTap}) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: AppFontStyle.fontStyleW600(
          fontSize: 14,
          fontColor: AppColors.redesignMutedText,
        ),
      ),
    );
  }

  static Future<void> _requestNativeOrFallback() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        await _inAppReview.requestReview();
        await _box.write(_kHasRated, true);
        Utils.showLog('ReviewPrompt native dialog requested successfully.');
        return;
      }

      await _openStoreListing();
      await _box.write(_kHasRated, true);
    } catch (e) {
      Utils.showLog('ReviewPrompt failed: $e');
      await _openStoreListing();
    }
  }

  static Future<void> _openStoreListing() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.openStoreListing();
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;

    if (Platform.isAndroid) {
      var uri = Uri.parse('market://details?id=$packageName');
      var launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        uri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        Utils.showToast(Get.context, 'Unable to open store review page right now.');
      }
      return;
    }

    Utils.showToast(Get.context, 'Unable to open store review page right now.');
  }
}

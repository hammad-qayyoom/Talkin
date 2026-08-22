import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateDialog extends StatefulWidget {
  final bool isForceUpdate;
  final String? customTitle;
  final String? customMessage;
  final String? customButtonText;
  final String? customSkipText;
  final String? targetVersion;
  final VoidCallback? onSkip;

  const AppUpdateDialog({
    super.key,
    this.isForceUpdate = false,
    this.customTitle,
    this.customMessage,
    this.customButtonText,
    this.customSkipText,
    this.targetVersion,
    this.onSkip,
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.customTitle != null && widget.customTitle!.trim().isNotEmpty) {
      return widget.customTitle!.trim();
    }
    final apiTitle = Database.settingApiModel?.data?.updateDialogTitle;
    if (apiTitle != null && apiTitle.trim().isNotEmpty) {
      return apiTitle.trim();
    }
    return EnumLocale.txtUpdateRequired.name.tr;
  }

  String get _message {
    if (widget.customMessage != null && widget.customMessage!.trim().isNotEmpty) {
      return widget.customMessage!.trim();
    }
    final apiMessage = Database.settingApiModel?.data?.updateDialogMessage;
    if (apiMessage != null && apiMessage.trim().isNotEmpty) {
      return apiMessage.trim();
    }
    return EnumLocale
        .txtPleaseUpdateToTheLatestVersionToContinueUsingTheAppWithNewFe.name.tr;
  }

  String get _buttonText {
    if (widget.customButtonText != null &&
        widget.customButtonText!.trim().isNotEmpty) {
      return widget.customButtonText!.trim();
    }
    final apiButton = Database.settingApiModel?.data?.updateDialogButtonText;
    if (apiButton != null && apiButton.trim().isNotEmpty) {
      return apiButton.trim();
    }
    return EnumLocale.txtUpdateNow.name.tr;
  }

  String get _skipText {
    if (widget.customSkipText != null &&
        widget.customSkipText!.trim().isNotEmpty) {
      return widget.customSkipText!.trim();
    }
    final apiSkip = Database.settingApiModel?.data?.updateDialogSkipText;
    if (apiSkip != null && apiSkip.trim().isNotEmpty) {
      return apiSkip.trim();
    }
    return "Maybe Later";
  }

  String get _versionBadgeText {
    final ver = widget.targetVersion ??
        (GetPlatform.isIOS
            ? (Database.settingApiModel?.data?.iosLatestVersion ??
                Database.settingApiModel?.data?.iosAppVersion ??
                "")
            : (Database.settingApiModel?.data?.androidLatestVersion ??
                Database.settingApiModel?.data?.androidAppVersion ??
                ""));
    if (ver.isNotEmpty) {
      return "v$ver ${EnumLocale.txtNewVersion.name.tr}";
    }
    return EnumLocale.txtNewVersion.name.tr;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForceUpdate,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !widget.isForceUpdate) {
          widget.onSkip?.call();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Update Icon
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 1 + (0.06 * (1 - (value - 0.5).abs() * 2)),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.2),
                                AppColors.primary.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.system_update_alt_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Version Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _versionBadgeText,
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Title
                  Text(
                    _title,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 22,
                      fontColor: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Message Description
                  Text(
                    _message,
                    style: AppFontStyle.fontStyleW400(
                      fontSize: 14,
                      fontColor: AppColors.black.withValues(alpha: 0.65),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 24),

                  // Update Button
                  InkWell(
                    onTap: _openStore,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _buttonText,
                            style: AppFontStyle.fontStyleW700(
                              fontColor: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  // Skip Button (Only for Flexible Update)
                  if (!widget.isForceUpdate) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        widget.onSkip?.call();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        _skipText,
                        style: AppFontStyle.fontStyleW600(
                          fontColor: AppColors.black.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],

                  // Footer notice for Force Update
                  if (widget.isForceUpdate) ...[
                    const SizedBox(height: 12),
                    Text(
                      EnumLocale.txtThisUpdateIsRequiredToContinue.name.tr,
                      style: AppFontStyle.fontStyleW500(
                        fontColor: AppColors.black.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openStore() async {
    final androidUrl = Database.settingApiModel?.data?.androidAppLink ?? "";
    final iosUrl = Database.settingApiModel?.data?.iosAppLink ?? "";
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final url = isIos ? iosUrl : androidUrl;

    if (url.trim().isEmpty) {
      Utils.showLog("⚠️ Store URL is empty");
      return;
    }

    try {
      final uri = Uri.parse(url.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      Utils.showLog("Failed to launch store url $url: $e");
    }
  }
}

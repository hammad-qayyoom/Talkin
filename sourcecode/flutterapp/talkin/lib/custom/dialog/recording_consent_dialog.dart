import 'package:flutter/material.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class RecordingConsentDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final IconData icon;
  final List<Color> gradientColors;

  RecordingConsentDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    this.icon = Icons.fiber_manual_record_rounded,
    List<Color>? gradientColors,
  }) : gradientColors = gradientColors ?? [
      AppColors.redesignBrandRed,
      AppColors.redesignBrandRedDark,
    ];

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    IconData icon = Icons.fiber_manual_record_rounded,
    List<Color>? gradientColors,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'RecordingConsent',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curvedAnim = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curvedAnim,
          child: FadeTransition(
            opacity: anim,
            child: RecordingConsentDialog(
              title: title,
              description: description,
              confirmText: confirmText,
              cancelText: cancelText,
              onConfirm: onConfirm,
              onCancel: onCancel,
              icon: icon,
              gradientColors: gradientColors,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final constrainedWidth = (screenWidth - 48).clamp(280.0, 360.0);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: constrainedWidth,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.redesignSoftBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.22),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.redesignSheetHandle,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 15,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryAppButton(
                  onTap: onConfirm,
                  height: 50,
                  borderRadius: 14,
                  gradientColor: gradientColors,
                  text: confirmText,
                  textStyle: AppFontStyle.fontStyleW700(
                    fontSize: 17,
                    fontColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryAppButton(
                  onTap: onCancel,
                  height: 48,
                  borderRadius: 14,
                  color: AppColors.redesignSurfaceInput,
                  borderColor: AppColors.redesignSoftBorder,
                  text: cancelText,
                  textStyle: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomRangePicker {
  static Future<DateTimeRange?> onShow(
    BuildContext context,
    DateTimeRange? initialDateRange,
  ) async {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.appColor,
      onPrimary: AppColors.white,
      onSurface: AppColors.black,
      surface: AppColors.white,
    );

    return await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      barrierColor: AppColors.black.withValues(alpha: 0.8),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
            textTheme: Theme.of(context).textTheme.copyWith(
                  bodyMedium: AppFontStyle.fontStyleW500(
                    fontColor: AppColors.black,
                    fontSize: 16,
                  ),
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

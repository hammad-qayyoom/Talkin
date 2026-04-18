import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/setting_screen/controller/setting_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class AppRestartDialog extends StatefulWidget {
  const AppRestartDialog({super.key});

  @override
  State<AppRestartDialog> createState() => _AppRestartDialogState();
}

class _AppRestartDialogState extends State<AppRestartDialog> {
  SettingController settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // top handle (subtle)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.redesignSheetHandle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Hero icon
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.redesignAvatarSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.verified,
                  color: AppColors.redesignBrandRed,
                  size: 38,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Title
            Text(
              EnumLocale.txtAppRestart.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW700(
                fontSize: 20,
                fontColor: AppColors.redesignTextStrong,
              ),
            ),

            const SizedBox(height: 20),

            // Primary CTA
            PrimaryAppButton(
              color: AppColors.redesignBrandRed,
              gradientColor: [
                AppColors.redesignBrandRed,
                AppColors.redesignBrandRedDark
              ],
              onTap: () {
                Get.offAllNamed(AppRoutes.splashScreenPage);
              },
              height: 52,
              borderRadius: 12,
              text: 'Restart App',
              textStyle: AppFontStyle.fontStyleW600(
                fontSize: 16,
                fontColor: AppColors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Secondary action
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 48,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.redesignSoftBorder, width: 1.0),
                ),
                child: Text(
                  EnumLocale.txtClose.name.tr,
                  style: AppFontStyle.fontStyleW600(
                      fontSize: 15, fontColor: AppColors.redesignBrandDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class RequestSentDialog extends StatelessWidget {
  const RequestSentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.redesignBrandRed,
                  AppColors.redesignBrandRedDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      AppAsset.appLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Expert Application Received',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 106,
            width: 106,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.redesignSoftBorder,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                AppAsset.requestSentImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            EnumLocale.txtYourHostRequestSentSuccessfully.name.tr,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW700(
              fontSize: 30,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            EnumLocale.txtYourHostRequestSentSuccessfullyDescription.name.tr,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW500(
              fontSize: 14,
              height: 1.5,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryAppButton(
            onTap: () {
              Get.offAllNamed(AppRoutes.hostRequestSentSuccessfullyScreen);
            },
            color: AppColors.redesignBrandDark,
            height: 52,
            borderRadius: 14,
            text: EnumLocale.txtViewRequest.name.tr,
            textStyle: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

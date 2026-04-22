import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class ExitAppDialog extends StatelessWidget {
  const ExitAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final constrainedWidth = (screenWidth - 32).clamp(280.0, 430.0);

    return Center(
      child: Container(
        width: constrainedWidth,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: AppColors.redesignSoftBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
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
              const SizedBox(height: 14),
              Container(
                height: 86,
                width: 86,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.redesignBrandRed,
                      AppColors.redesignBrandRedDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.redesignBrandRed.withValues(alpha: 0.34),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    AppAsset.logOut,
                    height: 50,
                    width: 50,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                EnumLocale.txtExitApp.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 24,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                EnumLocale.desWantExitApp.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 16,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryAppButton(
                onTap: () {
                  exit(0);
                },
                height: 52,
                borderRadius: 14,
                gradientColor: [
                  AppColors.redesignBrandRed,
                  AppColors.redesignBrandRedDark,
                ],
                text: EnumLocale.txtExitApp.name.tr,
                textStyle: AppFontStyle.fontStyleW700(
                  fontSize: 18,
                  fontColor: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),
              PrimaryAppButton(
                onTap: () {
                  Get.back();
                },
                height: 50,
                borderRadius: 14,
                color: AppColors.redesignSurfaceInput,
                borderColor: AppColors.redesignSoftBorder,
                text: EnumLocale.txtCancel.name.tr,
                textStyle: AppFontStyle.fontStyleW700(
                  fontSize: 17,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNotLiveDialog extends StatelessWidget {
  const AppNotLiveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 365,
      child: Material(
        shape: const SquircleBorder(
          radius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAsset.underMaintenanceImage),
                  fit: BoxFit.cover,
                ),
                // color: Colors.red,
              ),
              // child: Image.asset(
              //   AppAsset.underMaintenanceImage,
              //   height: 180,
              //   width: 180,
              // ),
            ),
            Text(
              "Your app is under maintenance.",
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 19,
                fontColor: AppColors.appColor,
              ),
            ).paddingOnly(bottom: 13),
            // const Spacer(),
            PrimaryAppButton(
              onTap: () {
                exit(0);
              },
              height: 47,
              borderRadius: 8,
              text: EnumLocale.txtExitApp.name.tr,
              textStyle: AppFontStyle.fontStyleW600(
                fontSize: 17,
                fontColor: AppColors.white,
              ),
            ).paddingOnly(top: 20, bottom: 10, left: 5, right: 5),
          ],
        ).paddingAll(15),
      ),
    );
  }
}

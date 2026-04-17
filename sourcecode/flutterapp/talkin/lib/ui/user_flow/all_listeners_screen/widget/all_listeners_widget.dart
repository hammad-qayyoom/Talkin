import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_bar/custom_app_bar.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';

class AllListenersAppBar extends StatelessWidget {
  const AllListenersAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      // appBarColor: AppColors.red,
      title: EnumLocale.txtAllListeners.name.tr,
      showLeadingIcon: true,
      action: [
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.searchScreen);
          },
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                AppAsset.searchIcon,
                height: 18,
                width: 18,
              ),
            ),
          ).paddingOnly(right: 18),
        )
      ],
    );
  }
}

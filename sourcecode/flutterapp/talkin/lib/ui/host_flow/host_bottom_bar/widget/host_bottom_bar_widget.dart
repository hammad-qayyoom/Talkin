import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_bar/salomon_bottom_bar.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/controller/host_bottom_bar_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class HostBottomBarView extends StatelessWidget {
  const HostBottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostBottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        final int currentIndex = logic.selectIndex >= 0 && logic.selectIndex < 5
            ? logic.selectIndex
            : 0;

        return Container(
          height: Platform.isIOS ? 85 : 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.5),
                offset: const Offset(
                  6.0,
                  6.0,
                ),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ), //BoxShadow
            ],
          ),
          child: OverflowBox(
            maxHeight: double.infinity,
            maxWidth: double.infinity,
            child: SalomonBottomBar(
              currentIndex: currentIndex,
              onTap: (value) async {
                logic.onClick(value);
              },
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                  left: 10, right: 10, top: Platform.isIOS ? 10 : 0),
              selectedColorOpacity: 1,
              items: [
                bottomBarItemView(
                  index: 0,
                  selectIndex: currentIndex,
                  image: AppAsset.homeFilled,
                  label: EnumLocale.txtHome.name.tr,
                ),
                bottomBarItemView(
                  index: 1,
                  selectIndex: currentIndex,
                  image: AppAsset.calendar,
                  label: 'Sessions',
                ),
                bottomBarIconItemView(
                  index: 2,
                  selectIndex: currentIndex,
                  icon: Icons.dynamic_feed_rounded,
                  label: 'Feed',
                ),
                bottomBarItemView(
                  index: 3,
                  selectIndex: currentIndex,
                  image: AppAsset.chat,
                  label: EnumLocale.txtChat.name.tr,
                ),
                bottomBarItemView(
                  index: 4,
                  selectIndex: currentIndex,
                  image: AppAsset.walletIcon,
                  label: EnumLocale.txtWallet.name.tr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

SalomonBottomBarItem bottomBarItemView({
  required final int index,
  required final int selectIndex,
  required final String image,
  required final String label,
}) {
  return SalomonBottomBarItem(
    icon: Image.asset(
      image,
      height: 26,
      width: 26,
      color: selectIndex == index ? AppColors.white : AppColors.unSelected,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: selectIndex == index ? FontWeight.w700 : FontWeight.w500,
        color: selectIndex == index ? AppColors.appColor : AppColors.unSelected,
      ),
    ).paddingOnly(bottom: 5),
    selectedColor: AppColors.appColor,
  );
}

SalomonBottomBarItem bottomBarIconItemView({
  required final int index,
  required final int selectIndex,
  required final IconData icon,
  required final String label,
}) {
  return SalomonBottomBarItem(
    icon: Icon(
      icon,
      size: 26,
      color: selectIndex == index ? AppColors.white : AppColors.unSelected,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: selectIndex == index ? FontWeight.w700 : FontWeight.w500,
        color: selectIndex == index ? AppColors.appColor : AppColors.unSelected,
      ),
    ).paddingOnly(bottom: 5),
    selectedColor: AppColors.appColor,
  );
}

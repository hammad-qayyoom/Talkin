import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_bar/salomon_bottom_bar.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class BottomBarView extends StatelessWidget {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        return Container(
          height: Platform.isIOS ? 94 : 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.black.withValues(alpha: 0.05),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                offset: const Offset(0.0, -2.0),
                blurRadius: 14.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: OverflowBox(
            maxHeight: double.infinity,
            maxWidth: double.infinity,
            child: SalomonBottomBar(
              currentIndex: logic.selectIndex,
              onTap: (value) async {
                logic.onClick(value);
              },
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: Platform.isIOS ? 10 : 6,
              ),
              selectedColorOpacity: 1,
              items: [
                bottomBarItemView(
                  index: 0,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.homeFilled,
                  label: EnumLocale.txtHome.name.tr,
                  selectedColor: AppColors.redesignBrandRed,
                  unselectedColor: AppColors.redesignBottomBarUnselected,
                ),
                bottomBarIconItemView(
                  index: 1,
                  selectIndex: logic.selectIndex,
                  icon: Icons.dynamic_feed_rounded,
                  label: 'Feed',
                  selectedColor: AppColors.redesignBrandRed,
                  unselectedColor: AppColors.redesignBottomBarUnselected,
                ),
                bottomBarItemView(
                  index: 2,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.listener,
                  label: EnumLocale.txtListener.name.tr,
                  selectedColor: AppColors.redesignBrandRed,
                  unselectedColor: AppColors.redesignBottomBarUnselected,
                ),
                bottomBarItemView(
                  index: 3,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.chat,
                  label: EnumLocale.txtChat.name.tr,
                  selectedColor: AppColors.redesignBrandRed,
                  unselectedColor: AppColors.redesignBottomBarUnselected,
                ),
                bottomBarItemView(
                  index: 4,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.calendar,
                  label: 'Sessions',
                  selectedColor: AppColors.redesignBrandRed,
                  unselectedColor: AppColors.redesignBottomBarUnselected,
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
  required final Color selectedColor,
  required final Color unselectedColor,
}) {
  return SalomonBottomBarItem(
    icon: Image.asset(
      image,
      height: 26,
      width: 26,
      color: selectIndex == index ? AppColors.white : unselectedColor,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: selectIndex == index ? FontWeight.w700 : FontWeight.w500,
        color: selectIndex == index ? selectedColor : unselectedColor,
      ),
    ).paddingOnly(bottom: 5),
    selectedColor: selectedColor,
  );
}

SalomonBottomBarItem bottomBarIconItemView({
  required final int index,
  required final int selectIndex,
  required final IconData icon,
  required final String label,
  required final Color selectedColor,
  required final Color unselectedColor,
}) {
  return SalomonBottomBarItem(
    icon: Icon(
      icon,
      size: 26,
      color: selectIndex == index ? AppColors.white : unselectedColor,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: selectIndex == index ? FontWeight.w700 : FontWeight.w500,
        color: selectIndex == index ? selectedColor : unselectedColor,
      ),
    ).paddingOnly(bottom: 5),
    selectedColor: selectedColor,
  );
}

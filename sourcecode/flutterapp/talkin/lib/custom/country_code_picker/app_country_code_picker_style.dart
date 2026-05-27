import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

PickerDialogStyle appCountryCodePickerStyle(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;

  return PickerDialogStyle(
    backgroundColor: AppColors.white,
    width: width >= 560 ? 430 : width,
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
    searchFieldPadding: const EdgeInsets.only(bottom: 6),
    listTilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    listTileDivider: Divider(
      height: 1,
      thickness: 1,
      color: AppColors.redesignSoftBorder,
    ),
    countryNameStyle: AppFontStyle.fontStyleW700(
      fontSize: 14,
      fontColor: AppColors.redesignBrandDark,
    ),
    countryCodeStyle: AppFontStyle.fontStyleW700(
      fontSize: 14,
      fontColor: AppColors.redesignBrandDark,
    ),
    searchFieldCursorColor: AppColors.redesignBrandRed,
    searchFieldInputDecoration: InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppColors.redesignSurfaceNeutralAlt,
      hintText: EnumLocale.txtSearchCountryCode.name.tr,
      hintStyle: AppFontStyle.fontStyleW500(
        fontSize: 14,
        fontColor: AppColors.redesignMutedText,
      ),
      prefixIcon: Icon(
        Icons.search_rounded,
        color: AppColors.redesignMutedText,
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.redesignSoftBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.redesignBrandRed, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.redesignSoftBorder),
      ),
    ),
  );
}

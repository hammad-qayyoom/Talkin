import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class _MoreOptionTile extends StatelessWidget {
  const _MoreOptionTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppFontStyle.fontStyleW700(
                        fontColor: AppColors.redesignSheetOptionTitle,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.redesignSheetOptionChevron,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.redesignSheetDivider,
            height: 1,
            indent: 14,
            endIndent: 14,
          ),
      ],
    );
  }
}

void showMoreOptionsBottomSheet({
  required BuildContext context,
  required bool isHost,
  required String userId,
  required VoidCallback onBlock,
  required VoidCallback onReport,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => SafeArea(
      top: false,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.redesignSheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: 44,
                          decoration: BoxDecoration(
                            color: AppColors.redesignSheetHandle,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          EnumLocale.txtMore.name.tr,
                          style: AppFontStyle.fontStyleW700(
                            fontColor: AppColors.redesignSheetTitle,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: Get.back,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.redesignSheetBg,
                          border: Border.all(
                            color: AppColors.redesignSheetCloseBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 24,
                          color: AppColors.redesignSheetCloseIcon,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.redesignSheetDivider, height: 1),
            _MoreOptionTile(
              icon: Icons.block_rounded,
              title: EnumLocale.txtBlock.name.tr,
              iconColor: AppColors.redesignSheetBlockIcon,
              iconBackground: AppColors.redesignSheetBlockBg,
              onTap: () {
                Get.back();
                onBlock();
              },
            ),
            _MoreOptionTile(
              icon: Icons.report_gmailerrorred_rounded,
              title: EnumLocale.txtReport.name.tr,
              iconColor: AppColors.redesignSheetReportIcon,
              iconBackground: AppColors.redesignSheetReportBg,
              onTap: () {
                Get.back();
                onReport();
              },
              showDivider: false,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

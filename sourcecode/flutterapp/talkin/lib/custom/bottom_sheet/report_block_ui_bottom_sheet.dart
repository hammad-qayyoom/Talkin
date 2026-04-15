import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class _MoreOptionTile extends StatelessWidget {
  const _MoreOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.redesignSurfaceNeutralAlt,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFontStyle.fontStyleW700(
                        fontColor: AppColors.redesignSheetOptionTitle,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFontStyle.fontStyleW500(
                        fontColor: AppColors.redesignMutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.redesignSheetOptionChevron,
                ),
              ),
            ],
          ),
        ),
      ),
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
    builder: (context) {
      final bottomInset = MediaQuery.of(context).padding.bottom;

      return SafeArea(
        top: false,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.redesignSheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Column(
                  children: [
                    Container(
                      height: 5,
                      width: 52,
                      decoration: BoxDecoration(
                        color: AppColors.redesignSheetHandle,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                EnumLocale.txtMore.name.tr,
                                style: AppFontStyle.fontStyleW700(
                                  fontColor: AppColors.redesignSheetTitle,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isHost
                                    ? 'Safety actions for this user chat'
                                    : 'Safety actions for this listener chat',
                                textAlign: TextAlign.center,
                                style: AppFontStyle.fontStyleW500(
                                  fontColor: AppColors.redesignMutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: Get.back,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.redesignSheetCloseBorder,
                                  width: 1.4,
                                ),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 28,
                                color: AppColors.redesignSheetCloseIcon,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: AppColors.redesignSheetDivider, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  children: [
                    _MoreOptionTile(
                      icon: Icons.block_rounded,
                      title: EnumLocale.txtBlock.name.tr,
                      subtitle: 'Prevent messages and calls from this chat',
                      iconColor: AppColors.redesignSheetBlockIcon,
                      iconBackground: AppColors.redesignSheetBlockBg,
                      onTap: () {
                        Get.back();
                        onBlock();
                      },
                    ),
                    const SizedBox(height: 10),
                    _MoreOptionTile(
                      icon: Icons.report_gmailerrorred_rounded,
                      title: EnumLocale.txtReport.name.tr,
                      subtitle: 'Report this conversation for review',
                      iconColor: AppColors.redesignSheetReportIcon,
                      iconBackground: AppColors.redesignSheetReportBg,
                      onTap: () {
                        Get.back();
                        onReport();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: bottomInset > 0 ? bottomInset : 12),
            ],
          ),
        ),
      );
    },
  );
}

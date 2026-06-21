import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFontStyle.fontStyleW500(
                        fontColor: AppColors.redesignMutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.redesignSurfaceNeutralAlt,
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
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
      final horizontalPadding =
          MediaQuery.sizeOf(context).width >= 760 ? 18.0 : 14.0;

      return SafeArea(
        top: false,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.redesignSheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 46,
                      decoration: BoxDecoration(
                        color: AppColors.redesignSheetHandle,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                EnumLocale.txtMore.name.tr,
                                style: AppFontStyle.fontStyleW700(
                                  fontColor: AppColors.redesignSheetTitle,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isHost
                                    ? 'Safety actions for this user chat'
                                    : 'Safety actions for this listener chat',
                                style: AppFontStyle.fontStyleW500(
                                  fontColor: AppColors.redesignMutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: Get.back,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.redesignSurfaceNeutralAlt,
                                border: Border.all(
                                  color: AppColors.redesignSoftBorder,
                                  width: 1.1,
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
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.redesignSheetDivider, height: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  10,
                ),
                child: Column(
                  children: [
                    _MoreOptionTile(
                      icon: Icons.block_rounded,
                      title: EnumLocale.txtBlock.name.tr,
                      subtitle: EnumLocale.txtPreventMessagesAndCallsFromThisChat.name.tr,
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
                      subtitle: EnumLocale.txtReportThisConversationForReview.name.tr,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/app_language_bottom_sheet.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/talk_about_bottom_sheet.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class ListenersAppBarView extends StatelessWidget {
  const ListenersAppBarView({super.key});

  static final Color _screenBackground = AppColors.redesignScreenBackground;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return Container(
      color: _screenBackground,
      padding: EdgeInsets.only(
        top: topInset + (isTablet ? 14 : 10),
        left: isTablet ? 22 : 16,
        right: isTablet ? 22 : 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          const SizedBox(width: 46),
          Expanded(
            child: Text(
              EnumLocale.txtAllListeners.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW700(
                fontSize: isTablet ? 38 : 22,
                fontColor: _brandDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.searchScreen);
            },
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _softBorder),
              ),
              child: Center(
                child: Image.asset(
                  AppAsset.searchIcon,
                  height: 22,
                  width: 22,
                  color: _brandDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListenersTopButtonView extends StatelessWidget {
  final double horizontalInset;

  const ListenersTopButtonView({
    super.key,
    this.horizontalInset = 16,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  Widget _buildFilterCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: isTablet ? 60 : 56,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 9 : 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _brandRed : _softBorder,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.black.withValues(alpha: isSelected ? 0.06 : 0.04),
                blurRadius: isSelected ? 14 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _brandRed.withValues(alpha: 0.12)
                      : AppColors.redesignScreenBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected ? _brandRed : _mutedText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 11,
                        fontColor: isSelected ? _brandRed : _mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListenersScreenController>(
      builder: (controller) {
        final selectedLanguageCount = controller.selectedLanguages.length;
        final selectedTopicCount = controller.selectedTopics.length;

        return Padding(
          padding: EdgeInsets.fromLTRB(horizontalInset, 0, horizontalInset, 14),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterCard(
                  context: context,
                  icon: Icons.record_voice_over_rounded,
                  title: EnumLocale.txtLanguage.name.tr,
                  value: selectedLanguageCount > 0
                      ? '$selectedLanguageCount selected'
                      : EnumLocale.txtAll.name.tr,
                  isSelected: selectedLanguageCount > 0,
                  onTap: () {
                    Get.bottomSheet(
                      const AppLanguageBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparent,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFilterCard(
                  context: context,
                  icon: Icons.question_answer_rounded,
                  title: EnumLocale.txtTalkAbout.name.tr,
                  value: selectedTopicCount > 0
                      ? '$selectedTopicCount selected'
                      : EnumLocale.txtAll.name.tr,
                  isSelected: selectedTopicCount > 0,
                  onTap: () {
                    Get.bottomSheet(
                      const TalkAboutBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparent,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

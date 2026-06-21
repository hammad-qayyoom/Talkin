import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/bottom_sheet/share_app_bottom_sheet.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class CallCutView extends StatelessWidget {
  const CallCutView({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDark;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _cardSurface = AppColors.white;
  static final Color _background = AppColors.redesignScreenBackground;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallCutController>(
      builder: (controller) {
        final receiverName = (controller.receiverName ?? '').trim().isEmpty
            ? 'Expert'
            : controller.receiverName!.trim();

        return Container(
          color: _background,
          child: Column(
            children: [
              _buildHero(receiverName, context),
              _buildSummaryCard(controller, receiverName),
              _buildQuestionCard(
                title: EnumLocale.txtDidYouLikeService.name.tr,
                selectedValue: controller.listenerService,
                onSelect: controller.listenerServiceSelect,
              ),
              _buildQuestionCard(
                title: "Add @receiverName to your Favourite Experts?".trParams({'receiverName': receiverName}),
                selectedValue: controller.favListener,
                onSelect: controller.favListenerSelect,
              ),
              _buildShareCard(controller),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero(String receiverName, BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_brandRed, _brandRedDark],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _brandRed.withValues(alpha: 0.25),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              EnumLocale.txtCompleteTrailCallWithName.name.trParams({
                'completeTrailCall': EnumLocale.txtCompleteTrailCall.name.tr,
                'receiverName': receiverName,
                'completeTrailCall1': EnumLocale.txtCompleteTrailCall1.name.tr,
              }),
              style: AppFontStyle.fontStyleW700(
                fontSize: 15,
                fontColor: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.26),
              ),
            ),
            child: Icon(
              Icons.call_rounded,
              color: AppColors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(CallCutController controller, String receiverName) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_brandRed, _brandRedDark],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: ClipOval(
                    child: CustomProfileImage(
                      image: controller.receiverImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EnumLocale.txtListener.name.tr,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: _mutedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      receiverName,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 18,
                        fontColor: _brandDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 10) / 2;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: CallDetailContainer(
                      title: EnumLocale.txtDate.name.tr,
                      image: AppAsset.calendar,
                      subTitle: controller.date ?? '--',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: CallDetailContainer(
                      title: EnumLocale.txtDuration.name.tr,
                      icon: Icons.access_time_filled_rounded,
                      subTitle: controller.callDuration ?? '--',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: CallDetailContainer(
                      title: EnumLocale.txtBalanceused.name.tr,
                      image: AppAsset.wallet,
                      subTitle: controller.usedBalance ?? '--',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: CallDetailContainer(
                      title: EnumLocale.txtCallId.name.tr,
                      image: AppAsset.callIconBlack,
                      subTitle: controller.callId ?? '--',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required String selectedValue,
    required Function(String value) onSelect,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFontStyle.fontStyleW600(
              fontSize: 15,
              fontColor: _brandDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ChoiceButton(
                label: EnumLocale.txtYes.name.tr,
                isSelected: selectedValue == 'yes',
                onTap: () => onSelect('yes'),
              ),
              const SizedBox(width: 10),
              _ChoiceButton(
                label: EnumLocale.txtNo.name.tr,
                isSelected: selectedValue == 'no',
                onTap: () => onSelect('no'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(CallCutController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtShareListenersApp.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 17,
                    fontColor: _brandDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  EnumLocale.txtShareListenersAppDescription.name.tr,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 14,
                    fontColor: _mutedText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: controller.onClickShare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_brandRed, _brandRedDark],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      EnumLocale.txtShareAppNow.name.tr,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceNeutralAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _softBorder),
            ),
            child: Center(
              child: Image.asset(
                AppAsset.shareApp,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomView extends StatelessWidget {
  const BottomView({super.key});

  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 10 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: _softBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomActionButton(
              label: EnumLocale.txtSkip.name.tr,
              onTap: () {
                Get.toNamed(AppRoutes.bottomBar);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BottomActionButton(
              label: EnumLocale.txtFeedBack.name.tr,
              filled: true,
              onTap: () {
                if (Get.isBottomSheetOpen ?? false) {
                  Get.back();
                }
                Get.bottomSheet(
                  ShareAppBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CallDetailContainer extends StatelessWidget {
  const CallDetailContainer({
    super.key,
    this.icon,
    this.image,
    required this.title,
    required this.subTitle,
  });

  final IconData? icon;
  final String? image;
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    final accentBg = AppColors.redesignAccentSoftBg;
    final neutralText = AppColors.redesignMutedText;
    final headingColor = AppColors.redesignBrandDark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      color: headingColor,
                      size: 18,
                    )
                  : Image.asset(
                      image!,
                      height: 18,
                      width: 18,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: neutralText,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 3),
                Text(
                  subTitle,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 14,
                    fontColor: headingColor,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? AppColors.redesignBrandRed : AppColors.redesignSoftBorder;
    final bgColor = isSelected
        ? AppColors.redesignAccentSoftBg
        : AppColors.redesignSurfaceNeutralAlt;
    final textColor =
        isSelected ? AppColors.redesignBrandDark : AppColors.redesignMutedText;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 14,
            fontColor: textColor,
          ),
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFF161A23), Color(0xFF20273A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: filled ? null : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled ? AppColors.transparent : AppColors.redesignBrandDark,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppFontStyle.fontStyleW700(
              fontSize: 14,
              fontColor: filled ? AppColors.white : AppColors.redesignBrandDark,
            ),
          ),
        ),
      ),
    );
  }
}

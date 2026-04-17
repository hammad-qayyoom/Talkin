import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/ui/host_flow/host_listeners_detail_screen/controller/host_listeners_detail_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class HostListenersDetailTopView extends StatelessWidget {
  const HostListenersDetailTopView({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _mutedText = AppColors.redesignMutedText;

  void _showImagePickerSheet({
    required BuildContext context,
    required HostListenersDetailController controller,
  }) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: _softBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.redesignSheetHandle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              EnumLocale.changeYourImage.name.tr,
              style: AppFontStyle.fontStyleW700(
                fontSize: 18,
                fontColor: _brandDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose where to pick your profile photo from',
              style: AppFontStyle.fontStyleW500(
                fontSize: 12,
                fontColor: _mutedText,
              ),
            ),
            const SizedBox(height: 14),
            _BottomSheetActionTile(
              iconAsset: AppAsset.cameraFlipIcon,
              label: EnumLocale.txtTakeAphoto.name.tr,
              onTap: () {
                Get.back();
                controller.takePhoto();
              },
            ),
            const SizedBox(height: 10),
            _BottomSheetActionTile(
              iconAsset: AppAsset.chatImageIcon,
              label: EnumLocale.txtChooseFromYourFile.name.tr,
              onTap: () {
                Get.back();
                controller.getImageFromGallery();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 760;

    return GetBuilder<HostListenersDetailController>(
      builder: (controller) {
        final String listenerName = controller.nameCnt.text.trim().isEmpty
            ? (Database.fetchListenerProfileModel?.data?.name ?? 'Expert')
            : controller.nameCnt.text.trim();
        final String listenerNick = controller.nickNameCnt.text.trim().isEmpty
            ? (Database.fetchListenerProfileModel?.data?.nickName ??
                EnumLocale.txtNickName.name.tr)
            : controller.nickNameCnt.text.trim();
        final String? localImagePath = controller.pickImage;
        final bool hasLocalImage =
            localImagePath != null && localImagePath.trim().isNotEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _softBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        'Edit Expert',
                        textAlign: TextAlign.center,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: isTablet ? 20 : 17,
                          fontColor: _brandDark,
                        ),
                      ),
                    ),
                    _RoundIconButton(
                      icon: Icons.photo_camera_outlined,
                      onTap: () => _showImagePickerSheet(
                        context: context,
                        controller: controller,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.redesignBrandRed,
                        AppColors.redesignAccentGradientEnd,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      height: isTablet ? 96 : 82,
                      width: isTablet ? 96 : 82,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _brandRed.withValues(alpha: 0.28),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: hasLocalImage
                            ? Image.file(
                                File(localImagePath),
                                fit: BoxFit.cover,
                              )
                            : CustomProfileImage(
                                image: Database.fetchListenerProfileModel?.data
                                        ?.image ??
                                    '',
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  listenerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: isTablet ? 21 : 18,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.redesignSurfaceNeutralAlt,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: _softBorder),
                                ),
                                child: Text(
                                  'Expert',
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 10,
                                    fontColor: _mutedText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@$listenerNick',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: isTablet ? 14 : 12,
                              fontColor: _mutedText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ActionPill(
                                icon: Icons.language_rounded,
                                label:
                                    '${controller.selectedLanguages.length} ${EnumLocale.txtTalkLanguages.name.tr.replaceAll(':-', '').trim()}',
                              ),
                              _ActionPill(
                                icon: Icons.local_offer_outlined,
                                label:
                                    '${controller.selectedTopics.length} ${EnumLocale.txtTalkAbout.name.tr.replaceAll(':-', '').trim()}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _showImagePickerSheet(
                      context: context,
                      controller: controller,
                    ),
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: Text(
                      EnumLocale.txtChangeImage.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.redesignBrandDark,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HostListenersDetailView extends StatelessWidget {
  const HostListenersDetailView({super.key});

  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _mutedText = AppColors.redesignMutedText;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostListenersDetailController>(
      builder: (controller) {
        final quickLanguages = controller.allLanguages.take(12).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(
            children: [
              _SectionCard(
                title: EnumLocale.txtListenerDetails.name.tr
                    .replaceAll(':-', '')
                    .trim(),
                subtitle:
                    'This information appears on your public expert card.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(title: EnumLocale.txtEnterName.name.tr),
                    const SizedBox(height: 7),
                    _ModernInputField(
                      controller: controller.nameCnt,
                      textInputAction: TextInputAction.next,
                      hint: EnumLocale.txtEnterYourName.name.tr,
                    ),
                    const SizedBox(height: 14),
                    _FieldLabel(title: EnumLocale.txtNickName.name.tr),
                    const SizedBox(height: 7),
                    _ModernInputField(
                      controller: controller.nickNameCnt,
                      textInputAction: TextInputAction.next,
                      hint: EnumLocale.txtEnterNickName.name.tr,
                    ),
                    const SizedBox(height: 14),
                    _FieldLabel(title: EnumLocale.txtEnterIntroduction.name.tr),
                    const SizedBox(height: 7),
                    _ModernInputField(
                      controller: controller.introCnt,
                      textInputAction: TextInputAction.newline,
                      hint: EnumLocale.txtEnterIntroduction.name.tr,
                      minLines: 5,
                      maxLines: 7,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: EnumLocale.txtTalkLanguages.name.tr
                    .replaceAll(':-', '')
                    .trim(),
                subtitle: 'Pick languages you can confidently speak in calls.',
                trailing: TextButton(
                  onPressed: () {
                    Get.bottomSheet(
                      AllLanguageBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparent,
                    );
                  },
                  child: Text(
                    EnumLocale.txtViewAll.name.tr,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 12,
                      fontColor: _brandRed,
                    ),
                  ),
                ),
                child: GetBuilder<HostListenersDetailController>(
                  id: Constant.idLanguageSection,
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (controller.selectedLanguages.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.redesignSurfaceNeutralAlt,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Text(
                              'No language selected yet',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 12,
                                fontColor: _mutedText,
                              ),
                            ),
                          ),
                        if (controller.selectedLanguages.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.selectedLanguages.map((lang) {
                              return _SelectableChip(
                                label: lang,
                                isSelected: true,
                                onTap: () => controller.toggleLanguage(lang),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Quick Select',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: _brandDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: quickLanguages.map((lang) {
                            return _SelectableChip(
                              label: lang,
                              isSelected: controller.isSelected(lang),
                              onTap: () => controller.toggleLanguage(lang),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title:
                    EnumLocale.txtTalkAbout.name.tr.replaceAll(':-', '').trim(),
                subtitle: 'Choose categories where you provide the best value.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<HostListenersDetailController>(
                      id: Constant.talkAboutTopic,
                      builder: (controller) {
                        if (controller.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (controller.talkTopic.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.redesignSurfaceNeutralAlt,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Text(
                              'No topics found',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 12,
                                fontColor: _mutedText,
                              ),
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(controller.talkTopic.length,
                              (index) {
                            final topic = controller.talkTopic[index];
                            final isSelected =
                                controller.selectedTopics.contains(index);
                            final topicName = (topic.name ?? '').trim().isEmpty
                                ? 'Topic'
                                : topic.name!.trim();

                            return _SelectableChip(
                              label: topicName,
                              isSelected: isSelected,
                              withCheck: true,
                              onTap: () => controller.selectTopic(index),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _RateInputTile(
                            title: EnumLocale.txtPrivateVideoCallRate.name.tr,
                            controller: controller.ratePrivateVideoCallCnt,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RateInputTile(
                            title: EnumLocale.txtPrivateAudioCallRate.name.tr,
                            controller: controller.ratePrivateAudioCallCnt,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

class HostListenersDetailBottomButton extends StatelessWidget {
  const HostListenersDetailBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostListenersDetailController>(
      builder: (controller) {
        final width = MediaQuery.sizeOf(context).width;
        final maxContentWidth = width >= 1100 ? 980.0 : width;

        return Container(
          padding: EdgeInsets.only(
            top: 10,
            bottom: MediaQuery.of(context).padding.bottom + 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            border:
                Border(top: BorderSide(color: AppColors.redesignSoftBorder)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PrimaryAppButton(
                  height: 52,
                  borderRadius: 16,
                  gradientColor: [
                    AppColors.redesignBrandDark,
                    AppColors.redesignBrandDarkAlt,
                  ],
                  onTap: () {
                    if (Database.demoListener == true) {
                      Utils.showToast(
                        Get.context!,
                        EnumLocale.txtDEmoListenerText.name.tr,
                      );
                    } else {
                      controller.onSaveProfile();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        EnumLocale.txtSAVED.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 16,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AllLanguageBottomSheet extends StatelessWidget {
  AllLanguageBottomSheet({super.key});

  final controller = Get.find<HostListenersDetailController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.72,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: GetBuilder<HostListenersDetailController>(
        id: Constant.idLanguageSection,
        builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppColors.redesignSheetHandle,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      EnumLocale.txtSelectLanguage.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 18,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Done',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 13,
                        fontColor: AppColors.redesignBrandRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to select one or multiple languages',
                style: AppFontStyle.fontStyleW500(
                  fontSize: 12,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.allLanguages.map((lang) {
                      return _SelectableChip(
                        label: lang,
                        isSelected: controller.isSelected(lang),
                        onTap: () => controller.toggleLanguage(lang),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  AppColors.redesignBrandRed,
                  AppColors.redesignAccentGradientEnd,
                ],
              ),
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
                      title,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 17,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                    padding: const EdgeInsets.only(left: 8), child: trailing!),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppFontStyle.fontStyleW600(
        fontSize: 12,
        fontColor: AppColors.redesignTextMeta,
      ),
    );
  }
}

class _ModernInputField extends StatelessWidget {
  const _ModernInputField({
    required this.controller,
    this.hint,
    this.textInputAction,
    this.textInputType,
    this.maxLines = 1,
    this.minLines = 1,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int minLines;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      minLines: minLines,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      cursorColor: AppColors.redesignBrandRed,
      style: AppFontStyle.fontStyleW600(
        fontSize: 14,
        fontColor: AppColors.redesignBrandDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppFontStyle.fontStyleW500(
          fontSize: 13,
          fontColor: AppColors.redesignMutedText.withValues(alpha: 0.75),
        ),
        filled: true,
        fillColor: AppColors.redesignSurfaceNeutralAlt,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.redesignSoftBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.redesignSoftBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.redesignBrandRed),
        ),
      ),
    );
  }
}

class _RateInputTile extends StatelessWidget {
  const _RateInputTile({
    required this.title,
    required this.controller,
  });

  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(title: title),
        const SizedBox(height: 7),
        _ModernInputField(
          controller: controller,
          hint: '0',
          textInputAction: TextInputAction.next,
          textInputType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.withCheck = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool withCheck;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.redesignBrandRed
        : AppColors.redesignSurfaceNeutralAlt;
    final textColor =
        isSelected ? AppColors.white : AppColors.redesignBrandDark;
    final borderColor =
        isSelected ? AppColors.redesignBrandRed : AppColors.redesignSoftBorder;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 12,
                  fontColor: textColor,
                ),
              ),
              if (withCheck && isSelected) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.redesignMutedText,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppFontStyle.fontStyleW600(
              fontSize: 11,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: AppColors.redesignSurfaceNeutralAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.redesignSoftBorder),
        ),
        child: Icon(
          icon,
          size: 19,
          color: AppColors.redesignBrandDark,
        ),
      ),
    );
  }
}

class _BottomSheetActionTile extends StatelessWidget {
  const _BottomSheetActionTile({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.redesignSurfaceNeutralAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Center(
                  child: Image.asset(
                    iconAsset,
                    height: 17,
                    width: 17,
                    color: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 14,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.redesignMutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

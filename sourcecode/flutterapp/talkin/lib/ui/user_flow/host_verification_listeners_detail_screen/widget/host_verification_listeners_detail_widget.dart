import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/bottom_sheet/all_language_bottom_sheet.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostVerificationListenersDetailAppBar extends StatelessWidget {
  const HostVerificationListenersDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.redesignScreenBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: Get.back,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EnumLocale.txtListenerVerification.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 22,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Expert profile and topic setup',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class HostVerificationListenersDetailView extends StatelessWidget {
  const HostVerificationListenersDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostVerificationController>(
      id: Constant.idIdentityProof,
      builder: (controller) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.redesignBrandRed,
                    AppColors.redesignBrandRedDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Complete profile details to appear in expert discovery.',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: EnumLocale.txtListenerDetails.name.tr,
              child: Column(
                children: [
                  _FieldLabel(title: EnumLocale.txtEnterName.name.tr),
                  CustomTextField(
                    filled: true,
                    borderColor: AppColors.redesignSoftBorder,
                    controller: controller.nameController,
                    cursorColor: AppColors.redesignBrandDark,
                    fontColor: AppColors.redesignBrandDark,
                    hintText: EnumLocale.txtEnterName.name.tr,
                    hintTextColor: AppColors.redesignMutedText,
                    fontSize: 15,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(title: EnumLocale.txtEnterNickName.name.tr),
                  CustomTextField(
                    filled: true,
                    borderColor: AppColors.redesignSoftBorder,
                    controller: controller.nickNameController,
                    cursorColor: AppColors.redesignBrandDark,
                    fontColor: AppColors.redesignBrandDark,
                    hintText: EnumLocale.txtEnterNickName.name.tr,
                    hintTextColor: AppColors.redesignMutedText,
                    fontSize: 15,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(title: EnumLocale.txtGender.name.tr),
                  CustomTextField(
                    filled: true,
                    borderColor: AppColors.redesignSoftBorder,
                    controller: controller.genderCnt,
                    cursorColor: AppColors.redesignBrandDark,
                    fontColor: AppColors.redesignBrandDark,
                    hintText: EnumLocale.txtGender.name.tr,
                    hintTextColor: AppColors.redesignMutedText,
                    fontSize: 15,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(title: EnumLocale.txtEnterIntroduction.name.tr),
                  CustomTextField(
                    filled: true,
                    borderColor: AppColors.redesignSoftBorder,
                    controller: controller.introCnt,
                    cursorColor: AppColors.redesignBrandDark,
                    fontColor: AppColors.redesignBrandDark,
                    hintText: EnumLocale.txtEnterIntroduction.name.tr,
                    hintTextColor: AppColors.redesignMutedText,
                    fontSize: 14,
                    textInputAction: TextInputAction.next,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(
                    title: EnumLocale.txtEnterYourExperience.name.tr,
                  ),
                  CustomTextField(
                    filled: true,
                    borderColor: AppColors.redesignSoftBorder,
                    controller: controller.experienceCnt,
                    cursorColor: AppColors.redesignBrandDark,
                    fontColor: AppColors.redesignBrandDark,
                    hintText: EnumLocale.txtEnterYourExperience.name.tr,
                    hintTextColor: AppColors.redesignMutedText,
                    fontSize: 15,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    textInputType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: EnumLocale.txtTalkLanguages.name.tr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtSelectLanguages.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 14,
                      height: 1.45,
                      fontColor: AppColors.redesignMutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            AllLanguageBottomSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redesignSurfaceNeutral,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: AppColors.redesignSoftBorder),
                          ),
                          child: Text(
                            EnumLocale.txtViewAll.name.tr,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: AppColors.redesignMutedText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (controller.selectedLanguages.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.redesignSurfaceNeutralAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.redesignSoftBorder),
                      ),
                      child: Text(
                        'No languages selected yet.',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 13,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedLanguages.map((language) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redesignAccentSoftBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.redesignBrandRed
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            language,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: AppColors.redesignBrandDark,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '${EnumLocale.txtTalkAbout.name.tr} :-',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtSelectTopic.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 14,
                      height: 1.45,
                      fontColor: AppColors.redesignMutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (controller.talkTopic.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.redesignSurfaceNeutralAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.redesignSoftBorder),
                      ),
                      child: Text(
                        'No topics available right now.',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 13,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      itemCount: controller.talkTopic.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final topic = controller.talkTopic[index];
                        final bool isSelected =
                            controller.selectedTopics.contains(index);

                        return Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => controller.selectTopic(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.redesignAccentSoftBg
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.redesignBrandRed
                                      : AppColors.redesignSoftBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      topic.name?.trim().isNotEmpty == true
                                          ? topic.name!.trim()
                                          : 'Topic',
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 15,
                                        fontColor: isSelected
                                            ? AppColors.redesignBrandDark
                                            : AppColors.redesignMutedText,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.redesignBrandRed
                                          : AppColors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.redesignBrandRed
                                            : AppColors.redesignMutedText,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: AppColors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 7),
        child: Text(
          title,
          style: AppFontStyle.fontStyleW700(
            fontSize: 13,
            fontColor: AppColors.redesignTextMeta,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFontStyle.fontStyleW700(
              fontSize: 20,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class HostVerificationListenersDetailBottomButton extends StatelessWidget {
  const HostVerificationListenersDetailBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.redesignScreenBackground,
          border: Border(
            top: BorderSide(color: AppColors.redesignSoftBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: GetBuilder<HostVerificationController>(
          id: Constant.idBecomeHost,
          builder: (controller) {
            return PrimaryAppButton(
              onTap: controller.validateAndSubmit,
              color: AppColors.redesignBrandDark,
              borderRadius: 14,
              height: 50,
              text: EnumLocale.txtSUBMIT.name.tr,
              textStyle: AppFontStyle.fontStyleW700(
                fontSize: 17,
                fontColor: AppColors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

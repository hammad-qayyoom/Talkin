import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostVerificationAppBar extends StatelessWidget {
  const HostVerificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxContentWidth = screenWidth >= 760 ? 980.0 : double.infinity;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.redesignScreenBackground,
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                    child: Text(
                      EnumLocale.txtListenerVerification.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: (screenWidth >= 760) ? 28 : 20,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

class HostVerificationUploadImageView extends StatelessWidget {
  const HostVerificationUploadImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostVerificationController>(
      id: Constant.idIdentityProof,
      builder: (controller) {
        return _VerificationSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtUploadImages.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                EnumLocale.txtHostVerificationUploadImageTxt.name.tr,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 14,
                  height: 1.45,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        Icons.verified_user_outlined,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Upload clear images for faster approval.',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoading && controller.identityProofList.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(999),
                    color: AppColors.redesignBrandRed,
                    backgroundColor: AppColors.redesignSoftBorder,
                  ),
                ),
              const SizedBox(height: 14),
              _IdentityProofDropdown(controller: controller),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  const double spacing = 10;
                  final double tileWidth =
                      (constraints.maxWidth - (spacing * 2)) / 3;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: tileWidth,
                        child: _UploadTile(
                          imagePath: controller.personalPhoto,
                          iconAsset: AppAsset.uploadImage,
                          title: EnumLocale.txtUploadImag.name.tr,
                          subtitle: EnumLocale.txtPersonalPhotos.name.tr,
                          actionText: EnumLocale.txtCapture.name.tr,
                          onActionTap: () => controller.pickImage(
                            isPersonalPhoto: true,
                          ),
                          onRemoveTap: () {
                            controller.personalPhoto = null;
                            controller.update([Constant.idIdentityProof]);
                          },
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _UploadTile(
                          imagePath: controller.idProofPhoto1,
                          iconAsset: AppAsset.uploadIdImage,
                          title: EnumLocale.txtUploadIDPhotos.name.tr,
                          subtitle: EnumLocale.txtFrontSide.name.tr,
                          actionText: EnumLocale.txtAttach.name.tr,
                          onActionTap: () => controller.pickImage(
                            isPersonalPhoto: false,
                          ),
                          onRemoveTap: () {
                            controller.idProofPhoto1 = null;
                            controller.update([Constant.idIdentityProof]);
                          },
                        ),
                      ),
                      SizedBox(
                        width: tileWidth,
                        child: _UploadTile(
                          imagePath: controller.idProofPhoto2,
                          iconAsset: AppAsset.uploadIdImage,
                          title: EnumLocale.txtUploadIDPhotos.name.tr,
                          subtitle: EnumLocale.txtBackSide.name.tr,
                          actionText: EnumLocale.txtAttach.name.tr,
                          onActionTap: () => controller.pickImage(
                            isPersonalPhoto: false,
                          ),
                          onRemoveTap: () {
                            controller.idProofPhoto2 = null;
                            controller.update([Constant.idIdentityProof]);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IdentityProofDropdown extends StatelessWidget {
  const _IdentityProofDropdown({required this.controller});

  final HostVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: controller.toggleIdentityExpansion,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.selectedIdentityProof?.title ??
                          EnumLocale.txtSelectIdentityProof.name.tr,
                      style: controller.selectedIdentityProof == null
                          ? AppFontStyle.fontStyleW500(
                              fontSize: 14,
                              fontColor: AppColors.redesignMutedText,
                            )
                          : AppFontStyle.fontStyleW600(
                              fontSize: 14,
                              fontColor: AppColors.redesignBrandDark,
                            ),
                    ),
                  ),
                  Icon(
                    controller.isIdentityExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.redesignMutedText,
                  ),
                ],
              ),
            ),
          ),
          if (controller.isIdentityExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.redesignSoftBorder),
                ),
              ),
              child: controller.identityProofList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No identity proofs available.',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 13,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    )
                  : Column(
                      children: controller.identityProofList.map((item) {
                        final bool isSelected =
                            controller.selectedIdentityProof?.id == item.id;

                        return Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: () => controller.selectIdentityProof(item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title ?? '',
                                      style: AppFontStyle.fontStyleW500(
                                        fontSize: 14,
                                        fontColor: isSelected
                                            ? AppColors.redesignBrandDark
                                            : AppColors.redesignMutedText,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: AppColors.redesignBrandRed,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.imagePath,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onActionTap,
    required this.onRemoveTap,
  });

  final String? imagePath;
  final String iconAsset;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onActionTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(14),
        padding: EdgeInsets.zero,
        color: AppColors.redesignSoftBorder,
        dashPattern: const [4, 5],
        strokeWidth: 1,
      ),
      child: imagePath == null
          ? Container(
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    iconAsset,
                    height: 42,
                    width: 42,
                    fit: BoxFit.contain,
                  ),
                  Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 12,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 11,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onActionTap,
                    child: Container(
                      width: double.infinity,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.redesignBrandDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        actionText,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 12,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(7),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemoveTap,
                      child: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: AppColors.redesignBrandDark,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class HostVerificationFillFormView extends StatelessWidget {
  const HostVerificationFillFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostVerificationController>(
      builder: (logic) {
        return _VerificationSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtFillForm.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                EnumLocale.txtHostVerificationFillForm.name.tr,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 14,
                  height: 1.45,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
              const SizedBox(height: 14),
              Form(
                key: logic.formKey,
                child: Column(
                  children: [
                    if (Database.loginType != 2) ...[
                      _FieldLabel(title: EnumLocale.txtEnterMail.name.tr),
                      CustomTextField(
                        filled: true,
                        borderColor: AppColors.redesignSoftBorder,
                        controller: logic.emailController,
                        cursorColor: AppColors.redesignBrandDark,
                        fontColor: AppColors.redesignBrandDark,
                        hintText: EnumLocale.txtEnterYourMail.name.tr,
                        hintTextColor: AppColors.redesignMutedText,
                        fontSize: 15,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return EnumLocale.desEnterEmail.name.tr;
                          } else if (!logic.isEmailValid(value)) {
                            return EnumLocale.desEnterValidEmailAddress.name.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    _FieldLabel(title: EnumLocale.txtEnterYourAddress.name.tr),
                    CustomTextField(
                      filled: true,
                      borderColor: AppColors.redesignSoftBorder,
                      controller: logic.addressController,
                      cursorColor: AppColors.redesignBrandDark,
                      fontColor: AppColors.redesignBrandDark,
                      hintText: EnumLocale.txtEnterYourAddress.name.tr,
                      hintTextColor: AppColors.redesignMutedText,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(title: EnumLocale.txtCountry.name.tr),
                    CustomTextField(
                      filled: true,
                      borderColor: AppColors.redesignSoftBorder,
                      controller: logic.countryCnt,
                      cursorColor: AppColors.redesignBrandDark,
                      fontColor: AppColors.redesignBrandDark,
                      hintText: EnumLocale.txtCountry.name.tr,
                      hintTextColor: AppColors.redesignMutedText,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(title: EnumLocale.txtEnterYourAge.name.tr),
                    CustomTextField(
                      filled: true,
                      borderColor: AppColors.redesignSoftBorder,
                      controller: logic.ageController,
                      cursorColor: AppColors.redesignBrandDark,
                      fontColor: AppColors.redesignBrandDark,
                      hintText: EnumLocale.txtEnterYourAge.name.tr,
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
            ],
          ),
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

class _VerificationSectionCard extends StatelessWidget {
  const _VerificationSectionCard({required this.child});

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
      child: child,
    );
  }
}

class HostVerificationBottomButton extends StatelessWidget {
  const HostVerificationBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxContentWidth = screenWidth >= 760 ? 980.0 : double.infinity;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.redesignSoftBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 16,
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: GetBuilder<HostVerificationController>(
                builder: (controller) {
                  return PrimaryAppButton(
                    onTap: controller.validateAndNext,
                    color: AppColors.redesignBrandDark,
                    borderRadius: 18,
                    height: 54,
                    text: EnumLocale.txtNext.name.tr,
                    textStyle: AppFontStyle.fontStyleW600(
                      fontSize: 15,
                      fontColor: AppColors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

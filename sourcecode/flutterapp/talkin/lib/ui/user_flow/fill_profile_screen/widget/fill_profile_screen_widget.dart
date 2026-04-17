import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/custom_select_gender_bottom_sheet/custom_select_gender_bottom_sheet.dart';
import 'package:notisboard/custom/text_field/custom_text_field.dart';
import 'package:notisboard/ui/user_flow/fill_profile_screen/controller/fill_profile_screen_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class FillProfileScreenAppBar extends StatelessWidget {
  const FillProfileScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtMyProfile.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 30,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete your details to personalize your account.',
            style: AppFontStyle.fontStyleW500(
              fontSize: 13,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class FillProfileImageView extends StatelessWidget {
  const FillProfileImageView({super.key});

  void _openImagePickerSheet(FillProfileScreenController controller) {
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                height: 5,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.redesignSoftBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                EnumLocale.changeYourImage.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 18,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 10),
              _ImageActionTile(
                icon: Icons.photo_camera_outlined,
                title: EnumLocale.txtTakeAphoto.name.tr,
                onTap: () {
                  Get.back();
                  controller.takePhoto();
                },
              ),
              _ImageActionTile(
                icon: Icons.image_outlined,
                title: EnumLocale.txtChooseFromYourFile.name.tr,
                onTap: () {
                  Get.back();
                  controller.getImageFromGallery();
                },
                showDivider: false,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      builder: (controller) {
        final String? localImagePath = controller.pickImage;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 360;

              final avatar = Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.redesignBrandRed.withValues(alpha: 0.24),
                    width: 2,
                  ),
                ),
                child: Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    color: AppColors.redesignSurfaceGrey100,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: localImagePath != null
                        ? Image.file(
                            File(localImagePath),
                            fit: BoxFit.cover,
                          )
                        : CustomProfileImage(
                            image: controller.photo ??
                                Database.loginUserProfilePic,
                          ),
                  ),
                ),
              );

              final details = Column(
                crossAxisAlignment: isNarrow
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Photo',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: AppColors.redesignBrandDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visible on your profile and session requests.',
                    textAlign: isNarrow ? TextAlign.center : TextAlign.start,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.redesignMutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: () => _openImagePickerSheet(controller),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redesignBrandDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 16,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              EnumLocale.txtChangeImage.name.tr,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 13,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  children: [
                    avatar,
                    const SizedBox(height: 12),
                    details,
                  ],
                );
              }

              return Row(
                children: [
                  avatar,
                  const SizedBox(width: 14),
                  Expanded(child: details),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ImageActionTile extends StatelessWidget {
  const _ImageActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: AppColors.redesignBrandRed,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 15,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.redesignSoftBorder,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}

class FillProfileEditInfoView extends StatelessWidget {
  const FillProfileEditInfoView({super.key});

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        title,
        style: AppFontStyle.fontStyleW700(
          fontSize: 13,
          fontColor: AppColors.redesignTextMeta,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      builder: (logic) {
        return Form(
          key: logic.formKey,
          child: Column(
            children: [
              _SectionCard(
                icon: Icons.person_outline_rounded,
                title: 'Basic Information',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(EnumLocale.txtFullName.name.tr),
                    CustomTextField(
                      filled: true,
                      hintText: EnumLocale.txtAddYOurFullName.name.tr,
                      controller: logic.nameController,
                      borderColor: AppColors.redesignSoftBorder,
                      cursorColor: AppColors.redesignBrandDark,
                      fontColor: AppColors.redesignBrandDark,
                      hintTextColor: AppColors.redesignMutedText,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel(EnumLocale.txtNickName.name.tr),
                    CustomTextField(
                      filled: true,
                      hintText: EnumLocale.txtAddYourNickName.name.tr,
                      controller: logic.nickNameController,
                      borderColor: AppColors.redesignSoftBorder,
                      cursorColor: AppColors.redesignBrandDark,
                      fontColor: AppColors.redesignBrandDark,
                      hintTextColor: AppColors.redesignMutedText,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                    ),
                    if (Database.loginType != 2) ...[
                      const SizedBox(height: 12),
                      _sectionLabel(EnumLocale.txtEnterMail.name.tr),
                      CustomTextField(
                        filled: true,
                        hintText: EnumLocale.txtEnterYourMail.name.tr,
                        controller: logic.emailController,
                        borderColor: AppColors.redesignSoftBorder,
                        cursorColor: AppColors.redesignBrandDark,
                        fontColor: AppColors.redesignBrandDark,
                        hintTextColor: AppColors.redesignMutedText,
                        fontSize: 15,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                        readOnly: Database.loginType == 1 ||
                            Database.loginType == 4 ||
                            Database.loginType == 5,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _sectionLabel(EnumLocale.txtDateOfBirth.name.tr),
                    CustomTextField(
                      filled: true,
                      hintText: 'DD / MM / YYYY',
                      controller: logic.dateController,
                      borderColor: AppColors.redesignSoftBorder,
                      cursorColor: AppColors.redesignBrandDark,
                      fontColor: AppColors.redesignBrandDark,
                      hintTextColor: AppColors.redesignMutedText,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      readOnly: true,
                      onTap: () => logic.selectDate(context),
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel(EnumLocale.txtGenderIdentity.name.tr),
                    GetBuilder<FillProfileScreenController>(
                      id: Constant.idGenderSelect,
                      builder: (genderLogic) {
                        return CustomTextField(
                          onTap: () {
                            Get.bottomSheet(
                              const CustomEditeProfileSelectGenderBottomSheet(),
                              isScrollControlled: true,
                              backgroundColor: AppColors.transparent,
                            );
                          },
                          filled: true,
                          controller: genderLogic.genderController,
                          borderColor: AppColors.redesignSoftBorder,
                          cursorColor: AppColors.redesignBrandDark,
                          fontColor: AppColors.redesignBrandDark,
                          hintTextColor: AppColors.redesignMutedText,
                          fontSize: 15,
                          textInputAction: TextInputAction.next,
                          maxLines: 1,
                          readOnly: true,
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.redesignMutedText,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.phone_iphone_rounded,
                title: 'Contact Information',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(EnumLocale.txtSelectCountry.name.tr),
                    GetBuilder<FillProfileScreenController>(
                      id: Constant.idChangeCountry,
                      builder: (countryLogic) {
                        final selectedCountry =
                            countryLogic.countryController.text.trim();
                        final selectedFlag = countryLogic.flagController.text;

                        return Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: () {
                              countryLogic.onChangeCountry(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 52,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.redesignSoftBorder,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  if (selectedCountry.isNotEmpty) ...[
                                    Text(
                                      selectedFlag,
                                      style: AppFontStyle.fontStyleW500(
                                        fontColor: AppColors.redesignBrandDark,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  Expanded(
                                    child: Text(
                                      selectedCountry.isEmpty
                                          ? EnumLocale.txtSelectCountry.name.tr
                                          : selectedCountry,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: selectedCountry.isEmpty
                                          ? AppFontStyle.fontStyleW500(
                                              fontSize: 14,
                                              fontColor:
                                                  AppColors.redesignMutedText,
                                            )
                                          : AppFontStyle.fontStyleW600(
                                              fontSize: 15,
                                              fontColor:
                                                  AppColors.redesignBrandDark,
                                            ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.redesignMutedText,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel(EnumLocale.txtEnterMobileNumber.name.tr),
                    IntlPhoneField(
                      flagsButtonPadding: const EdgeInsets.all(8),
                      flagsButtonMargin: const EdgeInsets.only(right: 8),
                      dropdownIconPosition: IconPosition.trailing,
                      controller: logic.numberController,
                      obscureText: false,
                      validator: (value) {
                        if (value == null) {
                          return EnumLocale.desEnterMobile.name.tr;
                        }
                        return null;
                      },
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 14,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                      cursorColor: AppColors.redesignBrandDark,
                      dropdownTextStyle: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                      pickerDialogStyle: PickerDialogStyle(
                        countryCodeStyle: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                        countryNameStyle: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                        searchFieldCursorColor: AppColors.redesignBrandDark,
                        searchFieldInputDecoration: InputDecoration(
                          hintStyle: AppFontStyle.fontStyleW400(
                            fontSize: 14,
                            fontColor: AppColors.redesignMutedText,
                          ),
                          hintText: EnumLocale.txtSearchCountryCode.name.tr,
                        ),
                      ),
                      dropdownIcon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppColors.redesignMutedText,
                        size: 24,
                      ),
                      keyboardType: TextInputType.number,
                      showCountryFlag: false,
                      decoration: InputDecoration(
                        counterText: '',
                        hintStyle: AppFontStyle.fontStyleW500(
                          fontSize: 13,
                          fontColor: AppColors.redesignMutedText,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppColors.redesignSoftBorder),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppColors.redesignSoftBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: AppColors.redesignBrandRed),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        errorStyle: AppFontStyle.fontStyleW500(
                          fontSize: 9,
                          fontColor: AppColors.red,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        counterStyle: AppFontStyle.fontStyleW500(
                          fontSize: 9,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                      onCountryChanged: (value) {
                        Database.onSetSelectedCountryCode(value.code);
                        Database.getDialCode();
                      },
                      initialCountryCode: Database.selectedCountryCode,
                      onChanged: (phone) {
                        logic.dialCode = phone.countryCode;
                        logic.numberController.text = phone.number;
                      },
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
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
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.redesignBrandRed,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 16,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

GetBuilder<GetxController> saveProfileButton() {
  return GetBuilder<FillProfileScreenController>(
    builder: (controller) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.redesignSoftBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: PrimaryAppButton(
            onTap: () {
              controller.onSaveProfile();
            },
            color: AppColors.redesignBrandDark,
            borderRadius: 16,
            height: 54,
            text: EnumLocale.txtSaveProfile.name.tr,
            textStyle: AppFontStyle.fontStyleW600(
              fontSize: 16,
              fontColor: AppColors.white,
            ),
          ),
        ),
      );
    },
  );
}

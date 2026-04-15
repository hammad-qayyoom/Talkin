import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/custom_select_gender_bottom_sheet/custom_select_gender_bottom_sheet.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class EditProfileScreenAppBar extends StatelessWidget {
  const EditProfileScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              Utils.onChangeStatusBar(brightness: Brightness.dark);
              Get.back();
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtMyProfile.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your account details',
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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

class EditProfileImageView extends StatelessWidget {
  const EditProfileImageView({super.key});

  void _openImagePickerSheet(EditProfileController controller) {
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
    return GetBuilder<EditProfileController>(
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
                            image: Database.loginUserProfilePic,
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

class EditProfileEditInfoView extends StatelessWidget {
  const EditProfileEditInfoView({super.key});

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
    return GetBuilder<EditProfileController>(
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
                    _sectionLabel(EnumLocale.txtNickName.name.tr),
                    CustomTextField(
                      filled: true,
                      hintText: EnumLocale.txtAddYourNickName.name.tr,
                      controller: logic.nickNameCnt,
                      borderColor: AppColors.redesignSoftBorder,
                      cursorColor: AppColors.redesignBrandDark,
                      fontColor: AppColors.redesignBrandDark,
                      hintTextColor: AppColors.redesignMutedText,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel(EnumLocale.txtFullName.name.tr),
                    CustomTextField(
                      filled: true,
                      hintText: EnumLocale.txtAddYOurFullName.name.tr,
                      controller: logic.nameCnt,
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
                        controller: logic.emailCnt,
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
                    GetBuilder<EditProfileController>(
                      id: Constant.idGenderSelect,
                      builder: (genderLogic) {
                        return CustomTextField(
                          onTap: () {
                            Get.bottomSheet(
                              const CustomSelectGenderBottomSheet(),
                              isScrollControlled: true,
                              backgroundColor: AppColors.transparent,
                            );
                          },
                          filled: true,
                          controller: genderLogic.genderCnt,
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
                    GetBuilder<EditProfileController>(
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
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        selectedCountry,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFontStyle.fontStyleW600(
                                          fontColor:
                                              AppColors.redesignBrandDark,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ] else
                                    Expanded(
                                      child: Text(
                                        EnumLocale.txtSelectCountry.name.tr,
                                        style: AppFontStyle.fontStyleW500(
                                          fontSize: 14,
                                          fontColor:
                                              AppColors.redesignMutedText,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.redesignMutedText,
                                    size: 22,
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
                      controller: logic.mobileNumberCnt,
                      obscureText: false,
                      validator: (value) {
                        if (value == null) {
                          return EnumLocale.desEnterMobile.name.tr;
                        }
                        return null;
                      },
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 15,
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
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.redesignMutedText,
                      ),
                      keyboardType: TextInputType.number,
                      showCountryFlag: false,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        hintStyle: AppFontStyle.fontStyleW600(
                          fontSize: 12,
                          fontColor: AppColors.redesignMutedText,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.redesignSoftBorder,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.redesignSoftBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.redesignBrandRed,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        errorStyle: AppFontStyle.fontStyleW500(
                          fontSize: 10,
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
                        logic.mobileNumberCnt.text = phone.number;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
          Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: AppColors.redesignBrandRed,
                ),
              ),
              const SizedBox(width: 8),
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

class EditProfileSaveBar extends StatelessWidget {
  const EditProfileSaveBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      builder: (controller) {
        final width = MediaQuery.sizeOf(context).width;
        final maxContentWidth = width >= 760 ? 980.0 : width;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
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
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PrimaryAppButton(
                    onTap: () {
                      controller.onSaveProfile();
                    },
                    color: AppColors.redesignBrandRed,
                    borderRadius: 14,
                    height: 50,
                    text: EnumLocale.txtSaveProfile.name.tr,
                    textStyle: AppFontStyle.fontStyleW600(
                      fontSize: 17,
                      fontColor: AppColors.white,
                    ),
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

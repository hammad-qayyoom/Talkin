import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/forgot_password_screen/controller/forgot_password_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class ForgotPasswordAppBar extends StatelessWidget {
  const ForgotPasswordAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: Get.back,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 22,
                  color: AppColors.redesignBrandDark,
                ),
              ),
            ),
          ),
          Text(
            EnumLocale.txtForgotPassword.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 22,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordCardView extends StatelessWidget {
  const ForgotPasswordCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      builder: (logic) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Form(
            key: logic.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppColors.redesignBrandRed.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.redesignBrandRed,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  EnumLocale.txtForgotYourPassword.name.tr,
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 30,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  EnumLocale.txtForgotPassDescription.name.tr,
                  style: AppFontStyle.fontStyleW500(
                    height: 1.5,
                    fontSize: 14,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
                const SizedBox(height: 24),
                _ForgotPasswordLabel(
                  text: EnumLocale.txtEnterYourMail.name.tr,
                ),
                const SizedBox(height: 8),
                _ForgotPasswordEmailField(controller: logic.emailController),
                const SizedBox(height: 22),
                _ForgotPasswordButton(onTap: logic.onForgotPassword),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordLabel extends StatelessWidget {
  const _ForgotPasswordLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFontStyle.fontStyleW700(
        fontSize: 15,
        fontColor: AppColors.redesignBrandDark,
      ),
    );
  }
}

class _ForgotPasswordEmailField extends StatelessWidget {
  const _ForgotPasswordEmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      cursorColor: AppColors.redesignBrandDark,
      style: AppFontStyle.fontStyleW600(
        fontSize: 15,
        fontColor: AppColors.redesignBrandDark,
      ),
      decoration: InputDecoration(
        hintText: EnumLocale.txtEmailAddress.name.tr,
        hintStyle: AppFontStyle.fontStyleW500(
          fontSize: 15,
          fontColor: AppColors.redesignMutedText,
        ),
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          color: AppColors.redesignMutedText,
          size: 24,
        ),
        filled: true,
        fillColor: AppColors.redesignSurfaceInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.redesignSoftBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: AppColors.redesignBrandDark, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.redesignBrandRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.redesignBrandRed),
        ),
      ),
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.north_east_rounded, size: 22),
        label: Text(
          EnumLocale.txtVerify.name.tr,
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: AppColors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.redesignBrandDark,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

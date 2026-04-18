import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/upper_case_formatter/upper_case_formatter_class.dart';
import 'package:notisboard/ui/user_flow/registration_screen/controller/registration_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

/// =================== App Bar =================== ///
class RegistrationAppBarView extends StatelessWidget {
  const RegistrationAppBarView({super.key});

  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _surface = AppColors.white;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: Get.back,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _softBorder),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: _brandDark, size: 18),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              EnumLocale.txtRegister.name.tr,
              style: AppFontStyle.fontStyleW700(
                fontSize: 30,
                fontColor: _brandDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}

/// =================== Add Information(TextFormField) =================== ///
class RegistrationAddInfoView extends StatelessWidget {
  const RegistrationAddInfoView({super.key});

  static final Color _surface = AppColors.white;
  static final Color _softSurface = AppColors.redesignSurfaceInput;
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (logic) {
        return Form(
          key: logic.formKey,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _softBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your account',
                  style: AppFontStyle.fontStyleW700(
                      fontSize: 22, fontColor: _brandDark),
                ),
                const SizedBox(height: 6),
                Text(
                  'Simple details now, profile setup right after signup.',
                  style: AppFontStyle.fontStyleW500(
                      fontSize: 13, fontColor: _mutedText),
                ),
                const SizedBox(height: 22),
                _buildLabel(EnumLocale.txtEnterName.name.tr),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: logic.nameController,
                  textInputAction: TextInputAction.next,
                  hintText: 'Full name',
                  inputFormatters: [UpperCaseTextFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return EnumLocale.desEnterFullName.name.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel(EnumLocale.txtEnterMail.name.tr),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: logic.emailController,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.emailAddress,
                  hintText: 'Email address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return EnumLocale.desEnterEmail.name.tr;
                    } else if (!logic.isEmailValid(value)) {
                      return EnumLocale.desEnterValidEmailAddress.name.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Date of Birth'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: logic.birthDateController,
                  textInputAction: TextInputAction.next,
                  hintText: 'YYYY-MM-DD',
                  readOnly: true,
                  onTap: () => logic.onTapBirthDate(context),
                  suffixIcon: Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: _mutedText,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel(EnumLocale.txtPassword.name.tr),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: logic.passwordController,
                  textInputAction: TextInputAction.next,
                  hintText: 'Password',
                  obscureText: logic.isObscure,
                  suffixIcon: IconButton(
                    onPressed: logic.onClickObscure,
                    icon: Icon(
                      logic.isObscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: _mutedText,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return EnumLocale.desEnterPassword.name.tr;
                    } else if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Include at least one uppercase letter';
                    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Include at least one lowercase letter';
                    } else if (!RegExp(r'\d').hasMatch(value)) {
                      return 'Include at least one number';
                    } else if (!RegExp(
                            r'[!@#\$&*~%^()_+\-=\[\]{};:"\\|,.<>\/?]')
                        .hasMatch(value)) {
                      return 'Include at least one special character';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel(EnumLocale.txtConfirmPassword.name.tr),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: logic.confirmPassController,
                  textInputAction: TextInputAction.done,
                  hintText: 'Confirm password',
                  obscureText: logic.isObscure1,
                  suffixIcon: IconButton(
                    onPressed: logic.onClickObscure1,
                    icon: Icon(
                      logic.isObscure1
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: _mutedText,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return EnumLocale.desReEnterPassword.name.tr;
                    } else if (value != logic.passwordController.text) {
                      return EnumLocale.desPasswordNotMatch.name.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                GetBuilder<RegistrationController>(
                  id: Constant.idAcceptTerms,
                  builder: (controller) {
                    final bool isSelected = controller.isCheck;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: controller.onClickCheck,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: isSelected ? _brandRed : _mutedText,
                                width: 1.4,
                              ),
                              color: isSelected
                                  ? _brandRed
                                  : AppColors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.white,
                                    size: 14,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 3,
                            runSpacing: 3,
                            children: [
                              Text(
                                EnumLocale.txtAgreePrivacyPolicy.name.tr,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 13,
                                  fontColor: _brandDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.onClickPrivacyPolicy,
                                child: Text(
                                  EnumLocale.txtPrivacyPolicy.name.tr,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 13,
                                    fontColor: _brandDark,
                                    textDecoration: TextDecoration.underline,
                                    decorationColor: _brandDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                submitButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// =================== submit button =================== ///

  GetBuilder<GetxController> submitButton(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) {
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (controller.validateRegistration()) {
                await controller.signUpWithEmailPassword();
              }
            },
            icon: const Icon(Icons.north_east_rounded, size: 20),
            label: Text(
              EnumLocale.txtSubmit.name.tr,
              style: AppFontStyle.fontStyleW600(
                  fontSize: 17, fontColor: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: _brandDark,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: _brandDark),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? textInputType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: _brandDark),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        hintStyle:
            AppFontStyle.fontStyleW500(fontSize: 14, fontColor: _mutedText),
        filled: true,
        fillColor: _softSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _brandRed, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _brandRed.withValues(alpha: 0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _brandRed, width: 1.2),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class MainScreenView extends StatelessWidget {
  const MainScreenView({super.key});

  static final Color _screenBg = AppColors.redesignScreenBackground;
  static final Color _surfaceColor = AppColors.white;
  static final Color _softSurface = AppColors.redesignSurfaceInput;
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainScreenController>(
      builder: (controller) {
        final double bottomInset = MediaQuery.of(context).padding.bottom;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            color: _screenBg,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: -120,
                    right: -80,
                    child: Container(
                      height: 260,
                      width: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _brandRed.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: -100,
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _brandDark.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Notisboard",
                            style: AppFontStyle.fontStyleKaushanW400(
                              fontSize: 58,
                              fontColor: _brandDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Welcome back",
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 30,
                            fontColor: _brandDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Login to continue with secure and fast access.",
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _surfaceColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _softBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(EnumLocale.txtEnterYourMail.name.tr),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: controller.emailController,
                                hintText: 'Email address',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icon(
                                  Icons.mail_outline_rounded,
                                  color: _mutedText,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel(EnumLocale.txtEnterPassword.name.tr),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: controller.passwordController,
                                hintText: 'Password',
                                textInputAction: TextInputAction.done,
                                obscureText: controller.isObscure,
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: _mutedText,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: controller.onClickObscure,
                                  icon: Icon(
                                    controller.isObscure
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: _mutedText,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Get.toNamed(
                                      AppRoutes.forgotPasswordScreen,
                                      arguments: {
                                        'email': controller.emailController.text
                                            .trim(),
                                      },
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 6),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    EnumLocale.forgotPassword.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 13,
                                      fontColor: _brandDark,
                                      textDecoration: TextDecoration.underline,
                                      decorationColor: _brandDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPrimaryButton(
                                text: EnumLocale.txtContinue.name.tr,
                                backgroundColor: _brandDark,
                                icon: Icons.north_east_rounded,
                                onTap: () {
                                  if (controller.validateLogin()) {
                                    controller.onClickSignIn();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Text(
                                EnumLocale.txtYouHaveNewUser.name.tr,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 13,
                                  fontColor: _mutedText,
                                ),
                              ),
                              InkWell(
                                onTap: () => Get.toNamed(AppRoutes.register),
                                child: Text(
                                  EnumLocale.txtGetRegister.name.tr,
                                  style: AppFontStyle.fontStyleW700(
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
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                                child:
                                    Divider(color: _softBorder, thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "or continue with",
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 12,
                                  fontColor: _mutedText,
                                ),
                              ),
                            ),
                            Expanded(
                                child:
                                    Divider(color: _softBorder, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildPrimaryButton(
                          text: EnumLocale.txtQuickLogin.name.tr,
                          backgroundColor: _brandRed,
                          icon: Icons.rocket_launch_rounded,
                          onTap: controller.onQuickLogin1,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
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
      style: AppFontStyle.fontStyleW600(
        fontSize: 13,
        fontColor: _brandDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: _brandDark),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintStyle: AppFontStyle.fontStyleW500(
          fontSize: 14,
          fontColor: _mutedText,
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _softBorder),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required Color backgroundColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: AppFontStyle.fontStyleW600(
              fontSize: 17, fontColor: AppColors.white),
        ),
      ),
    );
  }
}

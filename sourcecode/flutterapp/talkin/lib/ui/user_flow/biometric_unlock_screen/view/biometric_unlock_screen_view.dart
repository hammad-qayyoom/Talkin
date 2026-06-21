import 'package:notisboard/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/services/biometric/biometric_auth_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class BiometricUnlockScreenView extends StatefulWidget {
  const BiometricUnlockScreenView({super.key});

  @override
  State<BiometricUnlockScreenView> createState() =>
      _BiometricUnlockScreenViewState();
}

class _BiometricUnlockScreenViewState extends State<BiometricUnlockScreenView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final ok = await BiometricAuthService.authenticate(
      reason: 'Authenticate to continue',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      final nextRoute =
          (Get.arguments?['nextRoute'] ?? AppRoutes.bottomBar).toString();
      Get.offAllNamed(nextRoute);
    } else {
      Utils.showToast(context, 'Biometric authentication failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fingerprint_rounded,
                  size: 64,
                  color: AppColors.redesignBrandDark,
                ),
                const SizedBox(height: 12),
                Text(
                  EnumLocale.txtAuthenticateToContinue.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  EnumLocale.txtUseFaceIdTouchIdFingerprintToUnlockYourAccount.name.tr,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 14,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redesignBrandDark,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_isLoading ? 'Authenticating...' : 'Try Again'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.main),
                  child: Text(
                    EnumLocale.txtLoginNormally.name.tr,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 14,
                      fontColor: AppColors.redesignBrandRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

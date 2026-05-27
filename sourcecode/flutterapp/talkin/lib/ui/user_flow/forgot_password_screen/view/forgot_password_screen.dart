import 'package:flutter/material.dart';
import 'package:notisboard/ui/user_flow/forgot_password_screen/widget/forgot_password_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -130,
                right: -80,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.redesignBrandRed.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 110,
                left: -95,
                child: Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.redesignBrandDark.withValues(alpha: 0.05),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ForgotPasswordAppBar(),
                    SizedBox(height: 18),
                    ForgotPasswordCardView(),
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

import 'package:flutter/material.dart';
import 'package:notisboard/ui/user_flow/registration_screen/widget/registration_screen_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

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
                left: -80,
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
                top: 120,
                right: -90,
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
                child: Column(
                  children: const [
                    RegistrationAppBarView(),
                    SizedBox(height: 18),
                    RegistrationAddInfoView(),
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

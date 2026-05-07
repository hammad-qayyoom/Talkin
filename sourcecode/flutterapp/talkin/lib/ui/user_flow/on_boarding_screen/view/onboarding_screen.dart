import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/dialog/exit_app_dialog.dart';
import 'package:notisboard/ui/user_flow/on_boarding_screen/widget/on_boarding_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || (Get.isDialogOpen ?? false)) {
          return;
        }

        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: const OnBoardingView(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_background/app_background.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/ui/user_flow/delete_account_otp_screen/controller/delete_account_otp_controller.dart';
import 'package:notisboard/ui/user_flow/delete_account_otp_screen/widget/delete_account_otp_widget.dart';
import 'package:notisboard/utils/constant.dart';

class DeleteAccountOtpScreen extends StatelessWidget {
  const DeleteAccountOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeleteAccountOtpController>(
      id: Constant.idLoginOrSignUp,
      builder: (logic) {
        return ProgressDialog(
          inAsyncCall: logic.isLoading,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            // backgroundColor: AppColors.lightPurple,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: const DeleteAccountOtpAppBar(),
            ),
            body: AppBackground(
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     // stops: [0.2, 0.4, 0.5, 0],
              //     end: Alignment.bottomCenter,
              //     begin: Alignment.topCenter,
              //     colors: [
              //       // AppColors.red,
              //       // AppColors.green,
              //       // AppColors.chatPink,
              //       // AppColors.chatPink,
              //       // AppColors.blue,
              //       // AppColors.blue,
              //
              //       // Color(0xffF1EDFF).withValues(alpha: 0.4),
              //       Color(0xffF4F6FF).withValues(alpha: 0.5),
              //       Color(0xffF7FAFF),
              //       Color(0xffFFFFFF),
              //       Color(0xffFFFFFF),
              //       Color(0xffFFFFFF),
              //     ],
              //   ),
              // ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DeleteAccountOtpView(),
                  DeleteAccountOtpWidget(),
                  // VerifyOtpResendOTPView(),
                  Spacer(),
                  DeleteAccountOtpButtonView(),
                  Spacer(),
                ],
              ).paddingOnly(left: 16, right: 16, top: 18),
            ),
          ),
        );
      },
    );
  }
}

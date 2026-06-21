import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:notisboard/custom/app_bar/custom_app_bar.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/ui/user_flow/delete_account_otp_screen/controller/delete_account_otp_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class DeleteAccountOtpAppBar extends StatelessWidget {
  const DeleteAccountOtpAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: "Delete Account",
      showLeadingIcon: true,
    );
  }
}

class DeleteAccountOtpView extends StatelessWidget {
  const DeleteAccountOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verify Deletion",
          style: AppFontStyle.fontStyleW800(
            fontSize: 30,
            fontColor: AppColors.appColor,
          ),
        ).paddingOnly(bottom: 6),
        Text(
          "An OTP has been sent to your email. Please enter it below to confirm your account deletion.",
          style: AppFontStyle.fontStyleW400(
            height: 1.9,
            fontSize: 12,
            fontColor: AppColors.grey,
          ),
        ).paddingOnly(right: 30),
      ],
    );
  }
}

class DeleteAccountOtpWidget extends StatelessWidget {
  const DeleteAccountOtpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeleteAccountOtpController>(
      id: Constant.idResendOtp,
      builder: (logic) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              EnumLocale.txtEnterOtp.name.tr,
              style: AppFontStyle.fontStyleW500(
                  fontSize: 13, fontColor: AppColors.black),
            ).paddingOnly(top: 36),
            Pinput(
              cursor: Container(
                width: 1,
                height: 15,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              length: 6,
              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.black,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black),
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              pinAnimationType: PinAnimationType.fade,
              controller: logic.otpController,
              focusedPinTheme: PinTheme(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ).paddingOnly(top: 17, bottom: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  logic.formattedCountdown,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 13,
                    fontColor: AppColors.otpScreenGrey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (logic.countdown == 0) {
                      logic.resendOtp();
                    }
                  },
                  child: Text(
                    "Resend OTP",
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13,
                      fontColor: logic.countdown == 0 ? AppColors.appColor : AppColors.grey,
                      textDecoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class DeleteAccountOtpButtonView extends StatelessWidget {
  const DeleteAccountOtpButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeleteAccountOtpController>(
      id: Constant.idVerifyOtp,
      builder: (logic) {
        return Center(
          child: PrimaryAppButton(
            height: 50,
            onTap: () => logic.verifyOtp(),
            text: "Verify & Delete",
            textStyle: AppFontStyle.fontStyleW500(
                fontSize: 16, fontColor: AppColors.white),
            color: Colors.red,
          ).paddingOnly(bottom: 15, left: 20, right: 20),
        );
      },
    );
  }
}

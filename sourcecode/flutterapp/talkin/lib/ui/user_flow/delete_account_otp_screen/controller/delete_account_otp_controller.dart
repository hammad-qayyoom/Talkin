import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/setting_screen/api/request_delete_otp_api.dart';
import 'package:notisboard/ui/user_flow/setting_screen/api/verify_delete_otp_api.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:notisboard/routes/app_routes.dart';

class DeleteAccountOtpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  int countdown = 0;
  bool isOtpExpired = false;

  Timer? timer;
  bool isLoading = false;

  TextEditingController otpController = TextEditingController();

  @override
  void onInit() {
    startCountdown();
    super.onInit();
  }

  @override
  void dispose() {
    otpController.clear();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final smsCode = otpController.text.trim();

    if (smsCode.isEmpty) {
      Utils.showToast(Get.context!, "Please enter OTP");
      return;
    }

    if (isOtpExpired) {
      Utils.showToast(Get.context!, "OTP expired. Please request a new one.");
      return;
    }

    isLoading = true;
    update([Constant.idVerifyOtp]);

    try {
      final response = await VerifyDeleteOtpApi.callApi(otp: smsCode);

      if (response != null && response.status == true) {
        Utils.showToast(Get.context!, response.message ?? "Account deleted successfully.");
        // Clear login session and go to splash or login
        Database.onLogOut();

        Get.offAllNamed(AppRoutes.splashScreenPage);
      } else {
        Utils.showToast(Get.context!, response?.message ?? "Invalid OTP or Something went wrong.");
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Something went wrong");
    } finally {
      isLoading = false;
      update([Constant.idVerifyOtp]);
    }
  }

  Future<void> resendOtp() async {
    isLoading = true;
    update([Constant.idVerifyOtp]);

    try {
      final response = await RequestDeleteOtpApi.callApi();
      if (response != null && response.status == true) {
        Utils.showToast(Get.context!, response.message ?? "OTP sent to your email.");
        isOtpExpired = false;
        startCountdown();
      } else {
        Utils.showToast(Get.context!, response?.message ?? "Failed to resend OTP.");
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Something went wrong.");
    } finally {
      isLoading = false;
      update([Constant.idVerifyOtp]);
    }
  }

  String get formattedCountdown {
    final minutes = (countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startCountdown() {
    countdown = 600; // 10 minutes
    update([Constant.idResendOtp]);

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown > 0) {
        countdown--;
        update([Constant.idResendOtp]);
      } else {
        isOtpExpired = true;
        t.cancel();
        update([Constant.idResendOtp]);
      }
    });
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }
}

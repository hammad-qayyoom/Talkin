import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/forgot_pass_verify_otp_screen/controller/forgot_pass_verify_otp_controller.dart';

class ForgotPassVerifyOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPassVerifyOtpController>(
        () => ForgotPassVerifyOtpController());
  }
}

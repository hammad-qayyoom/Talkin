import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/delete_account_otp_screen/controller/delete_account_otp_controller.dart';

class DeleteAccountOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteAccountOtpController>(
        () => DeleteAccountOtpController());
  }
}

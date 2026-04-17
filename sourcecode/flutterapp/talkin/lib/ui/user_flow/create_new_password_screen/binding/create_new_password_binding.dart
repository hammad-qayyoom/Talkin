import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/create_new_password_screen/controller/create_new_passwoed_controller.dart';

class CreateNewPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewPasswordController>(() => CreateNewPasswordController());
  }
}

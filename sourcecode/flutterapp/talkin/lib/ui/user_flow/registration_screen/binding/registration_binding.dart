import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/registration_screen/controller/registration_controller.dart';

class RegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegistrationController>(() => RegistrationController());
  }
}

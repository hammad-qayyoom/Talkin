import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/select_gender_screen/controller/select_gender_screen_controller.dart';

class SelectGenderScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectGenderScreenController>(() => SelectGenderScreenController());
  }
}

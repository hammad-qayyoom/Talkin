import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/calling_screen/controller/calling_screen_controller.dart';

class CallingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallingScreenController>(() => CallingScreenController());
  }
}

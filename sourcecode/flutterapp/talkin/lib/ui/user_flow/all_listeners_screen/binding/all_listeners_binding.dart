import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/all_listeners_screen/controller/all_listeners_controller.dart';

class AllListenersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllListenersController>(() => AllListenersController());
  }
}

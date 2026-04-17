import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';

class ListenersScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListenersScreenController>(() => ListenersScreenController());
  }
}

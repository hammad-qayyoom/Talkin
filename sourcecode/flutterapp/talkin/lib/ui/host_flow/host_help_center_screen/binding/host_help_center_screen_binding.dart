import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_help_center_screen/controller/host_help_center_screen_controller.dart';

class HostHelpCenterScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostHelpCenterScreenController>(() => HostHelpCenterScreenController());
  }
}

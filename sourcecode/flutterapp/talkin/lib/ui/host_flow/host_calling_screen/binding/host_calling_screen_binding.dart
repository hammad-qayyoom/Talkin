import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_calling_screen/controller/host_calling_screen_controller.dart';

class HostCallingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostCallingScreenController>(() => HostCallingScreenController());
  }
}

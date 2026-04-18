import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_listeners_detail_screen/controller/host_listeners_detail_controller.dart';

class HostListenersDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostListenersDetailController>(
        () => HostListenersDetailController());
  }
}

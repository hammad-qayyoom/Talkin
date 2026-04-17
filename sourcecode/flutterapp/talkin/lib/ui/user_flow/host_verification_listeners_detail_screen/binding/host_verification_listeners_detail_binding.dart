import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';

class HostVerificationListenersDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostVerificationController>(() => HostVerificationController());
  }
}

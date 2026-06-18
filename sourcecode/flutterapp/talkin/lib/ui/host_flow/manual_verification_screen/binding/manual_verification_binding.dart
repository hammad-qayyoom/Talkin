import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/manual_verification_screen/controller/manual_verification_controller.dart';

class ManualVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualVerificationController>(() => ManualVerificationController());
  }
}

import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fake_outgoing_call_screen/controller/fake_outgoing_call_controller.dart';

class FakeOutgoingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FakeOutgoingCallController>(() => FakeOutgoingCallController());
  }
}

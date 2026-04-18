import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';

class HostPersonalChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostPersonalChatScreenController>(
        () => HostPersonalChatScreenController());
  }
}

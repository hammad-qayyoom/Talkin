import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';

class PersonalChatScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalChatScreenController>(
        () => PersonalChatScreenController());
  }
}

import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';

class EditProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}

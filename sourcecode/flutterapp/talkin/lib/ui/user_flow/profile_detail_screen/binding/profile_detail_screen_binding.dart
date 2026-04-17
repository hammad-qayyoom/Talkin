import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';

class ProfileDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileDetailScreenController>(() => ProfileDetailScreenController());
  }
}

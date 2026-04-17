import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/setting_screen/controller/setting_controller.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(() => SettingController());
    // Get.lazyPut<SellerEditProfileController>(() => SellerEditProfileController());
  }
}

import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/controller/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(() => SplashScreenController());
  }
}

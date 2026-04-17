import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/feed_screen/controller/feed_screen_controller.dart';

class FeedScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedScreenController>(() => FeedScreenController());
  }
}

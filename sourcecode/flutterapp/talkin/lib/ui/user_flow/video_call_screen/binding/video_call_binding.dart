import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/video_call_screen/controller/video_call_controller.dart';

class VideoCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoCallController>(() => VideoCallController());
  }
}

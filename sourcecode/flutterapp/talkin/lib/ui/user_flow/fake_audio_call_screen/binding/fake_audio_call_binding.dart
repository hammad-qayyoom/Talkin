import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fake_audio_call_screen/controller/fake_audio_call_controller.dart';

class FakeAudioCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FakeAudioCallController>(() => FakeAudioCallController());
  }
}

import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_notification/controller/host_notification_controller.dart';

class HostNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostNotificationController>(() => HostNotificationController());
  }
}

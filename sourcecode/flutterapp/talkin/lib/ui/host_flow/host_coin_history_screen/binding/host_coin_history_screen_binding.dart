import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_coin_history_screen/controller/host_coin_history_screen_controller.dart';

class HostCoinHistoryScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostCoinHistoryScreenController>(
        () => HostCoinHistoryScreenController());
  }
}

import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_wallet_screen/controller/host_wallet_screen_controller.dart';

class HostWalletScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostWalletScreenController>(() => HostWalletScreenController());
  }
}

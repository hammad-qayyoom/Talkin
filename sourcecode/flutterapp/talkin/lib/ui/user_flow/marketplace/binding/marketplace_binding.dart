import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_controller.dart';

class MarketplaceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MarketplaceCartController>()) {
      Get.put(MarketplaceCartController(), permanent: true);
    }
    Get.lazyPut<MarketplaceController>(() => MarketplaceController());
  }
}


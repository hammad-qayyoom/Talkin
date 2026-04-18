import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/coin_purchase_screen/controller/coin_purchase_screen_controller.dart';

class CoinPurchaseScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinPurchaseScreenController>(
        () => CoinPurchaseScreenController());
  }
}

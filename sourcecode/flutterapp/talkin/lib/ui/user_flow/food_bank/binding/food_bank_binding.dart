import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/food_bank/controller/food_bank_controller.dart';
import 'package:notisboard/ui/user_flow/food_bank/controller/food_bank_history_controller.dart';

class FoodBankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoodBankController>(() => FoodBankController(), fenix: true);
    Get.lazyPut<FoodBankHistoryController>(() => FoodBankHistoryController(), fenix: true);
  }
}


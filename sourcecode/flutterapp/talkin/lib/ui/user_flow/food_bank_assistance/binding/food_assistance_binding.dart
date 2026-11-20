import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/controller/food_assistance_controller.dart';

class FoodAssistanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FoodAssistanceController>(() => FoodAssistanceController());
  }
}


import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/search_screen/controller/search_screen_controller.dart';

class SearchScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchScreenController>(() => SearchScreenController());
  }
}

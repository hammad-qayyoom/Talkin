import 'package:get/get.dart';
import 'package:notisboard/ui/common/blog_news/controller/blog_news_controller.dart';

class BlogNewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlogNewsController>(() => BlogNewsController());
  }
}

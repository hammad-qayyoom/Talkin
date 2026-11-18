import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fundraising/api/fundraising_api.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';

class ProgramDetailController extends GetxController {
  final isLoading = true.obs;
  final program = Rxn<FoundationProgram>();

  String slug = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FoundationProgram) {
      program.value = args;
      slug = args.slug;
      isLoading.value = false;
      loadProgramDetail();
    } else if (args is String) {
      slug = args;
      loadProgramDetail();
    }
  }

  Future<void> loadProgramDetail() async {
    if (slug.isEmpty) return;
    try {
      final res = await FundraisingApi.fetchProgramDetail(slug);
      if (res != null) {
        program.value = res;
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }
}


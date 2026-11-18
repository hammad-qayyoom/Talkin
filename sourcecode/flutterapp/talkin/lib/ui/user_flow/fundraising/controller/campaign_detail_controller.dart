import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fundraising/api/fundraising_api.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';

class CampaignDetailController extends GetxController {
  final isLoading = true.obs;
  final campaign = Rxn<FundraisingCampaign>();
  final selectedTabIndex = 0.obs; // 0: Story, 1: Updates, 2: Supporters
  final selectedTier = Rxn<CampaignTier>();

  String slug = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FundraisingCampaign) {
      campaign.value = args;
      slug = args.slug;
      isLoading.value = false;
      loadCampaignDetail(); // Fetch fresh updates & donor wall
    } else if (args is String) {
      slug = args;
      loadCampaignDetail();
    }
  }

  Future<void> loadCampaignDetail() async {
    if (slug.isEmpty) return;
    try {
      final res = await FundraisingApi.fetchCampaignDetail(slug);
      if (res != null) {
        campaign.value = res;
      }
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  void selectTier(CampaignTier? tier) {
    selectedTier.value = tier;
  }
}


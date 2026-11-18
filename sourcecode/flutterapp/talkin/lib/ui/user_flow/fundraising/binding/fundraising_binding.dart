import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/campaign_detail_controller.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/donation_controller.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/fundraising_controller.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/my_donations_controller.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/program_detail_controller.dart';

class FundraisingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FundraisingController>(() => FundraisingController(), fenix: true);
    Get.lazyPut<CampaignDetailController>(() => CampaignDetailController(), fenix: true);
    Get.lazyPut<ProgramDetailController>(() => ProgramDetailController(), fenix: true);
    Get.lazyPut<DonationController>(() => DonationController(), fenix: true);
    Get.lazyPut<MyDonationsController>(() => MyDonationsController(), fenix: true);
  }
}

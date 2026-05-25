import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/referral_screen/api/referral_summary_api.dart';
import 'package:notisboard/ui/user_flow/referral_screen/model/referral_summary_model.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:share_plus/share_plus.dart';

class ReferralController extends GetxController {
  bool isLoading = false;
  ReferralSummaryData? summary;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadReferralSummary();
  }

  Future<void> loadReferralSummary() async {
    isLoading = true;
    errorMessage = null;
    update();

    final response = await ReferralSummaryApi.callApi();

    isLoading = false;
    if (response?.status == true && response?.data != null) {
      summary = response!.data;
    } else {
      errorMessage = response?.message ?? 'Unable to load referral details.';
    }
    update();
  }

  Future<void> copyCode() async {
    final code = summary?.referralCode.trim() ?? '';
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    _toast('Referral code copied.');
  }

  Future<void> copyLink() async {
    final link = summary?.referralLink.trim() ?? '';
    if (link.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: link));
    _toast('Referral link copied.');
  }

  Future<void> shareReferral() async {
    final data = summary;
    if (data == null) return;

    final shareText = [
      'Join me on Notisboard and talk to trusted experts.',
      if (data.referralCode.trim().isNotEmpty)
        'Use my referral code: ${data.referralCode.trim()}',
      if (data.referralLink.trim().isNotEmpty) data.referralLink.trim(),
    ].join('\n\n');

    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  String get userDisplayName {
    final name = Database.loginUserName.trim();
    return name.isEmpty ? 'there' : name;
  }

  String formatReward(num value, String currency) {
    final displayValue =
        value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
    return '$displayValue $currency';
  }

  void _toast(String message) {
    final context = Get.context;
    if (context == null) return;
    Utils.showToast(context, message);
  }
}

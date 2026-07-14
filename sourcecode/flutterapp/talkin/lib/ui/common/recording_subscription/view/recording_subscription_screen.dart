import 'package:flutter/material.dart';
import 'package:notisboard/ui/common/recording_subscription/api/recording_subscription_api.dart';
import 'package:notisboard/ui/common/recording_subscription/model/recording_subscription_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class RecordingSubscriptionScreen extends StatefulWidget {
  const RecordingSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<RecordingSubscriptionScreen> createState() => _RecordingSubscriptionScreenState();
}

class _RecordingSubscriptionScreenState extends State<RecordingSubscriptionScreen> {
  bool isLoading = true;
  bool isPurchasing = false;
  RecordingSubscriptionModel? subscription;
  String status = "none";
  bool hasActivePlan = false;
  
  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => isLoading = true);
    final response = await RecordingSubscriptionApi.getSubscriptionStatus();
    if (response != null && response['status'] == true) {
      if (response['subscription'] != null) {
        subscription = RecordingSubscriptionModel.fromJson(response['subscription']);
      }
      status = response['subscriptionStatus'] ?? "none";
      hasActivePlan = response['hasSubscription'] ?? false;
    }
    setState(() => isLoading = false);
  }

  Future<void> _purchasePlan() async {
    setState(() => isPurchasing = true);
    final res = await RecordingSubscriptionApi.purchasePlan();
    setState(() => isPurchasing = false);
    if (res != null) {
      Utils.showToast("Subscription Activated Successfully!");
      _fetchStatus();
    } else {
      Utils.showToast("Failed to purchase subscription.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.redesignScreenBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.redesignBrandDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Recording Storage",
          style: AppFontStyle.redesignTextMeta.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.redesignBrandRed))
        : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 24),
          Text(
            "Plan Benefits",
            style: AppFontStyle.redesignTextStrong.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(Icons.cloud_done_rounded, "Secure Cloud Storage for all recordings"),
          _buildBenefitItem(Icons.history_rounded, "30-day access to replay consultation sessions"),
          _buildBenefitItem(Icons.privacy_tip_rounded, "Mutual consent enforced for privacy"),
          const SizedBox(height: 40),
          _buildPurchaseAction(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color cardColor = AppColors.white;
    Color iconColor = AppColors.redesignBrandDark;
    IconData icon = Icons.cloud_off_rounded;
    String title = "No Active Plan";
    String subtitle = "Get a storage plan to enable consultation recording.";

    if (hasActivePlan && status == "active") {
      cardColor = AppColors.redesignStatusSuccessBg;
      iconColor = AppColors.redesignStatusSuccessDark;
      icon = Icons.cloud_done_rounded;
      title = "Active Subscription";
      
      final days = subscription?.endsAt?.difference(DateTime.now()).inDays ?? 0;
      subtitle = "Valid for $days more days.";
    } else if (status == "grace_period") {
      cardColor = AppColors.redesignAccentSoftBg;
      iconColor = AppColors.redesignBrandRed;
      icon = Icons.lock_clock_rounded;
      title = "Grace Period Active";
      
      final days = subscription?.gracePeriodEndsAt?.difference(DateTime.now()).inDays ?? 0;
      subtitle = "Your recordings are locked. Renew within $days days to prevent deletion.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFontStyle.redesignTextStrong.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFontStyle.redesignMutedText.copyWith(fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.redesignBrandRed, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppFontStyle.redesignTextMeta.copyWith(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPurchaseAction() {
    final bool isRenewal = status == "grace_period" || status == "expired";
    final String btnText = hasActivePlan 
      ? "Extend Plan (+30 Days)" 
      : isRenewal ? "Renew Subscription (\$4.99/mo)" : "Subscribe Now (\$4.99/mo)";

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redesignBrandRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: isPurchasing ? null : _purchasePlan,
        child: isPurchasing 
          ? const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              btnText,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }
}

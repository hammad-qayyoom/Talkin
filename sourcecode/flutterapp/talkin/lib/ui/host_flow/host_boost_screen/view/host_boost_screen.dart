import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_boost_screen/api/boost_api.dart';
import 'package:notisboard/ui/host_flow/host_boost_screen/controller/host_boost_screen_controller.dart';
import 'package:notisboard/utils/app_color.dart';

class HostBoostScreen extends StatelessWidget {
  const HostBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostBoostScreenController>(
      init: HostBoostScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.redesignScreenBackground,
          appBar: AppBar(
            title: const Text("Boost Profile"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderBanner(controller),
                        const SizedBox(height: 20),
                        if (controller.activeBoost != null) ...[
                          _buildActiveBoostCard(controller),
                          const SizedBox(height: 20),
                        ],
                        _buildWalletBalanceCard(controller),
                        const SizedBox(height: 20),
                        _buildPlansSection(controller),
                        const SizedBox(height: 20),
                        if (controller.analytics != null) ...[
                          _buildAnalyticsSection(controller),
                          const SizedBox(height: 20),
                        ],
                        _buildHowItWorksSection(),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeaderBanner(HostBoostScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.redesignBrandRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Boost Your Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Get more visibility and bookings",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBoostCard(HostBoostScreenController controller) {
    final boost = controller.activeBoost!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.redesignStatusSuccessBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "Active",
                  style: TextStyle(
                    color: AppColors.redesignStatusSuccessDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${boost.planName ?? ''} Boost",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(Icons.timer, "${boost.daysRemaining ?? '0'} days left"),
              const SizedBox(width: 8),
              _buildStatChip(Icons.visibility, "${boost.visibilityMultiplier ?? 1.0}x Visibility"),
            ],
          ),
          const SizedBox(height: 12),
          if (boost.metadata != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric("Views", "${boost.metadata!.profileViews ?? 0}"),
                _buildMetric("Impressions", "${boost.metadata!.impressions ?? 0}"),
                _buildMetric("Bookings", "${boost.metadata!.bookingsGenerated ?? 0}"),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showExtendBoostSheet(controller),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text("Extend Boost"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.redesignMutedText),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.redesignMutedText)),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.redesignMutedText)),
      ],
    );
  }

  Widget _buildWalletBalanceCard(HostBoostScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: AppColors.redesignCoinText, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Available Credits",
                  style: TextStyle(fontSize: 13, color: AppColors.redesignMutedText),
                ),
                Text(
                  controller.walletBalance % 1 == 0
                      ? controller.walletBalance.toInt().toString()
                      : controller.walletBalance.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.redesignCoinText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection(HostBoostScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Available Plans",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...controller.boostPlans.map((plan) => _buildPlanCard(controller, plan)),
      ],
    );
  }

  Widget _buildPlanCard(HostBoostScreenController controller, BoostPlanModel plan) {
    final canAfford = controller.walletBalance >= (plan.creditCost ?? 0);
    final hasActiveBoost = controller.activeBoost != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.durationLabel ?? '',
                  style: TextStyle(fontSize: 13, color: AppColors.redesignMutedText),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.redesignStatusSuccessBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "${plan.visibilityMultiplier ?? 1.5}x Visibility",
                        style: TextStyle(
                          color: AppColors.redesignStatusSuccessDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${plan.creditCost ?? 0} credits",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.redesignCoinText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: canAfford && !controller.isActivating
                ? () => _handleActivate(controller, plan)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redesignBrandDark,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isActivating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    hasActiveBoost ? "Extend" : "Activate",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(HostBoostScreenController controller) {
    final totals = controller.analytics!.totals;
    if (totals == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Performance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.redesignSoftBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnalyticsMetric("Impressions", "${totals.impressions ?? 0}"),
                  _buildAnalyticsMetric("Profile Views", "${totals.profileViews ?? 0}"),
                  _buildAnalyticsMetric("Bookings", "${totals.bookingsGenerated ?? 0}"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Conversion Rate: ${totals.conversionRate ?? '0%'}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.redesignBrandDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.redesignMutedText)),
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How It Works",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildStepTile(1, "Choose a boost plan that fits your goals"),
        _buildStepTile(2, "Credits are deducted from your wallet balance"),
        _buildStepTile(3, "Your profile ranks higher in search results"),
      ],
    );
  }

  Widget _buildStepTile(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.redesignBrandRed,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$step",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showExtendBoostSheet(HostBoostScreenController controller) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Extend Your Boost",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Add more time to your current boost",
                style: TextStyle(fontSize: 13, color: AppColors.redesignMutedText),
              ),
              const SizedBox(height: 16),
              ...controller.boostPlans.map(
                (plan) => ListTile(
                  title: Text(plan.name ?? ''),
                  subtitle: Text("${plan.creditCost ?? 0} credits"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.extendBoost(plan.id ?? '');
                    },
                    child: const Text("Extend"),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _handleActivate(HostBoostScreenController controller, BoostPlanModel plan) {
    final screenWidth = MediaQuery.sizeOf(Get.context!).width;
    final constrainedWidth = (screenWidth - 32).clamp(280.0, 430.0);

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Center(
          child: Container(
            width: constrainedWidth,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: AppColors.redesignSoftBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.redesignSheetHandle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 86,
                    width: 86,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.redesignBrandRed,
                          AppColors.redesignBrandRedDark,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.redesignBrandRed.withValues(alpha: 0.34),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.bolt, color: Colors.white, size: 44),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Activate Boost",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.redesignBrandDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Activate ${plan.name} for ${plan.creditCost} credits?\nThis will boost your profile visibility by ${plan.visibilityMultiplier}x.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.redesignMutedText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        controller.activateBoost(plan.id ?? '');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redesignBrandRed,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Activate",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.redesignSurfaceInput,
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: AppColors.redesignBrandDark,
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

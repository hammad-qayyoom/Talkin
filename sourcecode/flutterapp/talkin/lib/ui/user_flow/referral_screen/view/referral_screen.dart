import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/ui/user_flow/referral_screen/controller/referral_controller.dart';
import 'package:notisboard/ui/user_flow/referral_screen/model/referral_summary_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class ReferralScreen extends GetView<ReferralController> {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<ReferralController>(
          builder: (_) {
            return RefreshIndicator(
              color: AppColors.redesignBrandRed,
              onRefresh: controller.loadReferralSummary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _Header()),
                  if (controller.isLoading && controller.summary == null)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (controller.errorMessage != null &&
                      controller.summary == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ErrorState(message: controller.errorMessage!),
                    )
                  else
                    SliverToBoxAdapter(
                      child: _ReferralContent(
                        data: controller.summary,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: Get.back,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.redesignSoftBorder),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.redesignBrandDark,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite & Earn',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 26,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share Notisboard and track referral rewards',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralContent extends GetView<ReferralController> {
  const _ReferralContent({required this.data});

  final ReferralSummaryData? data;

  @override
  Widget build(BuildContext context) {
    final summary = data;
    if (summary == null) {
      return const SizedBox.shrink();
    }

    final rewardSettings = summary.rewardSettings;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(summary: summary),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Referrals',
                  value: summary.totalReferrals.toString(),
                  icon: Icons.people_alt_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Approved',
                  value: controller.formatReward(
                    summary.approvedRewards,
                    rewardSettings.currency,
                  ),
                  icon: Icons.verified_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Pending',
                  value: controller.formatReward(
                    summary.pendingRewards,
                    rewardSettings.currency,
                  ),
                  icon: Icons.hourglass_bottom_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Paid',
                  value: controller.formatReward(
                    summary.paidRewards,
                    rewardSettings.currency,
                  ),
                  icon: Icons.payments_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RuleCard(settings: rewardSettings),
          const SizedBox(height: 16),
          Text(
            'Referral Activity',
            style: AppFontStyle.fontStyleW700(
              fontSize: 18,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 10),
          if (summary.records.isEmpty)
            const _EmptyRecords()
          else
            ...summary.records.map(_RecordTile.new),
        ],
      ),
    );
  }
}

class _HeroCard extends GetView<ReferralController> {
  const _HeroCard({required this.summary});

  final ReferralSummaryData summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.redesignBrandRed.withValues(alpha: 0.24),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your referral code',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: AppColors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.referralCode.isEmpty
                          ? 'Generating...'
                          : summary.referralCode,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 30,
                        fontColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              summary.referralLink.isEmpty
                  ? 'Referral link will appear here'
                  : summary.referralLink,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.fontStyleW500(
                fontSize: 12,
                fontColor: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroAction(
                  label: 'Copy Code',
                  icon: Icons.copy_rounded,
                  onTap: controller.copyCode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroAction(
                  label: 'Share',
                  icon: Icons.ios_share_rounded,
                  onTap: controller.shareReferral,
                  isPrimary: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HeroAction(
            label: 'Copy Referral Link',
            icon: Icons.link_rounded,
            onTap: controller.copyLink,
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.redesignBrandDark
                : AppColors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.redesignBrandRed, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW700(
              fontSize: 19,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: AppFontStyle.fontStyleW500(
              fontSize: 12,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.settings});

  final ReferralRewardSettings settings;

  String get _triggerLabel {
    switch (settings.triggerType) {
      case 'signup':
        return 'after successful signup';
      case 'completed_session':
        return 'after first completed session';
      case 'subscription':
      default:
        return 'after successful subscription';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reward = settings.amount % 1 == 0
        ? settings.amount.toInt().toString()
        : settings.amount.toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppColors.redesignBrandRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward rule',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 15,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Earn $reward ${settings.currency} $_triggerLabel.',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: AppColors.redesignMutedText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile(this.record);

  final ReferralRecordItem record;

  Color get _statusColor {
    switch (record.rewardStatus) {
      case 'approved':
      case 'paid':
        return const Color(0xFF16A34A);
      case 'rejected':
        return AppColors.redesignBrandRed;
      case 'pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = record.createdAt == null
        ? ''
        : DateFormat('MMM d, yyyy').format(record.createdAt!);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.referredUserName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  createdAt.isEmpty
                      ? record.rewardTriggerType
                      : '${record.rewardTriggerType} • $createdAt',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              record.rewardStatus.capitalizeFirst ?? record.rewardStatus,
              style: AppFontStyle.fontStyleW700(
                fontSize: 11,
                fontColor: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  const _EmptyRecords();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.group_add_rounded,
              color: AppColors.redesignBrandRed,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No referrals yet',
            style: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Share your code with friends. Referral activity will appear here.',
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW500(
              fontSize: 12,
              fontColor: AppColors.redesignMutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends GetView<ReferralController> {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.redesignBrandRed,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW600(
              fontSize: 14,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: controller.loadReferralSummary,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redesignBrandDark,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

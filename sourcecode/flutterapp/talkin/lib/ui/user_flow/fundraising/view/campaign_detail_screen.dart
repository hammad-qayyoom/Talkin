import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/campaign_detail_controller.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/ui/user_flow/fundraising/shimmer/fundraising_shimmer.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class CampaignDetailScreen extends GetView<CampaignDetailController> {
  const CampaignDetailScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.isLoading.value && controller.campaign.value == null) {
          return const CampaignDetailShimmer();
        }

        final campaign = controller.campaign.value;
        if (campaign == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Campaign Details')),
            body: const Center(child: Text('Campaign not found.')),
          );
        }

        final currencySymbol = campaign.currency == 'CAD'
            ? 'CA\$'
            : campaign.currency == 'USD'
                ? '\$'
                : '${campaign.currency} ';

        final double progress = (campaign.percentage / 100.0).clamp(0.0, 1.0);

        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App Bar with Image
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: AppColors.redesignBrandRedDeep,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                      onPressed: () => Get.back(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: campaign.featuredImage != null && campaign.featuredImage!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: campaign.featuredImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const AppImageShimmer(
                                borderRadius: BorderRadius.zero,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: _accentSoftBg,
                                child: Icon(Icons.volunteer_activism_rounded, color: _brandRed.withValues(alpha: 0.5), size: 50),
                              ),
                            )
                          : Container(
                              color: _accentSoftBg,
                              child: Icon(Icons.volunteer_activism_rounded, color: _brandRed.withValues(alpha: 0.5), size: 50),
                            ),
                    ),
                  ),

                  // Campaign Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges row
                          Row(
                            children: [
                              if (campaign.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _accentSoftBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _brandRed.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    campaign.category!.name,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 11,
                                      fontColor: _brandRed,
                                    ),
                                  ),
                                ),
                              if (campaign.location != null && campaign.location!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _softBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on_rounded, size: 12, color: _slateGrey),
                                      const SizedBox(width: 3),
                                      Text(
                                        campaign.location!,
                                        style: AppFontStyle.fontStyleW500(
                                          fontSize: 10.5,
                                          fontColor: _slateGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            campaign.title,
                            style: AppFontStyle.fontStyleW800(
                              fontSize: 20,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Organizer Info
                          if (campaign.creator != null)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  backgroundImage: campaign.creator!.avatar != null
                                      ? NetworkImage(campaign.creator!.avatar!)
                                      : null,
                                  child: campaign.creator!.avatar == null
                                      ? Icon(Icons.person, size: 16, color: _slateGrey)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Organized by ${campaign.creator!.fullName}',
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 12,
                                        fontColor: _brandDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),

                          // Funding Progress Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _softBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$currencySymbol${campaign.raisedAmount.toStringAsFixed(2)}',
                                      style: AppFontStyle.fontStyleW800(
                                        fontSize: 22,
                                        fontColor: _brandRed,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'pledged of $currencySymbol${campaign.goalAmount.toStringAsFixed(2)} goal',
                                      style: AppFontStyle.fontStyleW400(
                                        fontSize: 12.5,
                                        fontColor: _slateGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(_brandRed),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${campaign.percentage.toInt()}% Funded',
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 12.5,
                                        fontColor: _brandRed,
                                      ),
                                    ),
                                    Text(
                                      '${campaign.totalDonations} Supporters',
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 12.5,
                                        fontColor: _brandDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tab Selector (Story / Updates / Donor Wall)
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: _softBorder)),
                            ),
                            child: Row(
                              children: [
                                _buildTabHeader('Story', 0),
                                _buildTabHeader('Updates (${campaign.updates.length})', 1),
                                _buildTabHeader('Donor Wall (${campaign.recentSupporters.length})', 2),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tab Views
                          if (controller.selectedTabIndex.value == 0) ...[
                            // Story Tab
                            Text(
                              (campaign.content != null && campaign.content!.isNotEmpty)
                                  ? campaign.content!
                                  : (campaign.description ?? 'No detailed story provided yet.'),
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 13.5,
                                fontColor: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Tiers / Preset Rewards if any
                            if (campaign.tiers.isNotEmpty) ...[
                              Text(
                                'Select a Giving Tier',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 15,
                                  fontColor: _brandDark,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...campaign.tiers.map((tier) {
                                return _buildTierCard(tier, currencySymbol, campaign);
                              }),
                            ],
                          ] else if (controller.selectedTabIndex.value == 1) ...[
                            // Updates Tab
                            if (campaign.updates.isEmpty)
                              _buildEmptyTabState('No updates posted for this campaign yet.')
                            else
                              ...campaign.updates.map((update) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _softBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        update.title,
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: 14,
                                          fontColor: _brandDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        update.content,
                                        style: AppFontStyle.fontStyleW400(
                                          fontSize: 12.5,
                                          fontColor: _slateGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ] else ...[
                            // Donor Wall Tab
                            if (campaign.recentSupporters.isEmpty)
                              _buildEmptyTabState('Be the first to back this verified initiative!')
                            else
                              ...campaign.recentSupporters.map((donor) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _softBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: _accentSoftBg,
                                        child: Icon(Icons.favorite_rounded, size: 18, color: _brandRed),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              donor.name,
                                              style: AppFontStyle.fontStyleW600(
                                                fontSize: 13,
                                                fontColor: _brandDark,
                                              ),
                                            ),
                                            if (donor.message != null && donor.message!.isNotEmpty)
                                              Text(
                                                donor.message!,
                                                style: AppFontStyle.fontStyleW400(
                                                  fontSize: 11.5,
                                                  fontColor: _slateGrey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '$currencySymbol${donor.amount.toStringAsFixed(2)}',
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: 13.5,
                                          fontColor: _brandRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom Support Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.donationScreen,
                      arguments: {
                        'campaign': campaign,
                        'donationType': 'CAMPAIGN',
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Support This Cause',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 14.5,
                      fontColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabHeader(String label, int index) {
    final isSelected = controller.selectedTabIndex.value == index;
    return GestureDetector(
      onTap: () => controller.setTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _brandRed : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppFontStyle.fontStyleW700(
            fontSize: 13,
            fontColor: isSelected ? _brandRed : _slateGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(CampaignTier tier, String currencySymbol, FundraisingCampaign campaign) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.donationScreen,
          arguments: {
            'campaign': campaign,
            'initialAmount': tier.amount,
            'donationType': 'CAMPAIGN',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _softBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.title,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13.5,
                      fontColor: _brandDark,
                    ),
                  ),
                  if (tier.description != null && tier.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      tier.description!,
                      style: AppFontStyle.fontStyleW400(
                        fontSize: 11.5,
                        fontColor: _slateGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.donationScreen,
                  arguments: {
                    'campaign': campaign,
                    'initialAmount': tier.amount,
                    'donationType': 'CAMPAIGN',
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Pledge $currencySymbol${tier.amount.toStringAsFixed(0)}',
                style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTabState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Text(
          msg,
          style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: _slateGrey),
        ),
      ),
    );
  }
}

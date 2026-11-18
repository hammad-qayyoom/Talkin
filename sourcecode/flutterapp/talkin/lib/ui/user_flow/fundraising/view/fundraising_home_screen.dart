import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/fundraising_controller.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/ui/user_flow/fundraising/shimmer/fundraising_shimmer.dart';
import 'package:notisboard/ui/user_flow/fundraising/widget/foundation_program_card.dart';
import 'package:notisboard/ui/user_flow/fundraising/widget/fundraising_campaign_card.dart';
import 'package:notisboard/ui/user_flow/fundraising/widget/fundraising_hero_widget.dart';
import 'package:notisboard/ui/user_flow/fundraising/widget/fundraising_spotlight_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FundraisingHomeScreen extends GetView<FundraisingController> {
  const FundraisingHomeScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FundraisingController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _brandDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Fundraising Hub',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: _brandDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              tooltip: 'My Donations',
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _accentSoftBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_rounded, color: _brandRed, size: 18),
              ),
              onPressed: () => Get.toNamed(AppRoutes.myDonationsScreen),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => c.loadAll(isBackgroundSync: false),
        color: _brandRed,
        child: Obx(() {
          final featured = c.heroConfig.value.featuredCampaign;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              // Hero Banner (Always rendered immediately)
              FundraisingHeroWidget(
                config: c.heroConfig.value,
                onExploreTap: () {
                  c.setTab(0);
                },
              ),

              // Spotlight Banner (Feed a Child $1 Initiative)
              if (c.spotlightBanner.value != null)
                FundraisingSpotlightWidget(
                  banner: c.spotlightBanner.value!,
                ),

              // Featured Mission Card
              if (featured != null)
                _buildFeaturedMissionCard(featured),

              // Search Bar (Always rendered immediately)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _softBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.025),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: _brandRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: c.searchController,
                        onSubmitted: c.onSearchSubmitted,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search campaigns, causes, locations...',
                          hintStyle: AppFontStyle.fontStyleW400(
                            fontSize: 13,
                            fontColor: _slateGrey,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (c.searchQuery.value.isNotEmpty)
                      GestureDetector(
                        onTap: c.clearSearch,
                        child: Icon(Icons.close_rounded, color: _slateGrey, size: 18),
                      ),
                  ],
                ),
              ),

              // Segmented Tabs: Campaigns vs Programs (Always rendered immediately)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _softBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => c.setTab(0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: c.selectedTabIndex.value == 0
                                ? AppColors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: c.selectedTabIndex.value == 0
                                ? [
                                    BoxShadow(
                                      color: _brandRed.withValues(alpha: 0.12),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.volunteer_activism_rounded,
                                  size: 16,
                                  color: c.selectedTabIndex.value == 0
                                      ? _brandRed
                                      : _slateGrey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Verified Campaigns',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13,
                                    fontColor: c.selectedTabIndex.value == 0
                                        ? _brandRed
                                        : _slateGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => c.setTab(1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: c.selectedTabIndex.value == 1
                                ? AppColors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: c.selectedTabIndex.value == 1
                                ? [
                                    BoxShadow(
                                      color: _brandRed.withValues(alpha: 0.12),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size: 16,
                                  color: c.selectedTabIndex.value == 1
                                      ? _brandRed
                                      : _slateGrey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Global Programs',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13,
                                    fontColor: c.selectedTabIndex.value == 1
                                        ? _brandRed
                                        : _slateGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // If Campaigns Tab
              if (c.selectedTabIndex.value == 0) ...[
                // Category Filter Chips
                if (c.categories.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _buildCategoryChip(
                          label: 'All Categories',
                          isSelected: c.selectedCategorySlug.value == 'all',
                          onTap: () => c.selectCategory('all'),
                        ),
                        ...c.categories.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildCategoryChip(
                              label: cat.name,
                              isSelected: c.selectedCategorySlug.value == cat.slug,
                              onTap: () => c.selectCategory(cat.slug),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                // Campaigns List: Shimmer on initial loading or Campaign cards
                if (c.isLoadingCampaigns.value && c.campaignsList.isEmpty)
                  const FundraisingCampaignsShimmer()
                else if (c.campaignsList.isEmpty)
                  _buildEmptyState('No active campaigns found matching your criteria.')
                else
                  ...c.campaignsList.map((campaign) {
                    return FundraisingCampaignCard(campaign: campaign);
                  }),
              ] else ...[
                // Programs List: Shimmer on initial loading or Program cards
                const SizedBox(height: 10),
                if (c.isLoadingPrograms.value && c.programsList.isEmpty)
                  const FundraisingProgramsShimmer()
                else if (c.programsList.isEmpty)
                  _buildEmptyState('No global programs found at this time.')
                else
                  ...c.programsList.map((prog) {
                    return FoundationProgramCard(program: prog);
                  }),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFeaturedMissionCard(FundraisingCampaign campaign) {
    final currencySymbol = campaign.currency == 'CAD' ? 'CA\$' : '\$';
    final double progress = (campaign.percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner badges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _accentSoftBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              border: Border(bottom: BorderSide(color: _softBorder)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _brandRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FEATURED MISSION',
                    style: AppFontStyle.fontStyleW800(
                      fontSize: 9.5,
                      fontColor: Colors.white,
                    ),
                  ),
                ),
                if (campaign.category != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    campaign.category!.name,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 11,
                      fontColor: _brandDark,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (campaign.featuredImage != null && campaign.featuredImage!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: campaign.featuredImage!,
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const AppImageShimmer(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              color: _accentSoftBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.volunteer_activism_rounded, color: _brandRed.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FOUNDATION INITIATIVE',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 10,
                                  fontColor: _brandRed,
                                ),
                              ),
                              Text(
                                '${campaign.totalDonations} donations',
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 10.5,
                                  fontColor: _slateGrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            campaign.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW800(
                              fontSize: 16,
                              fontColor: _brandDark,
                            ),
                          ),
                          if (campaign.description != null && campaign.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              campaign.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 12,
                                fontColor: _slateGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Financial stats
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$currencySymbol${campaign.raisedAmount.toStringAsFixed(2)}',
                      style: AppFontStyle.fontStyleW800(
                        fontSize: 16,
                        fontColor: _brandRed,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'goal of $currencySymbol${campaign.goalAmount.toStringAsFixed(2)}',
                      style: AppFontStyle.fontStyleW400(
                        fontSize: 12,
                        fontColor: _slateGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(_brandRed),
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${campaign.percentage.toInt()}% Funded',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 11,
                        fontColor: _brandRed,
                      ),
                    ),
                    Text(
                      '100% Direct Aid Allocation',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 11,
                        fontColor: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Actions
                Row(
                  children: [
                    Expanded(
                      flex: 6,
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
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Support This Campaign',
                          style: AppFontStyle.fontStyleW700(fontSize: 12.5, fontColor: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.campaignDetailScreen,
                            arguments: campaign,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brandRed,
                          side: BorderSide(color: _brandRed.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'View Story →',
                          style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: _brandRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _brandRed : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _brandRed : _softBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brandRed.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: isSelected ? Colors.white : _brandDark,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.redesignAccentSoftBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.volunteer_activism_outlined, size: 36, color: _brandRed),
            ),
            const SizedBox(height: 14),
            Text(
              'No Campaigns Found',
              style: AppFontStyle.fontStyleW700(
                fontSize: 16,
                fontColor: _brandDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW400(
                fontSize: 13,
                fontColor: _slateGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

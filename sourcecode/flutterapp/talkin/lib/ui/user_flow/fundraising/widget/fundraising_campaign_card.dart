import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FundraisingCampaignCard extends StatelessWidget {
  final FundraisingCampaign campaign;

  const FundraisingCampaignCard({
    super.key,
    required this.campaign,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    final currencySymbol = campaign.currency == 'CAD'
        ? 'CA\$'
        : campaign.currency == 'USD'
            ? '\$'
            : '${campaign.currency} ';

    final double progress = (campaign.percentage / 100.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.campaignDetailScreen,
          arguments: campaign,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Top Featured Image with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: campaign.featuredImage != null && campaign.featuredImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: campaign.featuredImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const AppImageShimmer(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Category Chip
                if (campaign.category != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        campaign.category!.name,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 10.5,
                          fontColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Location Chip
                if (campaign.location != null && campaign.location!.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            campaign.location!,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 10,
                              fontColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    campaign.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 16,
                      fontColor: _brandDark,
                    ),
                  ),
                  if (campaign.description != null && campaign.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      campaign.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW400(
                        fontSize: 12.5,
                        fontColor: _slateGrey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Raised of Goal
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$currencySymbol${campaign.raisedAmount.toStringAsFixed(2)}',
                        style: AppFontStyle.fontStyleW800(
                          fontSize: 15,
                          fontColor: _brandRed,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'of $currencySymbol${campaign.goalAmount.toStringAsFixed(2)}',
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 12,
                          fontColor: _slateGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(_brandRed),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Funded % and Donors count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${campaign.percentage.toInt()}% Funded',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 11.5,
                          fontColor: _brandRed,
                        ),
                      ),
                      Text(
                        '${campaign.totalDonations} Donors',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11.5,
                          fontColor: _slateGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Support This Cause Button
                  SizedBox(
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Support This Cause',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _accentSoftBg,
      child: Center(
        child: Icon(Icons.volunteer_activism_rounded, color: _brandRed.withValues(alpha: 0.35), size: 40),
      ),
    );
  }
}

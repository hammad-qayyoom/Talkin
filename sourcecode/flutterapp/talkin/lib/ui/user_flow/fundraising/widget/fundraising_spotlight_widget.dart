import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FundraisingSpotlightWidget extends StatelessWidget {
  final FundraisingPromotionBanner banner;

  const FundraisingSpotlightWidget({
    super.key,
    required this.banner,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          // Banner Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentSoftBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _brandRed.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.campaign_rounded, size: 13, color: _brandRed),
                    const SizedBox(width: 4),
                    Text(
                      'FOUNDATION ANNOUNCEMENT',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 9.5,
                        fontColor: _brandRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Special Foundation Spotlight',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 10.5,
                    fontColor: _slateGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const AppImageShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _accentSoftBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.volunteer_activism_rounded, color: _brandRed.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: _brandDark,
                      ),
                    ),
                    if (banner.description != null && banner.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        banner.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 11.5,
                          fontColor: _slateGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // CTA Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.donationScreen,
                  arguments: {
                    'donationType': 'GENERAL_FOUNDATION',
                    'initialAmount': 1.0, // Feed a child $1 initiative default
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.ctaText ?? 'Support This Initiative',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 12.5,
                      fontColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

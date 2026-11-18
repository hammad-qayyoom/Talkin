import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FundraisingHeroWidget extends StatelessWidget {
  final FundraisingHeroConfig config;
  final VoidCallback? onExploreTap;

  const FundraisingHeroWidget({
    super.key,
    required this.config,
    this.onExploreTap,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDeep,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _brandRed.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.badgeIcon,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 5),
                Text(
                  config.badgeText,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 10.5,
                    fontColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Heading
          RichText(
            text: TextSpan(
              style: AppFontStyle.fontStyleW800(
                fontSize: 22,
                fontColor: AppColors.white,
              ),
              children: [
                TextSpan(text: '${config.heading} '),
                TextSpan(
                  text: config.highlightedHeading,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            config.description,
            style: AppFontStyle.fontStyleW400(
              fontSize: 12.5,
              fontColor: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 18),

          // Primary & Secondary Buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // General Donation
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.donationScreen,
                    arguments: {'donationType': 'GENERAL_FOUNDATION'},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _brandRed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, size: 16, color: _brandRed),
                    const SizedBox(width: 6),
                    Text(
                      'General Donation',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 13,
                        fontColor: _brandRed,
                      ),
                    ),
                  ],
                ),
              ),

              // Explore Active Campaigns
              OutlinedButton(
                onPressed: onExploreTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Explore Campaigns ↓',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 13,
                    fontColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

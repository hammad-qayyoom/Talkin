import 'package:flutter/material.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class EventHeroWidget extends StatelessWidget {
  const EventHeroWidget({super.key});

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
            color: AppColors.redesignBrandRed.withValues(alpha: 0.25),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 13, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  'DISCOVER EVENTS',
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
              children: const [
                TextSpan(text: 'Find Amazing '),
                TextSpan(
                  text: 'Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Browse upcoming events, conferences, workshops, and community gatherings from around the world.',
            style: AppFontStyle.fontStyleW400(
              fontSize: 12.5,
              fontColor: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 18),

          // Stats Metrics Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('200+', 'EVENTS YEARLY'),
                _buildStatDivider(),
                _buildStatItem('35+', 'COUNTRIES'),
                _buildStatDivider(),
                _buildStatItem('10K+', 'ATTENDEES'),
                _buildStatDivider(),
                _buildStatItem('500+', 'PARTNERS'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: AppFontStyle.fontStyleW800(
            fontSize: 14,
            fontColor: AppColors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 8.5,
            fontColor: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withValues(alpha: 0.22),
    );
  }
}


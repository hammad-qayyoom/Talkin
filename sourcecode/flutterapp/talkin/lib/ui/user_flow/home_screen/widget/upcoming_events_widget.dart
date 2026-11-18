import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class UpcomingEventsWidget extends StatelessWidget {
  const UpcomingEventsWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 760;
    final isLargeTablet = screenWidth >= 1100;
    final horizontalInset = isLargeTablet
        ? 28.0
        : isTablet
            ? 22.0
            : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalInset, 4, horizontalInset, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Upcoming Events',
                style: AppFontStyle.fontStyleW700(
                  fontSize: isTablet ? 20 : 16.5,
                  fontColor: _brandDark,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.eventsHomeScreen),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: isTablet ? 13.5 : 12,
                        fontColor: _brandRed,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _brandRed,
                      size: isTablet ? 15 : 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.eventsHomeScreen),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _softBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Event Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      AppAsset.eventSummit,
                      height: isTablet ? 74 : 60,
                      width: isTablet ? 100 : 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: isTablet ? 74 : 60,
                          width: isTablet ? 100 : 80,
                          color: const Color(0xFF1E3A6C),
                          child: const Icon(
                            Icons.event_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Event Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Notisboard Community Summit',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW700(
                            fontSize: isTablet ? 15 : 13.5,
                            fontColor: _brandDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Color(0xFF757575),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sat, 28 Nov 2026',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: isTablet ? 12 : 11,
                                fontColor: AppColors.redesignMutedText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Color(0xFF757575),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Lahore',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: isTablet ? 12 : 11,
                                fontColor: AppColors.redesignMutedText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Event Tag + Arrow
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Event',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 10,
                            fontColor: _brandRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9E9E9E),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class FoodBankBannerWidget extends StatelessWidget {
  const FoodBankBannerWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;

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
      padding: EdgeInsets.fromLTRB(horizontalInset, 2, horizontalInset, 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFDDD6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 14 : 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left content column
            Expanded(
              flex: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: isTablet ? 36 : 30,
                        width: isTablet ? 36 : 30,
                        decoration: BoxDecoration(
                          color: _brandRed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: Colors.white,
                          size: isTablet ? 18 : 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food Bank',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: isTablet ? 17 : 15,
                                fontColor: _brandDark,
                              ),
                            ),
                            Text(
                              'Free food assistance in your city',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: isTablet ? 12 : 10.5,
                                fontColor: AppColors.redesignMutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Action buttons row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.foodAssistanceHomeScreen);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 14 : 10,
                            vertical: isTablet ? 7 : 5.5,
                          ),
                          decoration: BoxDecoration(
                            color: _brandRed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Get Assistance',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: isTablet ? 12 : 10.5,
                                  fontColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.foodBankDonateScreen);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 14 : 10,
                            vertical: isTablet ? 7 : 5.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _brandRed,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Donate',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: isTablet ? 12 : 10.5,
                                  fontColor: _brandRed,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: _brandRed,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right produce box image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                AppAsset.foodBankBox,
                height: isTablet ? 95 : 78,
                width: isTablet ? 125 : 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: isTablet ? 95 : 78,
                    width: isTablet ? 125 : 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      color: _brandRed,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


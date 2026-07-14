import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class BlogNewsProfileCard extends StatelessWidget {
  const BlogNewsProfileCard({super.key, this.isHighlighted = true});

  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.blogNewsListScreen);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.redesignAccentSoftBg.withValues(alpha: 0.85)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isHighlighted
                    ? AppColors.redesignBrandRed.withValues(alpha: 0.28)
                    : AppColors.redesignSoftBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: isHighlighted ? AppColors.white : AppColors.redesignSurfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isHighlighted
                          ? AppColors.redesignBrandRed.withValues(alpha: 0.2)
                          : AppColors.redesignSoftBorder,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.newspaper_rounded,
                      size: 28,
                      color: AppColors.redesignBrandRed,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Blog & News Hub',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 16,
                                fontColor: AppColors.redesignBrandDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.redesignBrandRed,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'NEW',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 9,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Official updates, announcements & tips',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: AppColors.redesignMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.redesignMutedText,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

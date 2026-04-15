import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class FindMoreWidget extends StatelessWidget {
  const FindMoreWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandRedDark = AppColors.redesignBrandRedDeep;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _neutralText = AppColors.redesignMutedText;
  static final Color _neutralBorder = AppColors.redesignSoftBorder;

  String? _resolveCategoryImageUrl(String? imagePath) {
    final normalized = (imagePath ?? '').trim();
    if (normalized.isEmpty) return null;

    if (normalized.startsWith('http')) {
      return normalized;
    }

    if (normalized.startsWith('/')) {
      return '${Api.baseUrl}${normalized.substring(1)}';
    }

    return '${Api.baseUrl}$normalized';
  }

  IconData _resolveFallbackIcon(TalkTopic category) {
    final combined =
        '${category.icon ?? ''} ${category.name ?? ''}'.toLowerCase();

    if (combined.contains('doctor') ||
        combined.contains('medical') ||
        combined.contains('stethoscope')) {
      return Icons.medical_services_outlined;
    }

    if (combined.contains('family') || combined.contains('relationship')) {
      return Icons.family_restroom_outlined;
    }

    if (combined.contains('mental') || combined.contains('mind')) {
      return Icons.psychology_outlined;
    }

    if (combined.contains('work') ||
        combined.contains('career') ||
        combined.contains('office')) {
      return Icons.work_outline_rounded;
    }

    return Icons.category_outlined;
  }

  void _openExpertsTab(HomeScreenController homeController) {
    if (Get.isRegistered<BottomBarController>()) {
      Get.find<BottomBarController>().onClick(2);
      return;
    }

    Get.toNamed(
      AppRoutes.allListeners,
      arguments: {
        'categoryId': homeController.selectedCategoryId,
      },
    );
  }

  Widget _buildCategoryCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? imagePath,
    TalkTopic? category,
    double width = 136,
    bool isTablet = false,
  }) {
    final imageUrl = _resolveCategoryImageUrl(imagePath);
    final cardColor = isSelected ? _brandRed : AppColors.white;
    final textColor = isSelected ? AppColors.white : _brandDark;
    final iconFallbackColor = isSelected ? AppColors.white : _brandDark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 11 : 10,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? _brandRed : _neutralBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.black.withValues(alpha: isSelected ? 0.10 : 0.04),
                blurRadius: isSelected ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: isTablet ? 38 : 34,
                width: isTablet ? 38 : 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.2)
                      : AppColors.redesignSurfaceNeutralAlt,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: imageUrl == null
                      ? Center(
                          child: Icon(
                            category == null
                                ? Icons.grid_view_rounded
                                : _resolveFallbackIcon(category),
                            color: iconFallbackColor,
                            size: isTablet ? 21 : 20,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Icon(
                              category == null
                                  ? Icons.grid_view_rounded
                                  : _resolveFallbackIcon(category),
                              color: iconFallbackColor,
                              size: isTablet ? 21 : 20,
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              category == null
                                  ? Icons.grid_view_rounded
                                  : _resolveFallbackIcon(category),
                              color: iconFallbackColor,
                              size: isTablet ? 21 : 20,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: isTablet ? 13 : 12,
                    fontColor: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeScreenController homeController =
        Get.find<HomeScreenController>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTabletScreen = screenWidth >= 760;
    final isLargeTabletScreen = screenWidth >= 1100;
    final horizontalInset = isLargeTabletScreen
        ? 28.0
        : isTabletScreen
            ? 22.0
            : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            final isTablet = constraints.maxWidth >= 760;
            final isLargeTablet = constraints.maxWidth >= 1100;

            final heroPadding = isLargeTablet
                ? 26.0
                : isTablet
                    ? 22.0
                    : 18.0;
            final heroTitleSize = isLargeTablet
                ? 40.0
                : isTablet
                    ? 30.0
                    : isCompact
                        ? 20.0
                        : 24.0;
            final heroDescriptionSize = isTablet
                ? 15.0
                : isCompact
                    ? 12.0
                    : 13.0;
            final ctaHeight = isTablet ? 50.0 : 44.0;

            return Container(
              margin:
                  EdgeInsets.fromLTRB(horizontalInset, 10, horizontalInset, 14),
              padding: EdgeInsets.all(heroPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _brandRed,
                    _brandRedDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _brandRed.withValues(alpha: 0.24),
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
                        height: isTablet ? 44 : 38,
                        width: isTablet ? 44 : 38,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            AppAsset.appLogo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Talkin Premium',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: isTablet ? 18 : 14,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    EnumLocale.txtHomeFastLalk.name.tr,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: heroTitleSize,
                      fontColor: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    EnumLocale.txtHomeDescription.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: heroDescriptionSize,
                      fontColor: AppColors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isCompact)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: ctaHeight,
                          child: ElevatedButton(
                            onPressed: () => _openExpertsTab(homeController),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _brandDark,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Find Experts',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: isTablet ? 15 : 14,
                                      fontColor: AppColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: ctaHeight,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.userGroupSessionsScreen);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.white.withValues(alpha: 0.62),
                              ),
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Group Sessions',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: isTablet ? 14 : 13,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: ctaHeight,
                            child: ElevatedButton(
                              onPressed: () => _openExpertsTab(homeController),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _brandDark,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Find Experts',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: isTablet ? 15 : 14,
                                        fontColor: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_outward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: ctaHeight,
                            child: OutlinedButton(
                              onPressed: () {
                                Get.toNamed(AppRoutes.userGroupSessionsScreen);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      AppColors.white.withValues(alpha: 0.62),
                                ),
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Group Sessions',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: isTablet ? 14 : 13,
                                  fontColor: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Browse categories',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTabletScreen ? 22 : 16,
                    fontColor: _brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Show all categories',
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: isTabletScreen ? 15 : 12,
                    fontColor: _neutralText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GetBuilder<HomeScreenController>(
          id: Constant.idHomeCategories,
          builder: (controller) {
            final categories = controller.homeCategories;
            final cardWidth = isLargeTabletScreen
                ? 190.0
                : isTabletScreen
                    ? 170.0
                    : 136.0;
            final rowHeight = isTabletScreen ? 62.0 : 56.0;

            return SizedBox(
              height: rowHeight,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoryCard(
                      label: 'All',
                      isSelected: controller.selectedCategoryId == null,
                      onTap: () => controller.selectHomeCategory(null),
                      width: cardWidth,
                      isTablet: isTabletScreen,
                    );
                  }

                  final category = categories[index - 1];
                  final categoryId = (category.id ?? '').trim();
                  final isSelected = categoryId.isNotEmpty &&
                      controller.selectedCategoryId == categoryId;

                  return _buildCategoryCard(
                    label: (category.name ?? '').trim().isEmpty
                        ? 'Category'
                        : category.name!.trim(),
                    isSelected: isSelected,
                    onTap: () => controller.selectHomeCategory(
                      categoryId.isEmpty ? null : categoryId,
                    ),
                    imagePath: category.image,
                    category: category,
                    width: cardWidth,
                    isTablet: isTabletScreen,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

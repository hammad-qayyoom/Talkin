import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/custom/notisboard_wordmark.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

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

    if (combined.contains('family') || combined.contains('relationship')) {
      return Icons.family_restroom_outlined;
    }

    if (combined.contains('stress') || combined.contains('mind')) {
      return Icons.spa_outlined;
    }

    if (combined.contains('work') ||
        combined.contains('career') ||
        combined.contains('office')) {
      return Icons.work_outline_rounded;
    }

    return Icons.category_outlined;
  }

  String _categoryLabel(TalkTopic category) {
    final label = (category.name ?? '').trim();
    return label.isEmpty ? 'Category' : label;
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

  Widget _buildCategoryIcon({
    required bool isSelected,
    required bool isTablet,
    String? imagePath,
    TalkTopic? category,
    double? size,
  }) {
    final imageUrl = _resolveCategoryImageUrl(imagePath);
    final iconSize = size ?? (isTablet ? 42.0 : 38.0);
    final fallbackIcon = category == null
        ? Icons.grid_view_rounded
        : _resolveFallbackIcon(category);
    final iconColor = isSelected ? AppColors.white : _brandRed;

    return Container(
      height: iconSize,
      width: iconSize,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.white.withValues(alpha: 0.18)
            : AppColors.redesignAccentSoftBg,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
      ),
      child: imageUrl == null
          ? Icon(
              fallbackIcon,
              color: iconColor,
              size: isTablet ? 22 : 20,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ProfessionalCachedImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: Icon(
                    fallbackIcon,
                    color: iconColor,
                    size: isTablet ? 22 : 20,
                  ),
                  errorWidget: Icon(
                    fallbackIcon,
                    color: iconColor,
                    size: isTablet ? 22 : 20,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCategorySheetTile({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    TalkTopic? category,
    String? imagePath,
    bool isTablet = false,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(isTablet ? 14 : 12),
          decoration: BoxDecoration(
            color: isSelected
                ? _brandRed.withValues(alpha: 0.09)
                : AppColors.redesignSurfaceNeutralAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _brandRed : _neutralBorder,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildCategoryIcon(
                isSelected: isSelected,
                isTablet: isTablet,
                imagePath: imagePath,
                category: category,
                size: isTablet ? 44 : 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: isTablet ? 14 : 12.5,
                    fontColor: isSelected ? _brandRed : _brandDark,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  color: _brandRed,
                  size: isTablet ? 21 : 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAllCategoriesSheet(
    BuildContext context,
    HomeScreenController homeController,
  ) {
    final sheetWidth = MediaQuery.sizeOf(context).width;
    final isTablet = sheetWidth >= 760;

    Get.bottomSheet(
      FractionallySizedBox(
        heightFactor: isTablet ? 0.68 : 0.72,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: GetBuilder<HomeScreenController>(
              id: Constant.idHomeCategories,
              builder: (controller) {
                final categories = controller.homeCategories;
                final itemCount = categories.length + 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        height: 5,
                        width: 52,
                        decoration: BoxDecoration(
                          color: _neutralBorder,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 22 : 16,
                        16,
                        isTablet ? 22 : 16,
                        10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: isTablet ? 42 : 38,
                            width: isTablet ? 42 : 38,
                            decoration: BoxDecoration(
                              color: AppColors.redesignAccentSoftBg,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.grid_view_rounded,
                              color: _brandRed,
                              size: isTablet ? 23 : 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'All categories',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: isTablet ? 24 : 20,
                                fontColor: _brandDark,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: Get.back,
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: AppColors.redesignSurfaceNeutralAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _neutralBorder),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: _neutralText,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: controller.isCategoryLoading && categories.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(
                                color: _brandRed,
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.fromLTRB(
                                isTablet ? 22 : 16,
                                4,
                                isTablet ? 22 : 16,
                                18,
                              ),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 3 : 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                mainAxisExtent: isTablet ? 82 : 76,
                              ),
                              itemCount: itemCount,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _buildCategorySheetTile(
                                    label: 'All',
                                    isSelected:
                                        controller.selectedCategoryId == null,
                                    onTap: () {
                                      Get.back();
                                      homeController.selectHomeCategory(null);
                                    },
                                    isTablet: isTablet,
                                  );
                                }

                                final category = categories[index - 1];
                                final categoryId = (category.id ?? '').trim();
                                final isSelected = categoryId.isNotEmpty &&
                                    controller.selectedCategoryId == categoryId;

                                return _buildCategorySheetTile(
                                  label: _categoryLabel(category),
                                  isSelected: isSelected,
                                  onTap: () {
                                    Get.back();
                                    homeController.selectHomeCategory(
                                      categoryId.isEmpty ? null : categoryId,
                                    );
                                  },
                                  category: category,
                                  imagePath: category.image,
                                  isTablet: isTablet,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.34),
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
    final cardColor = isSelected ? _brandRed : AppColors.white;
    final textColor = isSelected ? AppColors.white : _brandDark;

    return Material(
      color: AppColors.transparent,
      child: SizedBox(
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12,
              vertical: isTablet ? 10 : 9,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? _brandRed : _neutralBorder,
                width: isSelected ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black
                      .withValues(alpha: isSelected ? 0.11 : 0.035),
                  blurRadius: isSelected ? 16 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCategoryIcon(
                  isSelected: isSelected,
                  isTablet: isTablet,
                  imagePath: imagePath,
                  category: category,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: isTablet ? 13.5 : 12.5,
                      fontColor: textColor,
                    ),
                  ),
                ),
              ],
            ),
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
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text.rich(
                        TextSpan(
                          style: AppFontStyle.fontStyleW700(
                            fontSize: isTablet ? 18 : 14,
                            fontColor: AppColors.white,
                          ),
                          children: [
                            NotisboardWordmark.span(
                              style: AppFontStyle.fontStyleW700(
                                fontSize: isTablet ? 18 : 14,
                                fontColor: AppColors.white,
                              ),
                            ),
                            const TextSpan(text: ' Premium'),
                          ],
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
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Find Experts',
                                      maxLines: 1,
                                      softWrap: false,
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: isTablet ? 15 : 14,
                                        fontColor: AppColors.white,
                                      ),
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Group Sessions',
                                maxLines: 1,
                                softWrap: false,
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: isTablet ? 14 : 13,
                                  fontColor: AppColors.white,
                                ),
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
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Find Experts',
                                        maxLines: 1,
                                        softWrap: false,
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: isTablet ? 15 : 14,
                                          fontColor: AppColors.white,
                                        ),
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
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Group Sessions',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: isTablet ? 14 : 13,
                                    fontColor: AppColors.white,
                                  ),
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
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _showAllCategoriesSheet(context, homeController),
                  child: Container(
                    height: isTabletScreen ? 38 : 34,
                    padding: EdgeInsets.only(
                      left: isTabletScreen ? 14 : 12,
                      right: isTabletScreen ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _neutralBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.035),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTabletScreen ? 160 : 126,
                          ),
                          child: Text(
                            screenWidth < 360
                                ? 'All categories'
                                : 'Show all categories',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: isTabletScreen ? 13 : 11.5,
                              fontColor: _brandRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _brandRed,
                          size: isTabletScreen ? 20 : 18,
                        ),
                      ],
                    ),
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
            final categoryCardWidth = isLargeTabletScreen
                ? 190.0
                : isTabletScreen
                    ? 170.0
                    : 146.0;
            final allCardWidth = isLargeTabletScreen
                ? 150.0
                : isTabletScreen
                    ? 138.0
                    : 118.0;
            final rowHeight = isTabletScreen ? 64.0 : 58.0;

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
                      width: allCardWidth,
                      isTablet: isTabletScreen,
                    );
                  }

                  final category = categories[index - 1];
                  final categoryId = (category.id ?? '').trim();
                  final isSelected = categoryId.isNotEmpty &&
                      controller.selectedCategoryId == categoryId;

                  return _buildCategoryCard(
                    label: _categoryLabel(category),
                    isSelected: isSelected,
                    onTap: () => controller.selectHomeCategory(
                      categoryId.isEmpty ? null : categoryId,
                    ),
                    imagePath: category.image,
                    category: category,
                    width: categoryCardWidth,
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

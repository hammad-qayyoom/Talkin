import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/model/growth_spotlight_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class UserGrowthSpotlightWidget extends StatelessWidget {
  const UserGrowthSpotlightWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  String _resolveSpotlightImageUrl(String rawImage) {
    final trimmed = rawImage.trim();
    if (trimmed.isEmpty) return "";
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    if (trimmed.startsWith("/")) {
      return "${Api.baseUrl}${trimmed.substring(1)}";
    }
    return "${Api.baseUrl}$trimmed";
  }

  String _resolveSpotlightTitle(GrowthSpotlightData item) {
    final text = (item.title ?? "").trim();
    if (text.isNotEmpty) {
      return text;
    }
    return "Spotlight Highlight";
  }

  String _resolveSpotlightDescription(GrowthSpotlightData item) {
    final text = (item.description ?? "").trim();
    if (text.isNotEmpty) {
      return text;
    }
    return "Check out latest updates and premium features.";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 760;

    return GetBuilder<HomeScreenController>(
      id: 'userSpotlight',
      builder: (controller) {
        if (!controller.isSpotlightLoading && controller.userSpotlightItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _softBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtGrowthSpotlight.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 18 : 16,
                    fontColor: _brandDark,
                  ),
                ),
                const SizedBox(height: 10),
                if (controller.isSpotlightLoading)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AppImageShimmer(
                      height: isTablet ? 170 : 138,
                      width: double.infinity,
                    ),
                  )
                else
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: isTablet ? 170 : 138,
                            autoPlay: controller.userSpotlightItems.length > 1,
                            viewportFraction: 1,
                            enlargeCenterPage: false,
                            onPageChanged: controller.onSpotlightPageChanged,
                          ),
                          items: controller.userSpotlightItems.map((item) {
                            final imageUrl = _resolveSpotlightImageUrl(item.image ?? "");
                            final title = _resolveSpotlightTitle(item);
                            final description = _resolveSpotlightDescription(item);

                            return Builder(
                              builder: (BuildContext context) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    imageUrl.isEmpty
                                        ? Container(
                                            color: AppColors.redesignSurfaceNeutralAlt,
                                          )
                                        : ProfessionalCachedImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: const AppImageShimmer(),
                                            errorWidget: Container(
                                              color: AppColors.redesignSurfaceNeutralAlt,
                                            ),
                                          ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.black.withValues(alpha: 0.08),
                                            AppColors.black.withValues(alpha: 0.48),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 12,
                                      right: 12,
                                      bottom: 10,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: isTablet ? 14 : 12,
                                              fontColor: AppColors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.fontStyleW500(
                                              fontSize: isTablet ? 12 : 11,
                                              fontColor: AppColors.white.withValues(alpha: 0.94),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      if (controller.userSpotlightItems.length > 1) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.userSpotlightItems.length,
                            (index) {
                              final isSelected = controller.currentSpotlightIndex == index;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isSelected ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: isSelected ? _brandRed : AppColors.redesignSoftBorder,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

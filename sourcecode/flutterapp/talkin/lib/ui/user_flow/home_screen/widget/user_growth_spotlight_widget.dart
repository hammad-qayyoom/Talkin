import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';

class UserGrowthSpotlightWidget extends StatelessWidget {
  const UserGrowthSpotlightWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;

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

  void _onBannerTap() {
    if (Get.isRegistered<BottomBarController>()) {
      final bottomBar = Get.find<BottomBarController>();
      bottomBar.selectIndex = 2; // Listeners / Experts
      bottomBar.update([Constant.idBottomBar]);
    }
  }

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

    final bannerHeight = isTablet ? 175.0 : 142.0;

    return GetBuilder<HomeScreenController>(
      id: 'userSpotlight',
      builder: (controller) {
        final items = controller.userSpotlightItems;

        return Padding(
          padding: EdgeInsets.fromLTRB(horizontalInset, 4, horizontalInset, 12),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: controller.isSpotlightLoading
                    ? AppImageShimmer(
                        height: bannerHeight,
                        width: double.infinity,
                      )
                    : items.isEmpty
                        ? GestureDetector(
                            onTap: _onBannerTap,
                            child: Container(
                              height: bannerHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0F1E36),
                                    Color(0xFF1E3A6C),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'CONNECT WITH TOP EXPERTS',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: isTablet ? 18 : 14.5,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Get Trusted Advice in Health, Education, Business and More',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontSize: isTablet ? 13 : 11,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _brandRed,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text(
                                                'Find Your Expert',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 13,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : CarouselSlider(
                            options: CarouselOptions(
                              height: bannerHeight,
                              autoPlay: items.length > 1,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              onPageChanged: controller.onSpotlightPageChanged,
                            ),
                            items: items.map((item) {
                              final imageUrl = _resolveSpotlightImageUrl(item.image ?? '');

                              return GestureDetector(
                                onTap: _onBannerTap,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color(0xFF0F1E36),
                                  ),
                                  child: imageUrl.isEmpty
                                      ? Container(color: const Color(0xFF0F1E36))
                                      : ProfessionalCachedImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: const AppImageShimmer(),
                                          errorWidget: Container(
                                            color: const Color(0xFF0F1E36),
                                          ),
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
              ),
              const SizedBox(height: 8),
              // Carousel Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length > 1 ? items.length : 3,
                  (index) {
                    final isSelected = controller.currentSpotlightIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: isSelected ? 16 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: isSelected
                            ? _brandRed
                            : AppColors.redesignSoftBorder,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

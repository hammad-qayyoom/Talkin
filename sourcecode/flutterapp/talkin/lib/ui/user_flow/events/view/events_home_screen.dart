import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/events/controller/events_controller.dart';
import 'package:notisboard/ui/user_flow/events/shimmer/events_shimmer.dart';
import 'package:notisboard/ui/user_flow/events/widget/event_card_widget.dart';
import 'package:notisboard/ui/user_flow/events/widget/event_hero_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class EventsHomeScreen extends GetView<EventsController> {
  const EventsHomeScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final c = Get.put(EventsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _brandDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Events & Gatherings',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: _brandDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              tooltip: 'My Tickets',
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.confirmation_number_outlined, color: _brandRed, size: 18),
              ),
              onPressed: () => Get.toNamed(AppRoutes.myTicketsScreen),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => c.loadEvents(isBackgroundSync: false),
        color: _brandRed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            // Hero Banner (Always rendered immediately)
            const EventHeroWidget(),

            // Search Bar (Always rendered immediately)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _softBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.025),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: _brandRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: c.searchController,
                      onSubmitted: c.onSearchSubmitted,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search events by name, topic, or location...',
                        hintStyle: AppFontStyle.fontStyleW400(
                          fontSize: 13,
                          fontColor: _slateGrey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (c.searchQuery.value.isNotEmpty) {
                      return GestureDetector(
                        onTap: c.clearSearch,
                        child: Icon(Icons.close_rounded, color: _slateGrey, size: 18),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            // Category Filter Chips Row (Always rendered immediately)
            Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: c.categories.map((cat) {
                    final isSelected = c.selectedCategorySlug.value == cat['slug'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => c.selectCategory(cat['slug']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? _brandRed : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _brandRed : _softBorder,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _brandRed.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            cat['name']!,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 12,
                              fontColor: isSelected ? AppColors.white : _brandDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),

            // Header: Count & Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final count = c.eventsList.length;
                    final categoryName = c.categories.firstWhere(
                          (cat) => cat['slug'] == c.selectedCategorySlug.value,
                          orElse: () => {'name': 'All Events'},
                        )['name'] ??
                        'Events';
                    return Text(
                      '$categoryName ($count)',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: _brandDark,
                      ),
                    );
                  }),
                  Obx(() {
                    if (c.isLoading.value && c.eventsList.isNotEmpty) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: _brandRed),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Updating...',
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 11,
                              fontColor: _slateGrey,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            // Events Content Section: Shimmer when loading, or real Event cards
            Obx(() {
              if (c.isLoading.value && c.eventsList.isEmpty) {
                return const EventsListShimmer();
              }

              if (c.eventsList.isEmpty) {
                return _buildEmptyState('No upcoming events found matching your criteria.');
              }

              return Column(
                children: c.eventsList.map((event) {
                  return EventCardWidget(event: event);
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.redesignAccentSoftBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy_outlined, size: 36, color: _brandRed),
            ),
            const SizedBox(height: 14),
            Text(
              'No Events Found',
              style: AppFontStyle.fontStyleW700(
                fontSize: 16,
                fontColor: _brandDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW400(
                fontSize: 13,
                fontColor: _slateGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

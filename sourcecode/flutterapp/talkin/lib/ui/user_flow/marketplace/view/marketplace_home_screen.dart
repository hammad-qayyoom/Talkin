import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/widget/product_card_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class MarketplaceHomeScreen extends StatelessWidget {
  const MarketplaceHomeScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketplaceController());
    final cart = Get.put(MarketplaceCartController(), permanent: true);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 760;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _brandDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marketplace',
              style: AppFontStyle.fontStyleW700(
                fontSize: 18,
                fontColor: _brandDark,
              ),
            ),
            Text(
              'Ethical & Fair-Trade Global Goods',
              style: AppFontStyle.fontStyleW500(
                fontSize: 11,
                fontColor: AppColors.redesignSlateGrey,
              ),
            ),
          ],
        ),
        actions: [
          // Order History Icon
          IconButton(
            icon: Icon(Icons.receipt_long_rounded, color: _brandDark, size: 22),
            tooltip: 'My Orders',
            onPressed: () => Get.toNamed(AppRoutes.marketplaceMyOrdersScreen),
          ),
          // Cart Icon with Badge
          Obx(() {
            final count = cart.totalCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_bag_outlined, color: _brandDark, size: 24),
                  onPressed: () => Get.toNamed(AppRoutes.marketplaceCartScreen),
                ),
                if (count > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _brandRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                      child: Center(
                        child: Text(
                          '$count',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 10,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadInitialData(),
        color: _brandRed,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar & Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 8),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _softBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onSubmitted: controller.onSearchSubmitted,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search ethical products, brands, artisans...',
                      hintStyle: AppFontStyle.fontStyleW400(
                        fontSize: 13,
                        fontColor: AppColors.redesignSlateGrey,
                      ),
                      prefixIcon: Icon(Icons.search_rounded, color: _brandRed, size: 20),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: controller.clearSearch,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),

            // Hero Showcase Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: _brandRed.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🌍 100% ETHICAL & FAIR-TRADE',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 10,
                                  fontColor: const Color(0xFFFF8A80),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Support Global Artisans',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 16,
                                fontColor: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Every single purchase directly empowers independent creators worldwide.',
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 11.5,
                                fontColor: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category Chips Row
            SliverToBoxAdapter(
              child: Obx(() {
                final cats = controller.categories;
                return SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    scrollDirection: Axis.horizontal,
                    itemCount: cats.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final catId = isAll ? 'all' : cats[index - 1].id;
                      final catName = isAll ? 'All' : cats[index - 1].name;
                      final isSelected = controller.selectedCategoryId.value == catId;

                      return GestureDetector(
                        onTap: () => controller.selectCategory(catId, catName),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
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
                          child: Center(
                            child: Text(
                              catName,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 12,
                                fontColor: isSelected ? AppColors.white : _brandDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            // Header Row: Count & Sort Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          controller.isLoading.value
                              ? 'Loading products...'
                              : '${controller.productList.length} products available',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: _brandDark,
                          ),
                        )),
                    // Sort dropdown
                    PopupMenuButton<String>(
                      onSelected: controller.changeSort,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'priority',
                          child: Text('Featured & Priority'),
                        ),
                        const PopupMenuItem(
                          value: 'newest',
                          child: Text('Newest Arrivals'),
                        ),
                        const PopupMenuItem(
                          value: 'price-low',
                          child: Text('Price: Low to High'),
                        ),
                        const PopupMenuItem(
                          value: 'price-high',
                          child: Text('Price: High to Low'),
                        ),
                      ],
                      child: Row(
                        children: [
                          Icon(Icons.swap_vert_rounded, size: 16, color: _brandRed),
                          const SizedBox(width: 4),
                          Text(
                            'Sort',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 12.5,
                              fontColor: _brandRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Products Grid
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.productList.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 56, color: AppColors.redesignSlateGrey),
                          const SizedBox(height: 12),
                          Text(
                            'No Products Found',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 16,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try clearing search keywords or selecting another category.',
                            textAlign: TextAlign.center,
                            style: AppFontStyle.fontStyleW400(
                              fontSize: 13,
                              fontColor: AppColors.redesignSlateGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    childAspectRatio: 0.64,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = controller.productList[index];
                      return ProductCardWidget(product: product);
                    },
                    childCount: controller.productList.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}


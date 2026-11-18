import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/shimmer/marketplace_shimmer.dart';
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
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: IconButton(
              tooltip: 'My Orders',
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_rounded, color: _brandRed, size: 18),
              ),
              onPressed: () => Get.toNamed(AppRoutes.marketplaceMyOrdersScreen),
            ),
          ),
          // Cart Icon with Badge
          Obx(() {
            final count = cart.totalCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Shopping Cart',
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.redesignAccentSoftBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_bag_outlined, color: _brandRed, size: 18),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.marketplaceCartScreen),
                ),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: _brandRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
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
        onRefresh: () => controller.loadInitialData(isBackgroundSync: false),
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

            // Hero Showcase Banner in Brand Red Gradient
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  const Text('🌍', style: TextStyle(fontSize: 11)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '100% ETHICAL & FAIR-TRADE',
                                    style: AppFontStyle.fontStyleW700(
                                      fontSize: 10,
                                      fontColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Support Global Artisans',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 18,
                                fontColor: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Every single purchase directly empowers independent creators worldwide.',
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 12,
                                fontColor: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
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
                    Obx(() {
                      final isInitialLoading = controller.isLoading.value && controller.productList.isEmpty;
                      return Row(
                        children: [
                          Text(
                            isInitialLoading
                                ? 'Loading products...'
                                : '${controller.productList.length} products available',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 13,
                              fontColor: _brandDark,
                            ),
                          ),
                          if (controller.isLoading.value && controller.productList.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: _brandRed),
                            ),
                          ],
                        ],
                      );
                    }),
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

            // Products Grid: Shimmer when initial loading or real products
            Obx(() {
              if (controller.isLoading.value && controller.productList.isEmpty) {
                return SliverToBoxAdapter(
                  child: MarketplaceGridShimmer(
                    horizontalPadding: horizontalPadding,
                    isTablet: isTablet,
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
                          Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              color: AppColors.redesignAccentSoftBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.search_off_rounded, size: 36, color: _brandRed),
                          ),
                          const SizedBox(height: 14),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/product_detail_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductDetailController());
    final cart = Get.find<MarketplaceCartController>();

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
        title: Text(
          'Product Details',
          style: AppFontStyle.fontStyleW700(
            fontSize: 18,
            fontColor: _brandDark,
          ),
        ),
        actions: [
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
      body: Obx(() {
        if (controller.isLoading.value && controller.product.value == null) {
          return const Center(
            child: AppImageShimmer(
              width: double.infinity,
              height: 280,
              borderRadius: BorderRadius.zero,
            ),
          );
        }

        final product = controller.product.value;
        if (product == null) {
          return Center(
            child: Text(
              'Product details not available.',
              style: AppFontStyle.fontStyleW600(
                fontSize: 14,
                fontColor: _brandDark,
              ),
            ),
          );
        }

        final images = product.images.isNotEmpty
            ? product.images
            : (product.featuredImage.isNotEmpty ? [product.featuredImage] : <String>[]);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel
              if (images.isNotEmpty)
                Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: isTablet ? 380 : 280,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: images.length > 1,
                          onPageChanged: (index, _) {
                            controller.selectImage(index);
                          },
                        ),
                        items: images.map((url) {
                          return CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            placeholder: (_, __) => const AppImageShimmer(
                              borderRadius: BorderRadius.zero,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.redesignNeutralGrey,
                              child: Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.redesignSlateGrey),
                            ),
                          );
                        }).toList(),
                      ),
                      if (images.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: images.asMap().entries.map((entry) {
                              final isSelected = controller.selectedImageIndex.value == entry.key;
                              return Container(
                                width: isSelected ? 18 : 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: isSelected ? _brandRed : _softBorder,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Container(
                  height: 200,
                  color: AppColors.redesignNeutralGrey,
                  child: Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.redesignSlateGrey),
                ),

              // Title, Pricing & Badges Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(horizontalPadding),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Badge Row
                    Row(
                      children: [
                        if (product.category?.name != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.redesignAccentSoftBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _brandRed.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              product.category!.name.toUpperCase(),
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 10,
                                fontColor: _brandRed,
                              ),
                            ),
                          ),
                        if (product.badge != null && product.badge!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.badge!,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 10,
                                fontColor: AppColors.green,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Stock Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.isInStock
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                product.isInStock ? Icons.check_circle : Icons.cancel,
                                size: 12,
                                color: product.isInStock ? AppColors.green : AppColors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                product.isInStock
                                    ? (product.trackInventory
                                        ? 'In Stock (${product.inventory})'
                                        : 'In Stock')
                                    : 'Sold Out',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 10.5,
                                  fontColor:
                                      product.isInStock ? AppColors.green : AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      product.title,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 18,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Price & Savings
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'CA\$${product.price.toStringAsFixed(2)}',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 22,
                            fontColor: _brandRed,
                          ),
                        ),
                        if (product.isOnSale && product.compareAtPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'CA\$${product.compareAtPrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.redesignSlateGrey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _brandRed,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: _brandRed.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              'Save ${product.discountPercent}%',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 10,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Vendor Card
              if (product.vendor != null || product.sellerName != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(horizontalPadding),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.redesignAccentSoftBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.store_rounded, color: _brandRed, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sold & Shipped by',
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 11,
                                fontColor: AppColors.redesignSlateGrey,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  product.vendor?.storeName ?? product.sellerName ?? 'Ethical Artisan',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13.5,
                                    fontColor: _brandDark,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.verified, size: 14, color: AppColors.blue),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFE082)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFA000)),
                            const SizedBox(width: 3),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 11,
                                fontColor: const Color(0xFF795548),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Quantity Selector Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                color: AppColors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 14,
                        fontColor: _brandDark,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: _softBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: controller.decrementQuantity,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          Obx(() => Text(
                                '${controller.quantity.value}',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 14,
                                  fontColor: _brandDark,
                                ),
                              )),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: controller.incrementQuantity,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Description & Details
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(horizontalPadding),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Description',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'Handcrafted with fair-trade certified materials by independent community artisans.',
                      style: AppFontStyle.fontStyleW400(
                        fontSize: 13,
                        fontColor: AppColors.redesignSlateGrey,
                      ),
                    ),
                    if (product.features.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Key Highlights & Features',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: _brandDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...product.features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline, size: 15, color: _brandRed),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  f,
                                  style: AppFontStyle.fontStyleW400(
                                    fontSize: 12.5,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Shipping & Return Guarantees
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(horizontalPadding),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping & Delivery Guarantee',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 18, color: _brandRed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Free standard shipping on all orders over CA\$100.00.',
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 12.5,
                              fontColor: _brandDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.published_with_changes_rounded, size: 18, color: AppColors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.returnPolicy ??
                                '30-day hassle-free return or exchange for unused goods.',
                            style: AppFontStyle.fontStyleW400(
                              fontSize: 12,
                              fontColor: AppColors.redesignSlateGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final product = controller.product.value;
        if (product == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Add to Cart Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: product.isInStock ? controller.addToCart : null,
                  icon: Icon(Icons.add_shopping_cart_rounded, color: _brandRed, size: 18),
                  label: Text(
                    'Add to Cart',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13,
                      fontColor: _brandRed,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _brandRed, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Buy Now Button
              Expanded(
                child: ElevatedButton(
                  onPressed: product.isInStock ? controller.buyNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Buy Now',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13.5,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class ProductCardWidget extends StatelessWidget {
  final MarketplaceProduct product;

  const ProductCardWidget({super.key, required this.product});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<MarketplaceCartController>();

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.marketplaceProductDetailScreen,
          arguments: product,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image & Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.05,
                    child: product.featuredImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.featuredImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.redesignNeutralGrey,
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.redesignNeutralGrey,
                              child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: AppColors.redesignNeutralGrey,
                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                          ),
                  ),
                ),
                // Sale / Discount Badge
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: _brandRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPercent}% OFF',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 10,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                  )
                else if (product.badge != null && product.badge!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.badge!,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 10,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                // Out of stock overlay
                if (!product.isInStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.45),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SOLD OUT',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 11,
                              fontColor: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Name
                  if (product.sellerName != null && product.sellerName!.isNotEmpty)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            product.sellerName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 11,
                              fontColor: AppColors.redesignSlateGrey,
                            ),
                          ),
                        ),
                        if (product.vendor?.isVerified == true) ...[
                          const SizedBox(width: 3),
                          Icon(Icons.verified, size: 12, color: AppColors.blue),
                        ],
                      ],
                    ),
                  const SizedBox(height: 3),

                  // Title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 13,
                      fontColor: _brandDark,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Pricing & Add to Cart Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CA\$${product.price.toStringAsFixed(2)}',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 14.5,
                                fontColor: _brandRed,
                              ),
                            ),
                            if (product.isOnSale && product.compareAtPrice != null)
                              Text(
                                'CA\$${product.compareAtPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.redesignSlateGrey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Quick Add to Cart button
                      Obx(() {
                        final inCart = cart.isInCart(product.id);
                        final qty = cart.getQuantity(product.id);

                        return GestureDetector(
                          onTap: product.isInStock
                              ? () => cart.addToCart(product)
                              : null,
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: inCart ? _brandRed : _brandRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: inCart
                                  ? Text(
                                      '$qty',
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 13,
                                        fontColor: AppColors.white,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add_shopping_cart_rounded,
                                      size: 18,
                                      color: _brandRed,
                                    ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

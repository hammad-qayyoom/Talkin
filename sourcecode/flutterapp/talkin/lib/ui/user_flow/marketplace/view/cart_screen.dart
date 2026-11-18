import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
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
        title: Obx(() => Text(
              'Shopping Cart (${cart.totalCount})',
              style: AppFontStyle.fontStyleW700(
                fontSize: 18,
                fontColor: _brandDark,
              ),
            )),
        actions: [
          Obx(() {
            if (cart.cartItems.isNotEmpty) {
              return TextButton(
                onPressed: () => cart.clearCart(),
                child: Text(
                  'Clear',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 13,
                    fontColor: _brandRed,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (cart.cartItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: AppColors.redesignAccentSoftBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 46,
                      color: _brandRed,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Cart is Empty',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 18,
                      fontColor: _brandDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore our certified ethical marketplace and support artisan livelihoods.',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW400(
                      fontSize: 13,
                      fontColor: AppColors.redesignSlateGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandRed,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Explore Marketplace',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final subtotal = cart.subtotal;
        final freeShippingDiff = 100.0 - subtotal;
        final shippingProgress = (subtotal / 100.0).clamp(0.0, 1.0);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Free Shipping Progress Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _softBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          subtotal >= 100
                              ? Icons.check_circle_rounded
                              : Icons.local_shipping_outlined,
                          size: 18,
                          color: subtotal >= 100 ? AppColors.green : _brandRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subtotal >= 100
                                ? '🎉 You unlocked FREE Shipping!'
                                : 'Add CA\$${freeShippingDiff.toStringAsFixed(2)} more for FREE Delivery',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 12.5,
                              fontColor: _brandDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: shippingProgress,
                        minHeight: 6,
                        backgroundColor: AppColors.redesignNeutralGrey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          subtotal >= 100 ? AppColors.green : _brandRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Cart Items List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = cart.cartItems[index];
                  final product = item.product;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _softBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail with Shimmer placeholder
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 72,
                            width: 72,
                            color: AppColors.redesignNeutralGrey,
                            child: product.featuredImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: product.featuredImage,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const AppImageShimmer(
                                      height: 72,
                                      width: 72,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    errorWidget: (_, __, ___) => Icon(Icons.shopping_bag_outlined, color: AppColors.redesignSlateGrey),
                                  )
                                : Icon(Icons.shopping_bag_outlined, color: AppColors.redesignSlateGrey),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title, Vendor & Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 13,
                                  fontColor: _brandDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              if (product.sellerName != null)
                                Text(
                                  product.sellerName!,
                                  style: AppFontStyle.fontStyleW400(
                                    fontSize: 11,
                                    fontColor: AppColors.redesignSlateGrey,
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                'CA\$${item.totalPrice.toStringAsFixed(2)}',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 14,
                                  fontColor: _brandRed,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stepper & Delete
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, size: 20, color: _brandRed),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => cart.removeFromCart(product.id),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: _softBorder),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => cart.updateQuantity(product.id, item.quantity - 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: const Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: AppFontStyle.fontStyleW700(
                                      fontSize: 12,
                                      fontColor: _brandDark,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => cart.updateQuantity(product.id, item.quantity + 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: const Icon(Icons.add, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Order Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _softBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Summary',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14.5,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Items Subtotal', 'CA\$${cart.subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Estimated Shipping',
                      cart.shippingFee == 0 ? 'FREE' : 'CA\$${cart.shippingFee.toStringAsFixed(2)}',
                      valueColor: cart.shippingFee == 0 ? AppColors.green : null,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Community Taxes & Fees (5%)', 'CA\$${cart.taxAmount.toStringAsFixed(2)}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Total',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 15,
                            fontColor: _brandDark,
                          ),
                        ),
                        Text(
                          'CA\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 17,
                            fontColor: _brandRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (cart.cartItems.isEmpty) return const SizedBox.shrink();

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
          child: ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.marketplaceCheckoutScreen),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandRed,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Proceed to Checkout',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14.5,
                    fontColor: AppColors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  CA\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14.5,
                    fontColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW500(
            fontSize: 12.5,
            fontColor: AppColors.redesignSlateGrey,
          ),
        ),
        Text(
          value,
          style: AppFontStyle.fontStyleW700(
            fontSize: 12.5,
            fontColor: valueColor ?? AppColors.redesignBrandDark,
          ),
        ),
      ],
    );
  }
}

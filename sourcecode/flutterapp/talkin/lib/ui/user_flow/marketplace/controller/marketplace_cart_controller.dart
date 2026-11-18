import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/utils.dart';

class MarketplaceCartController extends GetxController {
  static MarketplaceCartController get to => Get.find<MarketplaceCartController>();

  final RxList<CartItem> cartItems = <CartItem>[].obs;

  int get totalCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Free shipping on orders over CA$100, else flat CA$10
  double get shippingFee {
    if (subtotal <= 0) return 0.0;
    return subtotal >= 100 ? 0.0 : 10.0;
  }

  /// 5% estimated customer service fee and applicable sales taxes
  double get taxAmount {
    if (subtotal <= 0) return 0.0;
    return Math.roundToDouble((subtotal * 0.05) * 100) / 100;
  }

  double get totalAmount =>
      Math.roundToDouble((subtotal + shippingFee + taxAmount) * 100) / 100;

  String get currency =>
      cartItems.isNotEmpty ? cartItems.first.product.currency : 'CAD';

  bool isInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      return cartItems[index].quantity;
    }
    return 0;
  }

  void addToCart(MarketplaceProduct product, {int quantity = 1, bool showToast = true}) {
    if (!product.isInStock) {
      final ctx = Get.context;
      if (ctx != null) {
        Utils.showToast(ctx, 'Sorry, this product is currently out of stock.');
      }
      return;
    }

    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final current = cartItems[index].quantity;
      final maxAvailable = product.trackInventory ? product.inventory : 999;
      if (current + quantity > maxAvailable) {
        final ctx = Get.context;
        if (ctx != null) {
          Utils.showToast(ctx, 'Only $maxAvailable unit(s) available in inventory.');
        }
        return;
      }
      cartItems[index].quantity = current + quantity;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(product: product, quantity: quantity));
    }

    if (showToast) {
      Get.snackbar(
        'Added to Cart',
        '${product.title} ($quantity)',
        backgroundColor: AppColors.redesignBrandDark,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.white),
      );
    }
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    if (newQuantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final prod = cartItems[index].product;
    final maxAvailable = prod.trackInventory ? prod.inventory : 999;
    if (newQuantity > maxAvailable) {
      final ctx = Get.context;
      if (ctx != null) {
        Utils.showToast(ctx, 'Only $maxAvailable unit(s) available in stock.');
      }
      return;
    }

    cartItems[index].quantity = newQuantity;
    cartItems.refresh();
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() {
    cartItems.clear();
  }
}

class Math {
  static double roundToDouble(double val) {
    return (val * 100).round() / 100;
  }
}


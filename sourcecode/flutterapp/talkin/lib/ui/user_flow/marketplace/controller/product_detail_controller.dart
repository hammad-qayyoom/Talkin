import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/api/marketplace_api.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';
import 'package:notisboard/utils/utils.dart';

class ProductDetailController extends GetxController {
  final Rxn<MarketplaceProduct> product = Rxn<MarketplaceProduct>();
  final isLoading = true.obs;
  final selectedImageIndex = 0.obs;
  final quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is MarketplaceProduct) {
      product.value = args;
      isLoading.value = false;
      // Also fetch fresh in background
      _refreshProduct(args.slug.isNotEmpty ? args.slug : args.id);
    } else if (args is String) {
      _refreshProduct(args);
    }
  }

  Future<void> _refreshProduct(String slugOrId) async {
    final fresh = await MarketplaceApi.fetchProductDetail(slugOrId);
    if (fresh != null) {
      product.value = fresh;
    }
    isLoading.value = false;
  }

  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  void incrementQuantity() {
    final prod = product.value;
    if (prod == null) return;
    final maxAvailable = prod.trackInventory ? prod.inventory : 999;
    if (quantity.value < maxAvailable) {
      quantity.value++;
    } else {
      final ctx = Get.context;
      if (ctx != null) {
        Utils.showToast(ctx, 'Maximum available stock is $maxAvailable units.');
      }
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void addToCart() {
    final prod = product.value;
    if (prod == null) return;
    if (!prod.isInStock) {
      final ctx = Get.context;
      if (ctx != null) {
        Utils.showToast(ctx, 'Product is currently sold out.');
      }
      return;
    }
    final cart = Get.find<MarketplaceCartController>();
    cart.addToCart(prod, quantity: quantity.value);
  }

  void buyNow() {
    final prod = product.value;
    if (prod == null) return;
    if (!prod.isInStock) {
      final ctx = Get.context;
      if (ctx != null) {
        Utils.showToast(ctx, 'Product is currently sold out.');
      }
      return;
    }
    final cart = Get.find<MarketplaceCartController>();
    cart.addToCart(prod, quantity: quantity.value, showToast: false);
    Get.toNamed(AppRoutes.marketplaceCheckoutScreen);
  }
}

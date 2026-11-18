import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/marketplace/api/marketplace_api.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';

class MarketplaceController extends GetxController {
  // Static in-memory cache to guarantee zero-latency screen restoration
  static final List<MarketplaceProduct> _cachedProducts = [];
  static final List<MarketplaceCategory> _cachedCategories = [];
  static DateTime? _lastFetchTime;

  final isLoading = true.obs;
  final isCategoriesLoading = true.obs;
  final isSearching = false.obs;

  final RxList<MarketplaceProduct> productList = <MarketplaceProduct>[].obs;
  final RxList<MarketplaceCategory> categories = <MarketplaceCategory>[].obs;

  final selectedCategoryId = 'all'.obs;
  final selectedCategoryName = 'All'.obs;
  final selectedSort = 'priority'.obs;
  final searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  int currentPage = 1;
  bool hasNextPage = true;
  final isMoreLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Instant Cache Restoration: Restore products and categories immediately
    if (_cachedProducts.isNotEmpty) {
      categories.assignAll(_cachedCategories);
      productList.assignAll(_cachedProducts);
      isLoading.value = false;
      isCategoriesLoading.value = false;

      final isStale = _lastFetchTime == null ||
          DateTime.now().difference(_lastFetchTime!).inSeconds > 20;
      if (isStale) {
        loadInitialData(isBackgroundSync: true);
      }
    } else {
      isLoading.value = true;
      loadInitialData(isBackgroundSync: false);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData({bool isBackgroundSync = false}) async {
    if (!isBackgroundSync && productList.isEmpty) {
      isLoading.value = true;
    }

    await Future.wait([
      fetchCategories(),
      fetchProducts(reset: true, isBackgroundSync: isBackgroundSync),
    ]);

    _lastFetchTime = DateTime.now();
    isLoading.value = false;
  }

  Future<void> fetchCategories() async {
    if (categories.isEmpty) {
      isCategoriesLoading.value = true;
    }
    final res = await MarketplaceApi.fetchCategories();
    if (res.isNotEmpty) {
      categories.assignAll(res);
      _cachedCategories
        ..clear()
        ..addAll(res);
    }
    isCategoriesLoading.value = false;
  }

  Future<void> fetchProducts({bool reset = false, bool isBackgroundSync = false}) async {
    if (reset) {
      currentPage = 1;
      hasNextPage = true;
      if (!isBackgroundSync && productList.isEmpty) {
        isLoading.value = true;
      }
    }

    final res = await MarketplaceApi.fetchProducts(
      page: currentPage,
      limit: 20,
      categoryId: selectedCategoryId.value == 'all' ? null : selectedCategoryId.value,
      search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
      sort: selectedSort.value,
    );

    if (reset) {
      // Differential update: Only update modified products in-place
      _smartSyncProducts(res);
      isLoading.value = false;

      if (selectedCategoryId.value == 'all' && searchQuery.value.isEmpty) {
        _cachedProducts
          ..clear()
          ..addAll(productList);
      }
    } else {
      productList.addAll(res);
      isMoreLoading.value = false;
    }

    if (res.length < 20) {
      hasNextPage = false;
    }
  }

  /// Differential Sync for Marketplace Products
  void _smartSyncProducts(List<MarketplaceProduct> freshList) {
    if (productList.isEmpty) {
      productList.assignAll(freshList);
      return;
    }

    if (freshList.isEmpty) {
      productList.clear();
      return;
    }

    final freshMap = <String, MarketplaceProduct>{};
    for (final p in freshList) {
      freshMap[p.id] = p;
    }

    for (int i = productList.length - 1; i >= 0; i--) {
      final current = productList[i];
      final fresh = freshMap[current.id];

      if (fresh == null) {
        productList.removeAt(i);
      } else {
        if (_hasProductChanged(current, fresh)) {
          productList[i] = fresh; // In-place update!
        }
        freshMap.remove(current.id);
      }
    }

    if (freshMap.isNotEmpty) {
      productList.addAll(freshMap.values);
    }

    if (productList.length == freshList.length) {
      for (int i = 0; i < freshList.length; i++) {
        if (productList[i].id != freshList[i].id) {
          productList.assignAll(freshList);
          break;
        }
      }
    }
  }

  bool _hasProductChanged(MarketplaceProduct a, MarketplaceProduct b) {
    if (a.title != b.title) return true;
    if (a.slug != b.slug) return true;
    if (a.description != b.description) return true;
    if (a.featuredImage != b.featuredImage) return true;
    if (a.price != b.price) return true;
    if (a.compareAtPrice != b.compareAtPrice) return true;
    if (a.inventory != b.inventory) return true;
    if (a.trackInventory != b.trackInventory) return true;
    if (a.status != b.status) return true;
    if (a.isActive != b.isActive) return true;
    if (a.sellerName != b.sellerName) return true;
    if (a.badge != b.badge) return true;
    if (a.rating != b.rating) return true;
    if (a.reviewCount != b.reviewCount) return true;
    return false;
  }

  Future<void> loadMoreProducts() async {
    if (!hasNextPage || isMoreLoading.value || isLoading.value) return;
    isMoreLoading.value = true;
    currentPage++;
    await fetchProducts(reset: false);
  }

  void selectCategory(String categoryId, String categoryName) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;
    fetchProducts(reset: true);
  }

  void onSearchSubmitted(String query) {
    searchQuery.value = query.trim();
    fetchProducts(reset: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchProducts(reset: true);
  }

  void changeSort(String sortKey) {
    if (selectedSort.value == sortKey) return;
    selectedSort.value = sortKey;
    fetchProducts(reset: true);
  }
}

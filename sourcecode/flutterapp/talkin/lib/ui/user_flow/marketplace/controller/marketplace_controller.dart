import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/marketplace/api/marketplace_api.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';

class MarketplaceController extends GetxController {
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
    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    await Future.wait([
      fetchCategories(),
      fetchProducts(reset: true),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;
    final res = await MarketplaceApi.fetchCategories();
    categories.assignAll(res);
    isCategoriesLoading.value = false;
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      hasNextPage = true;
      isLoading.value = true;
    }

    final res = await MarketplaceApi.fetchProducts(
      page: currentPage,
      limit: 20,
      categoryId: selectedCategoryId.value == 'all' ? null : selectedCategoryId.value,
      search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
      sort: selectedSort.value,
    );

    if (reset) {
      productList.assignAll(res);
      isLoading.value = false;
    } else {
      productList.addAll(res);
      isMoreLoading.value = false;
    }

    if (res.length < 20) {
      hasNextPage = false;
    }
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


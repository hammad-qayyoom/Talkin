import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fundraising/api/fundraising_api.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';

class FundraisingController extends GetxController {
  // Static in-memory cache to guarantee zero-latency screen restoration
  static FundraisingHeroConfig? _cachedHeroConfig;
  static FundraisingPromotionBanner? _cachedSpotlightBanner;
  static final List<FundraisingCategory> _cachedCategories = [];
  static final List<FundraisingCampaign> _cachedCampaigns = [];
  static final List<FoundationProgram> _cachedPrograms = [];
  static DateTime? _lastFetchTime;

  final isLoading = true.obs;
  final isLoadingCampaigns = true.obs;
  final isLoadingPrograms = true.obs;

  final heroConfig = FundraisingHeroConfig().obs;
  final spotlightBanner = Rxn<FundraisingPromotionBanner>();

  final categories = <FundraisingCategory>[].obs;
  final selectedCategorySlug = 'all'.obs;
  final selectedSort = 'featured'.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // 0: Campaigns, 1: Programs
  final selectedTabIndex = 0.obs;

  final campaignsList = <FundraisingCampaign>[].obs;
  final programsList = <FoundationProgram>[].obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Instant Cache Restoration: Restore everything immediately if available
    if (_cachedCampaigns.isNotEmpty || _cachedPrograms.isNotEmpty) {
      if (_cachedHeroConfig != null) heroConfig.value = _cachedHeroConfig!;
      spotlightBanner.value = _cachedSpotlightBanner;
      categories.assignAll(_cachedCategories);
      campaignsList.assignAll(_cachedCampaigns);
      programsList.assignAll(_cachedPrograms);

      isLoading.value = false;
      isLoadingCampaigns.value = false;
      isLoadingPrograms.value = false;

      final isStale = _lastFetchTime == null ||
          DateTime.now().difference(_lastFetchTime!).inSeconds > 20;
      if (isStale) {
        loadAll(isBackgroundSync: true);
      }
    } else {
      isLoading.value = true;
      loadAll(isBackgroundSync: false);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadAll({bool isBackgroundSync = false}) async {
    if (!isBackgroundSync && campaignsList.isEmpty && programsList.isEmpty) {
      isLoading.value = true;
    }

    await Future.wait([
      _loadConfigAndPromotions(),
      _loadCategories(),
      fetchCampaigns(isBackgroundSync: isBackgroundSync),
      fetchPrograms(isBackgroundSync: isBackgroundSync),
    ]);

    _lastFetchTime = DateTime.now();
    isLoading.value = false;
  }

  Future<void> _loadConfigAndPromotions() async {
    try {
      final config = await FundraisingApi.fetchFundraisingPageConfig();
      heroConfig.value = config;
      _cachedHeroConfig = config;

      final promos = await FundraisingApi.fetchPromotions(placement: 'fundraising');
      if (promos.isNotEmpty) {
        spotlightBanner.value = promos.first;
        _cachedSpotlightBanner = promos.first;
      }
    } catch (_) {}
  }

  Future<void> _loadCategories() async {
    try {
      final list = await FundraisingApi.fetchCampaignCategories();
      categories.assignAll(list);
      _cachedCategories
        ..clear()
        ..addAll(list);
    } catch (_) {}
  }

  Future<void> fetchCampaigns({bool isBackgroundSync = false}) async {
    if (!isBackgroundSync && campaignsList.isEmpty) {
      isLoadingCampaigns.value = true;
    }

    try {
      final fresh = await FundraisingApi.fetchCampaigns(
        categorySlug: selectedCategorySlug.value,
        search: searchQuery.value,
        sort: selectedSort.value,
      );

      _smartSyncCampaigns(fresh);

      if (selectedCategorySlug.value == 'all' && searchQuery.value.isEmpty) {
        _cachedCampaigns
          ..clear()
          ..addAll(campaignsList);
      }
    } catch (_) {
    } finally {
      isLoadingCampaigns.value = false;
    }
  }

  Future<void> fetchPrograms({bool isBackgroundSync = false}) async {
    if (!isBackgroundSync && programsList.isEmpty) {
      isLoadingPrograms.value = true;
    }

    try {
      final fresh = await FundraisingApi.fetchPrograms();
      _smartSyncPrograms(fresh);

      _cachedPrograms
        ..clear()
        ..addAll(programsList);
    } catch (_) {
    } finally {
      isLoadingPrograms.value = false;
    }
  }

  /// Differential Sync for Campaigns:
  /// Updates only modified fields (raised amount, donor count, progress %, text, image)
  /// without causing entire screen rebuilds.
  void _smartSyncCampaigns(List<FundraisingCampaign> freshList) {
    if (campaignsList.isEmpty) {
      campaignsList.assignAll(freshList);
      return;
    }

    if (freshList.isEmpty) {
      campaignsList.clear();
      return;
    }

    final freshMap = <String, FundraisingCampaign>{};
    for (final c in freshList) {
      freshMap[c.id] = c;
    }

    for (int i = campaignsList.length - 1; i >= 0; i--) {
      final current = campaignsList[i];
      final fresh = freshMap[current.id];

      if (fresh == null) {
        campaignsList.removeAt(i);
      } else {
        if (_hasCampaignChanged(current, fresh)) {
          campaignsList[i] = fresh; // In-place update!
        }
        freshMap.remove(current.id);
      }
    }

    if (freshMap.isNotEmpty) {
      campaignsList.addAll(freshMap.values);
    }

    if (campaignsList.length == freshList.length) {
      for (int i = 0; i < freshList.length; i++) {
        if (campaignsList[i].id != freshList[i].id) {
          campaignsList.assignAll(freshList);
          break;
        }
      }
    }
  }

  bool _hasCampaignChanged(FundraisingCampaign a, FundraisingCampaign b) {
    if (a.title != b.title) return true;
    if (a.slug != b.slug) return true;
    if (a.description != b.description) return true;
    if (a.content != b.content) return true;
    if (a.featuredImage != b.featuredImage) return true;
    if (a.goalAmount != b.goalAmount) return true;
    if (a.raisedAmount != b.raisedAmount) return true;
    if (a.percentage != b.percentage) return true;
    if (a.donorCount != b.donorCount) return true;
    if (a.totalDonations != b.totalDonations) return true;
    if (a.status != b.status) return true;
    if (a.isFeatured != b.isFeatured) return true;
    if (a.location != b.location) return true;
    if (a.beneficiary != b.beneficiary) return true;
    if (a.category?.id != b.category?.id) return true;
    return false;
  }

  /// Differential Sync for Programs
  void _smartSyncPrograms(List<FoundationProgram> freshList) {
    if (programsList.isEmpty) {
      programsList.assignAll(freshList);
      return;
    }

    if (freshList.isEmpty) {
      programsList.clear();
      return;
    }

    final freshMap = <String, FoundationProgram>{};
    for (final p in freshList) {
      freshMap[p.id] = p;
    }

    for (int i = programsList.length - 1; i >= 0; i--) {
      final current = programsList[i];
      final fresh = freshMap[current.id];

      if (fresh == null) {
        programsList.removeAt(i);
      } else {
        if (_hasProgramChanged(current, fresh)) {
          programsList[i] = fresh; // In-place update!
        }
        freshMap.remove(current.id);
      }
    }

    if (freshMap.isNotEmpty) {
      programsList.addAll(freshMap.values);
    }

    if (programsList.length == freshList.length) {
      for (int i = 0; i < freshList.length; i++) {
        if (programsList[i].id != freshList[i].id) {
          programsList.assignAll(freshList);
          break;
        }
      }
    }
  }

  bool _hasProgramChanged(FoundationProgram a, FoundationProgram b) {
    if (a.title != b.title) return true;
    if (a.slug != b.slug) return true;
    if (a.description != b.description) return true;
    if (a.content != b.content) return true;
    if (a.featuredImage != b.featuredImage) return true;
    if (a.impact != b.impact) return true;
    if (a.region != b.region) return true;
    if (a.location != b.location) return true;
    if (a.budget != b.budget) return true;
    if (a.status != b.status) return true;
    return false;
  }

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  void selectCategory(String categorySlug) {
    if (selectedCategorySlug.value == categorySlug) return;
    selectedCategorySlug.value = categorySlug;
    fetchCampaigns();
  }

  void onSearchSubmitted(String query) {
    searchQuery.value = query.trim();
    fetchCampaigns();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchCampaigns();
  }
}

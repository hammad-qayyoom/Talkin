import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/events/api/event_api.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';

class EventsController extends GetxController {
  // Static in-memory cache to ensure instant loading without blank screens
  static final List<FoundationEvent> _cachedEvents = [];
  static DateTime? _lastFetchTime;

  final isLoading = true.obs;
  final eventsList = <FoundationEvent>[].obs;

  final categories = [
    {'name': 'All Events', 'slug': 'all'},
    {'name': 'Conference', 'slug': 'conference'},
    {'name': 'Workshop', 'slug': 'workshop'},
    {'name': 'Seminar', 'slug': 'seminar'},
    {'name': 'Fundraiser', 'slug': 'fundraiser'},
    {'name': 'Community', 'slug': 'community'},
    {'name': 'Webinar', 'slug': 'webinar'},
    {'name': 'Training', 'slug': 'training'},
    {'name': 'Networking', 'slug': 'networking'},
  ];

  final selectedCategorySlug = 'all'.obs;
  final selectedSort = 'date'.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Instant Cache Restoration: If data was cached, restore immediately
    if (_cachedEvents.isNotEmpty) {
      eventsList.assignAll(_cachedEvents);
      isLoading.value = false;

      // Silently sync in background if cache is older than 20 seconds
      final isStale = _lastFetchTime == null ||
          DateTime.now().difference(_lastFetchTime!).inSeconds > 20;
      if (isStale) {
        loadEvents(isBackgroundSync: true);
      }
    } else {
      isLoading.value = true;
      loadEvents(isBackgroundSync: false);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadEvents({bool isBackgroundSync = false}) async {
    // Only show full loader if there's no data at all and it's not a background sync
    if (!isBackgroundSync && eventsList.isEmpty) {
      isLoading.value = true;
    }

    try {
      final freshList = await EventApi.fetchEvents(
        categorySlug: selectedCategorySlug.value,
        search: searchQuery.value,
        sort: selectedSort.value,
      );

      // Smart In-Place Diffing: Only update what changed in the database
      _smartSyncEvents(freshList);

      _lastFetchTime = DateTime.now();
      if (selectedCategorySlug.value == 'all' && searchQuery.value.isEmpty) {
        _cachedEvents
          ..clear()
          ..addAll(eventsList);
      }
    } catch (_) {
      // On network failure, retain cached data so user is never stranded with an empty screen
    } finally {
      isLoading.value = false;
    }
  }

  /// Smart Differential Sync:
  /// Updates only modified items in-place (text, image, tickets, pricing)
  /// so Flutter widgets don't flicker or re-render unnecessarily.
  void _smartSyncEvents(List<FoundationEvent> freshList) {
    if (eventsList.isEmpty) {
      eventsList.assignAll(freshList);
      return;
    }

    if (freshList.isEmpty) {
      eventsList.clear();
      return;
    }

    final freshMap = <String, FoundationEvent>{};
    for (final e in freshList) {
      freshMap[e.id] = e;
    }

    // 1. Update modified events in-place or remove deleted ones
    for (int i = eventsList.length - 1; i >= 0; i--) {
      final current = eventsList[i];
      final fresh = freshMap[current.id];

      if (fresh == null) {
        // Event was deleted in database
        eventsList.removeAt(i);
      } else {
        // Check if any property was modified in the database
        if (_hasEventChanged(current, fresh)) {
          eventsList[i] = fresh; // In-place update!
        }
        freshMap.remove(current.id);
      }
    }

    // 2. Append new events that were just added
    if (freshMap.isNotEmpty) {
      eventsList.addAll(freshMap.values);
    }

    // 3. Align order if necessary
    if (eventsList.length == freshList.length) {
      for (int i = 0; i < freshList.length; i++) {
        if (eventsList[i].id != freshList[i].id) {
          eventsList.assignAll(freshList);
          break;
        }
      }
    }
  }

  bool _hasEventChanged(FoundationEvent a, FoundationEvent b) {
    if (a.title != b.title) return true;
    if (a.slug != b.slug) return true;
    if (a.description != b.description) return true;
    if (a.content != b.content) return true;
    if (a.featuredImage != b.featuredImage) return true;
    if (a.venue != b.venue) return true;
    if (a.address != b.address) return true;
    if (a.city != b.city) return true;
    if (a.country != b.country) return true;
    if (a.isOnline != b.isOnline) return true;
    if (a.onlineUrl != b.onlineUrl) return true;
    if (a.organizerName != b.organizerName) return true;
    if (a.badge != b.badge) return true;
    if (a.priceFrom != b.priceFrom) return true;
    if (a.currency != b.currency) return true;
    if (a.startDateTime != b.startDateTime) return true;
    if (a.endDateTime != b.endDateTime) return true;
    if (a.status != b.status) return true;
    if (a.category?.id != b.category?.id) return true;
    if (a.tickets.length != b.tickets.length) return true;

    for (int i = 0; i < a.tickets.length; i++) {
      final ta = a.tickets[i];
      final tb = b.tickets[i];
      if (ta.price != tb.price ||
          ta.soldCount != tb.soldCount ||
          ta.quantity != tb.quantity ||
          ta.isActive != tb.isActive) {
        return true;
      }
    }
    return false;
  }

  void selectCategory(String slug) {
    if (selectedCategorySlug.value == slug) return;
    selectedCategorySlug.value = slug;
    loadEvents();
  }

  void onSearchSubmitted(String q) {
    searchQuery.value = q.trim();
    loadEvents();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadEvents();
  }
}

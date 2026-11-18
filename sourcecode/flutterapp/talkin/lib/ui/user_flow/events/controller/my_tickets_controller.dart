import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/events/api/event_api.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';
import 'package:notisboard/utils/database.dart';

class MyTicketsController extends GetxController {
  final isLoading = true.obs;
  final allTickets = <EventRegistrationRecord>[].obs;
  final filteredTickets = <EventRegistrationRecord>[].obs;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Resolved user email from logged in profile / session
  String get userEmail => Database.resolvedUserEmail;

  // Backwards compatibility alias for any existing bindings
  RxList<EventRegistrationRecord> get tickets => filteredTickets;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    final email = userEmail;
    if (email.isNotEmpty) {
      final list = await EventApi.fetchUserTickets(email);
      allTickets.assignAll(list);
      _applySearchFilter();
    } else {
      allTickets.clear();
      filteredTickets.clear();
    }
    isLoading.value = false;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applySearchFilter();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applySearchFilter();
  }

  void _applySearchFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredTickets.assignAll(allTickets);
      return;
    }

    final filtered = allTickets.where((t) {
      final ref = t.bookingReference.toLowerCase();
      final title = t.eventTitle.toLowerCase();
      final attendee = t.attendeeName.toLowerCase();
      final status = t.status.toLowerCase();
      final venue = (t.venue ?? '').toLowerCase();
      final ticketType = (t.ticketName ?? '').toLowerCase();
      final amount = t.totalAmount.toString();
      final amountFormatted = t.totalAmount.toStringAsFixed(2);

      return ref.contains(query) ||
          title.contains(query) ||
          attendee.contains(query) ||
          status.contains(query) ||
          venue.contains(query) ||
          ticketType.contains(query) ||
          amount.contains(query) ||
          amountFormatted.contains(query);
    }).toList();

    filteredTickets.assignAll(filtered);
  }
}

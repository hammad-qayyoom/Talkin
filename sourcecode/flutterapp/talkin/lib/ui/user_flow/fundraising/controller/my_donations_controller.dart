import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fundraising/api/fundraising_api.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/database.dart';

class MyDonationsController extends GetxController {
  final isLoading = true.obs;
  final allDonations = <DonationRecord>[].obs;
  final filteredDonations = <DonationRecord>[].obs;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Resolved user email from logged in profile / session
  String get userEmail => Database.resolvedUserEmail;

  // Backwards compatibility alias for any existing bindings
  RxList<DonationRecord> get donations => filteredDonations;

  @override
  void onInit() {
    super.onInit();
    loadDonations();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadDonations() async {
    isLoading.value = true;
    final email = userEmail;
    if (email.isNotEmpty) {
      final list = await FundraisingApi.fetchUserDonations(email);
      allDonations.assignAll(list);
      _applySearchFilter();
    } else {
      allDonations.clear();
      filteredDonations.clear();
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
      filteredDonations.assignAll(allDonations);
      return;
    }

    final filtered = allDonations.where((d) {
      final receipt = d.receiptNumber.toLowerCase();
      final cause = (d.causeTitle ?? '').toLowerCase();
      final status = d.status.toLowerCase();
      final method = d.paymentMethod.toLowerCase();
      final amount = d.amount.toString();
      final amountFormatted = d.amount.toStringAsFixed(2);

      return receipt.contains(query) ||
          cause.contains(query) ||
          status.contains(query) ||
          method.contains(query) ||
          amount.contains(query) ||
          amountFormatted.contains(query);
    }).toList();

    filteredDonations.assignAll(filtered);
  }
}

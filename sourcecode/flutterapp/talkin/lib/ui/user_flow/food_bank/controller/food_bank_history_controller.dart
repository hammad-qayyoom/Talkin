import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/food_bank/api/food_bank_api.dart';
import 'package:notisboard/ui/user_flow/food_bank/model/food_bank_model.dart';
import 'package:notisboard/utils/database.dart';

class FoodBankHistoryController extends GetxController {
  final isLoading = true.obs;
  final donations = <FoodBankDonationRecord>[].obs;
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final savedEmail = _resolveEmail();
    emailController.text = savedEmail;
    loadDonations();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String _resolveEmail() {
    final userEmail = Database.fetchLoginUserProfileModel?.user?.email?.trim() ?? '';
    if (userEmail.isNotEmpty) return userEmail;
    final cached = Database.localStorage.read('last_food_bank_donor_email') ??
        Database.localStorage.read('last_donor_email') ??
        Database.localStorage.read('last_ticket_email');
    if (cached is String && cached.trim().isNotEmpty) return cached.trim();
    return '';
  }

  Future<void> loadDonations([String? overrideEmail]) async {
    isLoading.value = true;
    final email = (overrideEmail ?? emailController.text).trim();
    if (email.isNotEmpty) {
      Database.localStorage.write('last_food_bank_donor_email', email);
      final list = await FoodBankApi.fetchUserDonations(email);
      donations.assignAll(list);
    } else {
      donations.clear();
    }
    isLoading.value = false;
  }
}


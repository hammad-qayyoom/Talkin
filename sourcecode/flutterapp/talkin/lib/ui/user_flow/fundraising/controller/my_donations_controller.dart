import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fundraising/api/fundraising_api.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/database.dart';

class MyDonationsController extends GetxController {
  final isLoading = true.obs;
  final donations = <DonationRecord>[].obs;
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final savedEmail = _resolveDonorEmail();
    emailController.text = savedEmail;
    loadDonations();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String _resolveDonorEmail() {
    final userEmail = Database.fetchLoginUserProfileModel?.user?.email?.trim() ?? '';
    if (userEmail.isNotEmpty) return userEmail;
    final cached = Database.localStorage.read('last_donor_email');
    if (cached is String && cached.trim().isNotEmpty) return cached.trim();
    return '';
  }

  Future<void> loadDonations([String? overrideEmail]) async {
    isLoading.value = true;
    final email = (overrideEmail ?? emailController.text).trim();
    if (email.isNotEmpty) {
      Database.localStorage.write('last_donor_email', email);
      final list = await FundraisingApi.fetchUserDonations(email);
      donations.assignAll(list);
    } else {
      donations.clear();
    }
    isLoading.value = false;
  }
}

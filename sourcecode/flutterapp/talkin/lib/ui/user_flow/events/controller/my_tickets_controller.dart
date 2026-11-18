import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/events/api/event_api.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';
import 'package:notisboard/utils/database.dart';

class MyTicketsController extends GetxController {
  final isLoading = true.obs;
  final tickets = <EventRegistrationRecord>[].obs;
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final savedEmail = _resolveEmail();
    emailController.text = savedEmail;
    loadTickets();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String _resolveEmail() {
    final userEmail = Database.fetchLoginUserProfileModel?.user?.email?.trim() ?? '';
    if (userEmail.isNotEmpty) return userEmail;
    final cached = Database.localStorage.read('last_ticket_email') ?? Database.localStorage.read('last_donor_email');
    if (cached is String && cached.trim().isNotEmpty) return cached.trim();
    return '';
  }

  Future<void> loadTickets([String? overrideEmail]) async {
    isLoading.value = true;
    final email = (overrideEmail ?? emailController.text).trim();
    if (email.isNotEmpty) {
      Database.localStorage.write('last_ticket_email', email);
      final list = await EventApi.fetchUserTickets(email);
      tickets.assignAll(list);
    } else {
      tickets.clear();
    }
    isLoading.value = false;
  }
}


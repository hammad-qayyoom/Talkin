import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank/controller/food_bank_history_controller.dart';
import 'package:notisboard/ui/user_flow/food_bank/model/food_bank_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FoodBankHistoryScreen extends GetView<FoodBankHistoryController> {
  const FoodBankHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FoodBankHistoryController>()) {
      Get.put(FoodBankHistoryController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Food Bank Donations',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Column(
        children: [
          // Email Lookup Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            onSubmitted: (val) => controller.loadDonations(val),
                            decoration: InputDecoration(
                              hintText: 'Enter donor email to view receipts',
                              hintStyle: AppFontStyle.fontStyleW400(
                                fontSize: 12.5,
                                fontColor: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller.loadDonations(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadDonations,
              color: const Color(0xFFE11D48),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)));
                }

                if (controller.donations.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.volunteer_activism_outlined,
                              size: 64,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No Food Bank Donations Found',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 17,
                                fontColor: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No contributions recorded for ${controller.emailController.text.trim().isNotEmpty ? controller.emailController.text.trim() : "this account"}. Support the Food Bank with an emergency food parcel today.',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 13,
                                fontColor: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Get.toNamed(AppRoutes.foodBankDonateScreen),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Donate Now'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.donations.length,
                  itemBuilder: (context, index) {
                    final d = controller.donations[index];
                    return _buildDonationCard(context, d);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context, FoodBankDonationRecord d) {
    final currencySymbol = d.currency == 'CAD' ? 'CA\$' : '\$';

    String formattedDate = '';
    if (d.donatedAt != null && d.donatedAt!.isNotEmpty) {
      try {
        final parsed = DateTime.parse(d.donatedAt!);
        formattedDate = DateFormat('EEE, d MMM yyyy • h:mm a').format(parsed);
      } catch (_) {
        formattedDate = d.donatedAt!;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      d.donationRef,
                      style: AppFontStyle.fontStyleW800(
                        fontSize: 13,
                        fontColor: const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: d.donationRef));
                        Get.snackbar(
                          'Copied',
                          'Reference copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF0F172A),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    d.status.toUpperCase(),
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 10.5,
                      fontColor: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Food Bank Assistance Fund',
              style: AppFontStyle.fontStyleW700(
                fontSize: 15,
                fontColor: const Color(0xFF0F172A),
              ),
            ),
            if (formattedDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: AppFontStyle.fontStyleW400(
                  fontSize: 11.5,
                  fontColor: const Color(0xFF64748B),
                ),
              ),
            ],
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currencySymbol${d.amount.toStringAsFixed(2)}',
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 16,
                    fontColor: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'via ${d.paymentGateway}',
                  style: AppFontStyle.fontStyleW400(
                    fontSize: 11.5,
                    fontColor: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


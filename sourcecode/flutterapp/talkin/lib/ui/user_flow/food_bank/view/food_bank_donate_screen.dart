import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank/controller/food_bank_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FoodBankDonateScreen extends GetView<FoodBankController> {
  const FoodBankDonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FoodBankController>()) {
      Get.put(FoodBankController());
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
          'Donate to Food Bank',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'My Giving History',
            icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFFE11D48)),
            onPressed: () => Get.toNamed(AppRoutes.foodBankHistoryScreen),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)));
        }

        final cfg = controller.config.value;
        if (cfg == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                Text(
                  'Could not connect to Food Bank service',
                  style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: const Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.loadConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Disabled State
        if (!cfg.isEnabled || !cfg.enableMobileApp) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pause_circle_outline_rounded, size: 40, color: Color(0xFFE11D48)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Donations Currently Paused',
                    style: AppFontStyle.fontStyleW800(fontSize: 18, fontColor: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Food Bank contributions from the mobile application are temporarily paused by the administration. Please check back soon.',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW400(fontSize: 13, fontColor: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          );
        }

        final currencySymbol = cfg.currency == 'CAD' ? 'CA\$' : '\$';

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Hero Food Bank Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF881337), Color(0xFFBE123C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBE123C).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cfg.title,
                          style: AppFontStyle.fontStyleW800(
                            fontSize: 17,
                            fontColor: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '100% DIRECT',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 9.5,
                            fontColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cfg.description,
                    style: AppFontStyle.fontStyleW400(
                      fontSize: 12.5,
                      fontColor: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Predefined Amount Selector
            if (cfg.enablePredefinedAmounts && cfg.amounts.isNotEmpty) ...[
              Text(
                'Select Giving Tier',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cfg.amounts.map((tier) {
                  final isSelected = !controller.isCustomAmount.value &&
                      controller.selectedAmount.value == tier.amount;
                  return ChoiceChip(
                    label: Text(
                      '$currencySymbol${tier.amount.toStringAsFixed(0)}',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 13,
                        fontColor: isSelected ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE11D48),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    onSelected: (_) => controller.selectPredefinedAmount(tier.amount),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Custom Amount Input
            if (cfg.enableCustomAmount) ...[
              Text(
                'Or Custom Gift Amount',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: controller.isCustomAmount.value
                        ? const Color(0xFFE11D48)
                        : const Color(0xFFCBD5E1),
                    width: controller.isCustomAmount.value ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      currencySymbol,
                      style: AppFontStyle.fontStyleW800(
                        fontSize: 16,
                        fontColor: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller.customAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onTap: controller.enableCustomAmountMode,
                        onChanged: controller.onCustomAmountChanged,
                        decoration: InputDecoration(
                          hintText: 'Enter amount (${cfg.minAmount.toStringAsFixed(0)} - ${cfg.maxAmount.toStringAsFixed(0)})',
                          hintStyle: AppFontStyle.fontStyleW400(
                            fontSize: 13,
                            fontColor: const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Donor Information Form Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Donor Information',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 14,
                      fontColor: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField('Full Name', controller.nameController, 'Your name or alias'),
                  const SizedBox(height: 10),
                  _buildInputField(
                    'Email Address (for receipt)',
                    controller.emailController,
                    'example@domain.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    'Phone Number (Optional)',
                    controller.phoneController,
                    '+1 555-0199',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    'Dedication / Message (Optional)',
                    controller.messageController,
                    'In memory of, or words of encouragement',
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Payment Gateways Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Gateway',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 14,
                          fontColor: const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ADMIN VERIFIED',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 9.5,
                            fontColor: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...controller.availableGateways.map((gw) {
                    final isSelected = controller.selectedGatewayId.value == gw.id;
                    return GestureDetector(
                      onTap: () => controller.selectedGatewayId.value = gw.id,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              gw.icon,
                              size: 20,
                              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gw.title,
                                    style: AppFontStyle.fontStyleW700(
                                      fontSize: 13,
                                      fontColor: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    gw.subtitle,
                                    style: AppFontStyle.fontStyleW400(
                                      fontSize: 11,
                                      fontColor: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFCBD5E1),
                                  width: isSelected ? 6 : 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : controller.processDonation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: const Color(0xFFE11D48).withValues(alpha: 0.6),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Donate $currencySymbol${controller.selectedAmount.value.toStringAsFixed(2)} to Food Bank',
                        style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: Colors.white),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW600(fontSize: 11.5, fontColor: const Color(0xFF475569)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppFontStyle.fontStyleW400(fontSize: 12.5, fontColor: const Color(0xFF94A3B8)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

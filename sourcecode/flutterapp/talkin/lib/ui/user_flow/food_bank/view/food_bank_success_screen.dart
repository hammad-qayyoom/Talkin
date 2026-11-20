import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank/model/food_bank_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FoodBankSuccessScreen extends StatelessWidget {
  const FoodBankSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final record = Get.arguments as FoodBankDonationRecord?;
    final currencySymbol = record?.currency == 'CAD' ? 'CA\$' : '\$';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offNamedUntil(AppRoutes.homeScreen, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Heart / Food bank badge
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFE11D48),
                      size: 58,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'Donation Received!',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 22,
                    fontColor: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Thank you for supporting our Food Bank! Your generous contribution brings vital nourishment and hope to families.',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW400(
                    fontSize: 13,
                    fontColor: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Receipt Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow(
                        'Donation Reference',
                        record?.donationRef ?? 'FBD-VERIFIED',
                        isCopyable: true,
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildReceiptRow('Donor Name', record?.donorName ?? 'Anonymous Donor'),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildReceiptRow('Donor Email', record?.donorEmail ?? '—'),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildReceiptRow('Payment Gateway', record?.paymentGateway ?? 'Online Payment'),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildReceiptRow('Status', record?.status.toUpperCase() ?? 'COMPLETED',
                          valueColor: const Color(0xFFE11D48), isBold: true),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildReceiptRow(
                        'Total Amount',
                        '$currencySymbol${(record?.amount ?? 0.0).toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: const Color(0xFF0F172A),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offNamedUntil(AppRoutes.homeScreen, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Back to Home',
                      style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offNamed(AppRoutes.foodBankHistoryScreen);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'View My Giving History',
                      style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: const Color(0xFF0F172A)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    bool isCopyable = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW500(
            fontSize: 12.5,
            fontColor: const Color(0xFF64748B),
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: isBold
                      ? AppFontStyle.fontStyleW800(
                          fontSize: 14.5,
                          fontColor: valueColor ?? const Color(0xFF0F172A),
                        )
                      : AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: valueColor ?? const Color(0xFF0F172A),
                        ),
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
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
            ],
          ),
        ),
      ],
    );
  }
}


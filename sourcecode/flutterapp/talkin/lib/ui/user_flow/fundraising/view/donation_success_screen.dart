import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class DonationSuccessScreen extends StatelessWidget {
  const DonationSuccessScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;

  @override
  Widget build(BuildContext context) {
    final record = Get.arguments as DonationRecord?;

    final symbol = (record?.currency == 'CAD')
        ? 'CA\$'
        : (record?.currency == 'USD')
            ? '\$'
            : '${record?.currency ?? "CAD"} ';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offNamedUntil(AppRoutes.fundraisingHomeScreen, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated/Styled Success Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF059669),
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Donation Verified!',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 22,
                    fontColor: _brandDark,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Your contribution has been successfully processed and allocated directly to the mission.',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW400(
                    fontSize: 13.5,
                    fontColor: _slateGrey,
                  ),
                ),
                const SizedBox(height: 28),

                // Receipt Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _softBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Receipt Ref', record?.receiptNumber ?? 'DON-COMPLETED'),
                      Divider(height: 24, color: _softBorder),
                      _buildReceiptRow('Cause / Mission', record?.causeTitle ?? 'General Foundation Fund'),
                      Divider(height: 24, color: _softBorder),
                      _buildReceiptRow(
                        'Amount Contributed',
                        '$symbol${(record?.amount ?? 0.0).toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: _brandRed,
                      ),
                      Divider(height: 24, color: _softBorder),
                      _buildReceiptRow('Payment Method', record?.paymentMethod ?? 'Online'),
                      Divider(height: 24, color: _softBorder),
                      _buildReceiptRow('Allocation Status', '100% Direct Field Aid'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tax Deductible Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF047857).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF047857).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF047857), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'An official tax-deductible donation receipt has been sent to your email.',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 11.5,
                            fontColor: const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offNamedUntil(AppRoutes.fundraisingHomeScreen, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Back to Fundraising Hub',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offNamed(AppRoutes.myDonationsScreen);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brandRed,
                      side: BorderSide(color: _brandRed.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View My Giving History',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 14,
                        fontColor: _brandRed,
                      ),
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

  Widget _buildReceiptRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW500(
            fontSize: 12.5,
            fontColor: _slateGrey,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: isBold
                ? AppFontStyle.fontStyleW800(
                    fontSize: 14.5,
                    fontColor: valueColor ?? _brandDark,
                  )
                : AppFontStyle.fontStyleW600(
                    fontSize: 13,
                    fontColor: valueColor ?? _brandDark,
                  ),
          ),
        ),
      ],
    );
  }
}

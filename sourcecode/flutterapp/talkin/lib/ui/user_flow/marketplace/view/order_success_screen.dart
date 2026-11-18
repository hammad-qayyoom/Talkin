import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments is Map<String, dynamic>
        ? Get.arguments as Map<String, dynamic>
        : {};

    final orderNumber = args['orderNumber']?.toString() ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final total = args['total'] != null
        ? (args['total'] is num
            ? (args['total'] as num).toDouble()
            : double.tryParse(args['total'].toString()) ?? 0.0)
        : 0.0;
    final email = args['email']?.toString() ?? 'your email';
    final paymentMethod = args['paymentMethod']?.toString() ?? 'Online Payment';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offAllNamed(AppRoutes.bottomBar);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Success Icon
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 52,
                      color: AppColors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Order Placed Successfully!',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 22,
                    fontColor: _brandDark,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Thank you for supporting independent artisan livelihoods.',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW400(
                    fontSize: 13.5,
                    fontColor: AppColors.redesignSlateGrey,
                  ),
                ),
                const SizedBox(height: 24),

                // Order Details Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _softBorder),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Order Reference', orderNumber, isBold: true),
                      const SizedBox(height: 10),
                      _buildReceiptRow('Payment Method', paymentMethod),
                      const SizedBox(height: 10),
                      _buildReceiptRow('Total Amount', 'CA\$${total.toStringAsFixed(2)}', valueColor: _brandRed, isBold: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        children: [
                          Icon(Icons.mark_email_read_outlined, size: 16, color: AppColors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confirmation sent to $email',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 11.5,
                                fontColor: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Synchronized Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync_rounded, size: 18, color: AppColors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Synchronized with Foundation Admin Fulfillment & Vendor Portal in real-time.',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 11.5,
                            fontColor: const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Buttons
                ElevatedButton(
                  onPressed: () {
                    Get.offNamed(AppRoutes.marketplaceMyOrdersScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandDark,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'View My Orders',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 14.5,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Get.offNamed(AppRoutes.marketplaceHomeScreen);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _brandRed, width: 1.5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 14.5,
                      fontColor: _brandRed,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
            fontColor: AppColors.redesignSlateGrey,
          ),
        ),
        Text(
          value,
          style: isBold
              ? AppFontStyle.fontStyleW700(
                  fontSize: 13,
                  fontColor: valueColor ?? AppColors.redesignBrandDark,
                )
              : AppFontStyle.fontStyleW600(
                  fontSize: 12.5,
                  fontColor: valueColor ?? AppColors.redesignBrandDark,
                ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class TicketPassScreen extends StatelessWidget {
  const TicketPassScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;

  @override
  Widget build(BuildContext context) {
    final record = Get.arguments as EventRegistrationRecord?;

    final currencySymbol = record?.currency == 'CAD' ? 'CA\$' : '\$';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offNamedUntil(AppRoutes.eventsHomeScreen, (route) => route.isFirst);
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

                // Animated/Styled Green Checkmark
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF059669),
                      size: 58,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Booking Confirmed!',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 22,
                    fontColor: _brandDark,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Your tickets for ${record?.eventTitle ?? "Event"} have been secured. A confirmation pass has been registered for ${record?.email ?? "your account"}.',
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW400(
                    fontSize: 13,
                    fontColor: _slateGrey,
                  ),
                ),
                const SizedBox(height: 24),

                // Tracking Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'BOOKING TRACKING REFERENCE',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 10,
                          fontColor: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            record?.bookingReference ?? 'NTB-TKT-CONFIRMED',
                            style: AppFontStyle.fontStyleW800(
                              fontSize: 16,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              if (record?.bookingReference != null) {
                                Clipboard.setData(ClipboardData(text: record!.bookingReference));
                                Utils.showToast(context, 'Tracking reference copied!');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                'Copy',
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 11,
                                  fontColor: _brandRed,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Keep this reference code to track or check in to your event.',
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 11,
                          fontColor: const Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _softBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Event', record?.eventTitle ?? 'Event Pass'),
                      Divider(height: 18, color: _softBorder),
                      _buildReceiptRow('Venue / Format', record?.venue ?? (record?.isOnline == true ? 'Virtual Event' : 'In-Person')),
                      Divider(height: 18, color: _softBorder),
                      _buildReceiptRow('Tickets Quantity', '${record?.quantity ?? 1} Ticket(s)'),
                      Divider(height: 18, color: _softBorder),
                      _buildReceiptRow(
                        'Total Amount',
                        '$currencySymbol${(record?.totalAmount ?? 0.0).toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: const Color(0xFF047857),
                      ),
                      Divider(height: 18, color: _softBorder),
                      _buildReceiptRow('Payment Method', record?.paymentMethod ?? 'Online'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Sync Notice
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
                          '✓ Connected to your Foundation Account. This ticket is automatically synced with your Member Console.',
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
                      Get.offNamedUntil(AppRoutes.eventsHomeScreen, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Back to Events Hub',
                      style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offNamed(AppRoutes.myTicketsScreen);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brandRed,
                      side: BorderSide(color: _brandRed.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'View in My Tickets',
                      style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: _brandRed),
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

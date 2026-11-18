// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/ui/user_flow/events/controller/event_booking_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class EventBookingScreen extends GetView<EventBookingController> {
  const EventBookingScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _brandDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Get Tickets',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: _brandDark,
          ),
        ),
      ),
      body: Obx(() {
        final ev = controller.event.value;
        if (ev == null) {
          return const Center(child: Text('Event details unavailable.'));
        }

        final currencySymbol = ev.currency == 'CAD' ? 'CA\$' : '\$';
        final subtotal = controller.subtotal;
        final commission = controller.platformCommission;
        final grandTotal = controller.grandTotal;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Card Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _softBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.025),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (ev.featuredImage != null && ev.featuredImage!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: ev.featuredImage!,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const AppImageShimmer(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: _accentSoftBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.event_rounded, color: _brandRed.withValues(alpha: 0.5)),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: _accentSoftBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.event_rounded, color: _brandRed.withValues(alpha: 0.5)),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ev.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 15,
                                    fontColor: _brandDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  ev.locationDisplay,
                                  style: AppFontStyle.fontStyleW400(
                                    fontSize: 11.5,
                                    fontColor: _slateGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Selected Tickets Summary
                    Text(
                      'Chosen Tickets (${controller.totalTicketsCount})',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _softBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.025),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: controller.selectedTickets.entries.map((entry) {
                          final ticket = ev.tickets.firstWhereOrNull((t) => t.id == entry.key);
                          final name = ticket?.name ?? 'Admission Ticket';
                          final price = ticket?.price ?? 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$name x ${entry.value}',
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 13,
                                    fontColor: _brandDark,
                                  ),
                                ),
                                Text(
                                  '$currencySymbol${(price * entry.value).toStringAsFixed(2)}',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 13,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Attendee Details
                    Text(
                      'Attendee Information',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: controller.firstNameController,
                            label: 'First Name *',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: controller.lastNameController,
                            label: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: controller.emailController,
                      label: 'Email Address *',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: controller.phoneController,
                      label: 'Phone Number (Optional)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: controller.notesController,
                      label: 'Special Requests / Notes (Optional)',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),

                    // Order Summary
                    Text(
                      'Order Summary',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _softBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.025),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tickets Subtotal',
                                style: AppFontStyle.fontStyleW400(
                                  fontSize: 13,
                                  fontColor: _slateGrey,
                                ),
                              ),
                              Text(
                                '$currencySymbol${subtotal.toStringAsFixed(2)}',
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 13,
                                  fontColor: _brandDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '+ Platform Commission (4%)',
                                style: AppFontStyle.fontStyleW400(
                                  fontSize: 13,
                                  fontColor: _slateGrey,
                                ),
                              ),
                              Text(
                                '+$currencySymbol${commission.toStringAsFixed(2)}',
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 13,
                                  fontColor: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 20, color: _softBorder),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Grand Total',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 15,
                                  fontColor: _brandDark,
                                ),
                              ),
                              Text(
                                '$currencySymbol${grandTotal.toStringAsFixed(2)}',
                                style: AppFontStyle.fontStyleW800(
                                  fontSize: 17,
                                  fontColor: _brandRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Gateways (Strict App Admin Filter)
                    if (grandTotal > 0) ...[
                      Row(
                        children: [
                          Icon(Icons.payment_rounded, size: 18, color: _brandRed),
                          const SizedBox(width: 6),
                          Text(
                            'Payment Gateway',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 15,
                              fontColor: _brandDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active payment providers configured by administrator',
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 11.5,
                          fontColor: _slateGrey,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ...controller.availableGateways.map((g) {
                        final isSelected = controller.selectedGatewayKey.value == g.key;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? _brandRed : _softBorder,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _brandRed.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: RadioListTile<String>(
                            value: g.key,
                            groupValue: controller.selectedGatewayKey.value,
                            onChanged: (val) {
                              if (val != null) controller.selectGateway(val);
                            },
                            activeColor: _brandRed,
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _accentSoftBg
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                g.icon,
                                color: isSelected ? _brandRed : _slateGrey,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              g.title,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 13.5,
                                fontColor: _brandDark,
                              ),
                            ),
                            subtitle: Text(
                              g.subtitle,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 11.5,
                                fontColor: _slateGrey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Submit Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          grandTotal > 0
                              ? 'Place Order & Pay $currencySymbol${grandTotal.toStringAsFixed(2)}'
                              : 'Complete Free Registration',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 14.5,
                            fontColor: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppFontStyle.fontStyleW500(
        fontSize: 13,
        fontColor: _brandDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFontStyle.fontStyleW400(
          fontSize: 13,
          fontColor: _slateGrey,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _brandRed, width: 1.5),
        ),
      ),
    );
  }
}

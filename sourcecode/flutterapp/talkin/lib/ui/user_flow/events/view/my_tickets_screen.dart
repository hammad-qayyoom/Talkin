import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/events/controller/my_tickets_controller.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class MyTicketsScreen extends GetView<MyTicketsController> {
  const MyTicketsScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MyTicketsController>()) {
      Get.put(MyTicketsController());
    }

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
          'My Tickets & Passes',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: _brandDark,
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
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _softBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, size: 18, color: _slateGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            onSubmitted: (val) => controller.loadTickets(val),
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 13,
                              fontColor: _brandDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter attendee email to find passes',
                              hintStyle: AppFontStyle.fontStyleW400(
                                fontSize: 12.5,
                                fontColor: _slateGrey,
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
                  onPressed: () => controller.loadTickets(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _softBorder),

          // Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadTickets,
              color: _brandRed,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: _brandRed));
                }

                if (controller.tickets.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.confirmation_number_outlined,
                              size: 64,
                              color: _brandRed.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No Tickets Found',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 17,
                                fontColor: _brandDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No event registrations found for ${controller.emailController.text.trim().isNotEmpty ? controller.emailController.text.trim() : "this account"}. Search by the booking email or register for upcoming events.',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 13,
                                fontColor: _slateGrey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Get.toNamed(AppRoutes.eventsHomeScreen),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brandRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Browse Events'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.tickets.length,
                  itemBuilder: (context, index) {
                    final t = controller.tickets[index];
                    return _buildTicketCard(context, t);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, EventRegistrationRecord t) {
    final currencySymbol = t.currency == 'CAD' ? 'CA\$' : '\$';

    String formattedDate = '';
    if (t.eventDate != null && t.eventDate!.isNotEmpty) {
      try {
        final parsed = DateTime.parse(t.eventDate!);
        formattedDate = DateFormat('EEE, d MMM yyyy • h:mm a').format(parsed);
      } catch (_) {
        formattedDate = t.eventDate!;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reference & Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: _softBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _accentSoftBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.qr_code_2_rounded, size: 16, color: _brandRed),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.bookingReference,
                      style: AppFontStyle.fontStyleW800(
                        fontSize: 12.5,
                        fontColor: _brandRed,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: t.bookingReference));
                        Get.snackbar(
                          'Copied',
                          'Booking reference copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: _brandDark,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Icon(Icons.copy_rounded, size: 14, color: _slateGrey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t.status.toUpperCase(),
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 10.5,
                      fontColor: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.eventTitle,
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 16,
                    fontColor: _brandDark,
                  ),
                ),
                const SizedBox(height: 10),

                if (formattedDate.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: _slateGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: _slateGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                Row(
                  children: [
                    Icon(
                      t.isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
                      size: 15,
                      color: _slateGrey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t.isOnline ? 'Online Event (Link sent upon pass verification)' : (t.venue ?? 'Venue announced soon'),
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: _slateGrey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Divider(height: 1, color: _softBorder),
                const SizedBox(height: 12),

                // Attendee + Pricing row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendee & Ticket',
                          style: AppFontStyle.fontStyleW400(
                            fontSize: 11,
                            fontColor: _slateGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${t.attendeeName} • ${t.quantity} ${t.quantity > 1 ? 'tickets' : 'ticket'}',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 13,
                            fontColor: _brandDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Paid Amount',
                          style: AppFontStyle.fontStyleW400(
                            fontSize: 11,
                            fontColor: _slateGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$currencySymbol${t.totalAmount.toStringAsFixed(2)}',
                          style: AppFontStyle.fontStyleW800(
                            fontSize: 15,
                            fontColor: _brandRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // View Digital Pass Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(AppRoutes.ticketPassScreen, arguments: t);
                    },
                    icon: const Icon(Icons.qr_code_rounded, size: 16),
                    label: const Text('View Official Pass'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

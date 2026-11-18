import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/events/controller/event_detail_controller.dart';
import 'package:notisboard/ui/user_flow/events/shimmer/events_shimmer.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class EventDetailScreen extends GetView<EventDetailController> {
  const EventDetailScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.isLoading.value && controller.event.value == null) {
          return const EventDetailShimmer();
        }

        final event = controller.event.value;
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Event Details')),
            body: const Center(child: Text('Event not found.')),
          );
        }

        final currencySymbol = event.currency == 'CAD' ? 'CA\$' : '\$';

        String dateFormatted = '';
        String timeFormatted = '';
        if (event.startDateTime != null && event.startDateTime!.isNotEmpty) {
          try {
            final startDt = DateTime.parse(event.startDateTime!).toLocal();
            dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(startDt);
            timeFormatted = DateFormat('hh:mm a').format(startDt);
            if (event.endDateTime != null && event.endDateTime!.isNotEmpty) {
              final endDt = DateTime.parse(event.endDateTime!).toLocal();
              timeFormatted += ' - ${DateFormat('hh:mm a').format(endDt)}';
            }
          } catch (_) {}
        }

        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App Bar with Cover
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: AppColors.redesignBrandRedDeep,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                      onPressed: () => Get.back(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: event.featuredImage != null && event.featuredImage!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: event.featuredImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const AppImageShimmer(
                                borderRadius: BorderRadius.zero,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: _accentSoftBg,
                                child: Icon(Icons.event_rounded, color: _brandRed.withValues(alpha: 0.5), size: 50),
                              ),
                            )
                          : Container(
                              color: _accentSoftBg,
                              child: Icon(Icons.event_rounded, color: _brandRed.withValues(alpha: 0.5), size: 50),
                            ),
                    ),
                  ),

                  // Event Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges Row
                          Row(
                            children: [
                              if (event.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _accentSoftBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _brandRed.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    event.category!.name,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 11,
                                      fontColor: _brandRed,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: event.isOnline
                                      ? const Color(0xFF047857).withValues(alpha: 0.1)
                                      : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  event.isOnline ? 'Virtual Event' : 'In-Person',
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 11,
                                    fontColor: event.isOnline ? const Color(0xFF047857) : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            event.title,
                            style: AppFontStyle.fontStyleW800(
                              fontSize: 22,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Event Info Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _softBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.025),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (dateFormatted.isNotEmpty) ...[
                                  _buildInfoRow(Icons.calendar_today_rounded, dateFormatted, timeFormatted),
                                  Divider(height: 20, color: _softBorder),
                                ],
                                _buildInfoRow(
                                  event.isOnline ? Icons.laptop_chromebook_rounded : Icons.location_on_rounded,
                                  event.locationDisplay,
                                  event.isOnline ? 'Join link provided upon confirmation' : null,
                                ),
                                Divider(height: 20, color: _softBorder),
                                _buildInfoRow(
                                  Icons.business_center_rounded,
                                  'Organized by ${event.organizerDisplay}',
                                  'Verified Foundation Host',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description
                          Text(
                            'About This Event',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 16,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (event.content != null && event.content!.isNotEmpty)
                                ? event.content!
                                : (event.description ?? 'Event information and agenda available at check-in.'),
                            style: AppFontStyle.fontStyleW400(
                              fontSize: 13.5,
                              fontColor: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Ticket Tiers Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Tickets',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 16,
                                  fontColor: _brandDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Open For Booking',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 10,
                                    fontColor: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (event.tickets.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _softBorder),
                              ),
                              child: Center(
                                child: Text(
                                  'Free Admission / General Entry',
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 14,
                                    fontColor: _brandDark,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...event.tickets.map((ticket) {
                              final qty = controller.selectedTickets[ticket.id] ?? 0;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: qty > 0 ? _brandRed : _softBorder,
                                    width: qty > 0 ? 1.5 : 1.0,
                                  ),
                                  boxShadow: qty > 0
                                      ? [
                                          BoxShadow(
                                            color: _brandRed.withValues(alpha: 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ticket.name,
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: 14,
                                              fontColor: _brandDark,
                                            ),
                                          ),
                                          if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              ticket.description!,
                                              style: AppFontStyle.fontStyleW400(
                                                fontSize: 11.5,
                                                fontColor: _slateGrey,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            ticket.remaining > 0
                                                ? '${ticket.remaining} remaining'
                                                : 'Sold out',
                                            style: AppFontStyle.fontStyleW500(
                                              fontSize: 11,
                                              fontColor: ticket.remaining > 0
                                                  ? const Color(0xFF059669)
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Price & Stepper
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$currencySymbol${ticket.price.toStringAsFixed(2)}',
                                          style: AppFontStyle.fontStyleW800(
                                            fontSize: 15,
                                            fontColor: _brandDark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => controller.decrementTicket(ticket),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(Icons.remove, size: 16, color: _brandDark),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Text(
                                                qty.toString(),
                                                style: AppFontStyle.fontStyleW700(
                                                  fontSize: 14,
                                                  fontColor: _brandDark,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: ticket.isSoldOut
                                                  ? null
                                                  : () => controller.incrementTicket(ticket),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: ticket.isSoldOut
                                                      ? const Color(0xFFE2E8F0)
                                                      : _brandRed,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: ticket.isSoldOut ? Colors.grey : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom Booking Bar
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
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total (${controller.totalSelectedTickets} tickets)',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11.5,
                          fontColor: _slateGrey,
                        ),
                      ),
                      Text(
                        '$currencySymbol${controller.grandTotal.toStringAsFixed(2)}',
                        style: AppFontStyle.fontStyleW800(
                          fontSize: 18,
                          fontColor: _brandRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.totalSelectedTickets <= 0 && event.tickets.isNotEmpty) {
                          Utils.showToast(Get.context, 'Please select at least 1 ticket to proceed.');
                          return;
                        }
                        Get.toNamed(
                          AppRoutes.eventBookingScreen,
                          arguments: {
                            'event': event,
                            'selectedTickets': Map<String, int>.from(controller.selectedTickets),
                          },
                        );
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
                        'Book Tickets / Register Now',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13.5,
                          fontColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, [String? subtitle]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _brandRed),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 13,
                  fontColor: _brandDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFontStyle.fontStyleW400(
                    fontSize: 11.5,
                    fontColor: _slateGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

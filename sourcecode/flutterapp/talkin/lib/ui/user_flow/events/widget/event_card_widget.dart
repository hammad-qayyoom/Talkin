import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/events/model/event_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class EventCardWidget extends StatelessWidget {
  final FoundationEvent event;

  const EventCardWidget({
    super.key,
    required this.event,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;

  @override
  Widget build(BuildContext context) {
    final currencySymbol = event.currency == 'CAD' ? 'CA\$' : '\$';

    // Parse date if available
    String monthStr = '';
    String dayStr = '';
    String timeStr = '';
    if (event.startDateTime != null && event.startDateTime!.isNotEmpty) {
      try {
        final dt = DateTime.parse(event.startDateTime!).toLocal();
        monthStr = DateFormat('MMM').format(dt).toUpperCase();
        dayStr = dt.day.toString();
        timeStr = DateFormat('hh:mm a').format(dt);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.eventDetailScreen,
          arguments: event,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            // Cover Image with Date Badge & Online Tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: event.featuredImage != null && event.featuredImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: event.featuredImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const AppImageShimmer(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),

                // Date Badge (Left)
                if (dayStr.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            monthStr,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 9.5,
                              fontColor: _brandRed,
                            ),
                          ),
                          Text(
                            dayStr,
                            style: AppFontStyle.fontStyleW800(
                              fontSize: 14,
                              fontColor: _brandDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Virtual or In-Person Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.isOnline ? 'Virtual' : (event.city?.isNotEmpty == true ? event.city! : 'In-Person'),
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 10,
                        fontColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW800(
                      fontSize: 16,
                      fontColor: _brandDark,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Time & Location
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 13, color: _slateGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          timeStr.isNotEmpty ? '$timeStr · ${event.locationDisplay}' : event.locationDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 11.5,
                            fontColor: _slateGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Organizer & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'By ${event.organizerDisplay}',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11.5,
                          fontColor: _slateGrey,
                        ),
                      ),
                      Text(
                        event.priceFrom > 0 ? 'From $currencySymbol${event.priceFrom.toStringAsFixed(2)}' : 'Free Entry',
                        style: AppFontStyle.fontStyleW800(
                          fontSize: 13.5,
                          fontColor: event.priceFrom > 0 ? _brandRed : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.redesignAccentSoftBg,
      child: Center(
        child: Icon(Icons.confirmation_number_outlined, color: _brandRed.withValues(alpha: 0.35), size: 40),
      ),
    );
  }
}


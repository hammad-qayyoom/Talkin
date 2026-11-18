import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/my_donations_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class MyDonationsScreen extends GetView<MyDonationsController> {
  const MyDonationsScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MyDonationsController>()) {
      Get.put(MyDonationsController());
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
          'My Giving History',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: _brandDark,
          ),
        ),
      ),
      body: Column(
        children: [
          // Transaction / Receipt Search Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _softBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 20, color: _slateGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 13.5,
                        fontColor: _brandDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search receipt #, cause, amount...',
                        hintStyle: AppFontStyle.fontStyleW400(
                          fontSize: 13,
                          fontColor: _slateGrey,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.searchQuery.value.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: controller.clearSearch,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(Icons.cancel_rounded, size: 18, color: _slateGrey),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: _softBorder),

          // Main Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadDonations,
              color: _brandRed,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: _brandRed),
                  );
                }

                // Empty state when user has no giving history at all
                if (controller.allDonations.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                color: _accentSoftBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.volunteer_activism_outlined,
                                size: 44,
                                color: _brandRed,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'No Contributions Yet',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 17,
                                fontColor: _brandDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your verified donations and impact contributions will be listed here automatically.',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 13,
                                fontColor: _slateGrey,
                              ),
                            ),
                            const SizedBox(height: 22),
                            ElevatedButton(
                              onPressed: () => Get.toNamed(AppRoutes.fundraisingHomeScreen),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brandRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Explore Causes'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Filter returned 0 results
                if (controller.filteredDonations.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: _slateGrey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Matching Receipts',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 16,
                                fontColor: _brandDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No records matched "${controller.searchQuery.value}".',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 13,
                                fontColor: _slateGrey,
                              ),
                            ),
                            const SizedBox(height: 18),
                            OutlinedButton(
                              onPressed: controller.clearSearch,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _brandRed,
                                side: BorderSide(color: _brandRed),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Clear Search'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredDonations.length,
                  itemBuilder: (context, index) {
                    final d = controller.filteredDonations[index];
                    final symbol = d.currency == 'CAD'
                        ? 'CA\$'
                        : d.currency == 'USD'
                            ? '\$'
                            : '${d.currency} ';

                    String formattedDate = '';
                    if (d.createdAt != null && d.createdAt!.isNotEmpty) {
                      try {
                        final parsed = DateTime.parse(d.createdAt!);
                        formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(parsed);
                      } catch (_) {
                        formattedDate = d.createdAt!;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _accentSoftBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  d.receiptNumber,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 12,
                                    fontColor: _brandRed,
                                  ),
                                ),
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
                          const SizedBox(height: 10),
                          Text(
                            d.causeTitle ?? 'General Foundation Fund',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 15,
                              fontColor: _brandDark,
                            ),
                          ),
                          if (formattedDate.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 11.5,
                                fontColor: _slateGrey,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$symbol${d.amount.toStringAsFixed(2)}',
                                style: AppFontStyle.fontStyleW800(
                                  fontSize: 16,
                                  fontColor: _brandRed,
                                ),
                              ),
                              Text(
                                'via ${d.paymentMethod}',
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 11.5,
                                  fontColor: _slateGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

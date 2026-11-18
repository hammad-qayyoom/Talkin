import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/ui/user_flow/marketplace/api/marketplace_api.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final List<MarketplaceOrder> _orders = [];
  bool _isLoading = true;

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final email = Database.fetchLoginUserProfileModel?.user?.email ?? '';
    if (email.isNotEmpty) {
      final res = await MarketplaceApi.fetchUserOrders(email);
      setState(() {
        _orders.clear();
        _orders.addAll(res);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return AppColors.green;
      case 'SHIPPED':
      case 'IN_TRANSIT':
        return Colors.purple;
      case 'PROCESSING':
        return Colors.blue;
      case 'CANCELLED':
      case 'REFUNDED':
        return _brandRed;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 760;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _brandDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Marketplace Orders',
          style: AppFontStyle.fontStyleW700(
            fontSize: 18,
            fontColor: _brandDark,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: _brandRed,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _brandRed))
            : _orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: AppColors.redesignAccentSoftBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 44,
                              color: _brandRed,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Orders Yet',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 18,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your completed marketplace purchases will appear here.',
                            textAlign: TextAlign.center,
                            style: AppFontStyle.fontStyleW400(
                              fontSize: 13,
                              fontColor: AppColors.redesignSlateGrey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandRed,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Explore Marketplace',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 14,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 24),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final statusColor = _getStatusColor(order.status);
                      final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt);

                      return Container(
                        padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Order Number & Status Pill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    order.orderNumber,
                                    style: AppFontStyle.fontStyleW700(
                                      fontSize: 14,
                                      fontColor: _brandDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: AppFontStyle.fontStyleW700(
                                      fontSize: 10.5,
                                      fontColor: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Date
                            Text(
                              dateStr,
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 11.5,
                                fontColor: AppColors.redesignSlateGrey,
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1),
                            ),

                            // Items List
                            ...order.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    if (item.productFeaturedImage != null &&
                                        item.productFeaturedImage!.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: item.productFeaturedImage!,
                                          height: 38,
                                          width: 38,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const AppImageShimmer(
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                          ),
                                          errorWidget: (_, __, ___) => Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.redesignSlateGrey),
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 38,
                                        width: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.redesignNeutralGrey,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.redesignSlateGrey),
                                      ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.fontStyleW600(
                                              fontSize: 12.5,
                                              fontColor: _brandDark,
                                            ),
                                          ),
                                          Text(
                                            'Qty: ${item.quantity} × CA\$${item.unitPrice.toStringAsFixed(2)}',
                                            style: AppFontStyle.fontStyleW400(
                                              fontSize: 11,
                                              fontColor: AppColors.redesignSlateGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'CA\$${item.total.toStringAsFixed(2)}',
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 12.5,
                                        fontColor: _brandDark,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Sub-Orders / Tracking if available
                            if (order.vendorOrders.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              ...order.vendorOrders.map((vo) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _softBorder),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${vo.subOrderNumber} (${vo.storeName ?? "Vendor"})',
                                        style: AppFontStyle.fontStyleW500(
                                          fontSize: 11,
                                          fontColor: _brandDark,
                                        ),
                                      ),
                                      Text(
                                        vo.status.toUpperCase(),
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: 10,
                                          fontColor: _getStatusColor(vo.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1),
                            ),

                            // Total & Payment Method Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment: ${order.paymentMethod}',
                                  style: AppFontStyle.fontStyleW500(
                                    fontSize: 11.5,
                                    fontColor: AppColors.redesignSlateGrey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Total: ',
                                      style: AppFontStyle.fontStyleW500(
                                        fontSize: 12.5,
                                        fontColor: AppColors.redesignSlateGrey,
                                      ),
                                    ),
                                    Text(
                                      'CA\$${order.totalAmount.toStringAsFixed(2)}',
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 15,
                                        fontColor: _brandRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

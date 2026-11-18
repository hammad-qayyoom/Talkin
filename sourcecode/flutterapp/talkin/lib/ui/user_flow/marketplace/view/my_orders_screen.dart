import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/marketplace/api/marketplace_api.dart';
import 'package:notisboard/ui/user_flow/marketplace/model/marketplace_model.dart';
import 'package:notisboard/ui/user_flow/marketplace/shimmer/marketplace_shimmer.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final List<MarketplaceOrder> _allOrders = [];
  final List<MarketplaceOrder> _filteredOrders = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final email = Database.resolvedUserEmail;
    if (email.isNotEmpty) {
      final res = await MarketplaceApi.fetchUserOrders(email);
      _allOrders.clear();
      _allOrders.addAll(res);
      _applySearchFilter();
      setState(() => _isLoading = false);
    } else {
      _allOrders.clear();
      _filteredOrders.clear();
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applySearchFilter();
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _applySearchFilter();
    setState(() {});
  }

  void _applySearchFilter() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredOrders.clear();
      _filteredOrders.addAll(_allOrders);
      return;
    }

    final filtered = _allOrders.where((order) {
      final orderNum = order.orderNumber.toLowerCase();
      final status = order.status.toLowerCase();
      final method = order.paymentMethod.toLowerCase();
      final total = order.totalAmount.toString();
      final totalFormatted = order.totalAmount.toStringAsFixed(2);
      final hasMatchingItem = order.items.any((it) =>
          it.productTitle.toLowerCase().contains(query) ||
          (it.vendorName ?? '').toLowerCase().contains(query));

      return orderNum.contains(query) ||
          status.contains(query) ||
          method.contains(query) ||
          total.contains(query) ||
          totalFormatted.contains(query) ||
          hasMatchingItem;
    }).toList();

    _filteredOrders.clear();
    _filteredOrders.addAll(filtered);
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
      body: Column(
        children: [
          // Order Search Header
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
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 13.5,
                        fontColor: _brandDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search orders by #, product, or status...',
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
                  if (_searchQuery.trim().isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(Icons.cancel_rounded, size: 18, color: _slateGrey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: _softBorder),

          // Main Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchOrders,
              color: _brandRed,
              child: _isLoading
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: OrdersHistoryShimmer(horizontalPadding: horizontalPadding),
                    )
                  : _allOrders.isEmpty
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
                                  'Your completed marketplace purchases will appear here automatically.',
                                  textAlign: TextAlign.center,
                                  style: AppFontStyle.fontStyleW400(
                                    fontSize: 13,
                                    fontColor: _slateGrey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    if (Get.previousRoute.isNotEmpty) {
                                      Get.back();
                                    } else {
                                      Get.toNamed(AppRoutes.marketplaceHomeScreen);
                                    }
                                  },
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
                      : _filteredOrders.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF1F5F9),
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
                                      'No Matching Orders',
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 16,
                                        fontColor: _brandDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'No purchases matched "$_searchQuery".',
                                      textAlign: TextAlign.center,
                                      style: AppFontStyle.fontStyleW400(
                                        fontSize: 13,
                                        fontColor: _slateGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    OutlinedButton(
                                      onPressed: _clearSearch,
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
                            )
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 24),
                              itemCount: _filteredOrders.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
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
                                          fontColor: _slateGrey,
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
                                                    errorWidget: (_, __, ___) => Icon(
                                                      Icons.shopping_bag_outlined,
                                                      size: 20,
                                                      color: _slateGrey,
                                                    ),
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
                                                  child: Icon(
                                                    Icons.shopping_bag_outlined,
                                                    size: 20,
                                                    color: _slateGrey,
                                                  ),
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
                                                        fontColor: _slateGrey,
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
                                              fontColor: _slateGrey,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Total: ',
                                                style: AppFontStyle.fontStyleW500(
                                                  fontSize: 12.5,
                                                  fontColor: _slateGrey,
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
          ),
        ],
      ),
    );
  }
}

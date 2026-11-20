import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/controller/food_assistance_controller.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/model/food_assistance_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FoodCatalogScreen extends GetView<FoodAssistanceController> {
  const FoodCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FoodAssistanceController>()) {
      Get.put(FoodAssistanceController());
    }

    final categories = [
      {'key': 'ALL', 'label': 'All Items'},
      {'key': 'FRUITS', 'label': 'Fruits'},
      {'key': 'VEGETABLES', 'label': 'Veggies'},
      {'key': 'GRAINS', 'label': 'Grains & Rice'},
      {'key': 'DAIRY', 'label': 'Dairy & Cheese'},
      {'key': 'MEAT', 'label': 'Halal Meat'},
      {'key': 'CANNED_FOOD', 'label': 'Canned Goods'},
      {'key': 'HOUSEHOLD_ESSENTIALS', 'label': 'Hygiene'},
      {'key': 'BEVERAGES', 'label': 'Juices & Tea'},
    ];

    final dietaryTags = ['ALL', 'Halal', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Kosher'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Food Parcel Catalogue',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingProducts.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE11D48)));
        }

        final filtered = controller.filteredProducts;

        return Column(
          children: [
            // Top Sticky Filter & Limit Area
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // Search Bar & Dietary Dropdown
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            onChanged: (val) => controller.searchQuery.value = val,
                            style: AppFontStyle.fontStyleW500(fontSize: 12.5, fontColor: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              hintText: 'Search food items, tags...',
                              hintStyle: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dietary Filter Dropdown
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedDietary.value,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B), size: 18),
                            items: dietaryTags.map((d) {
                              return DropdownMenuItem<String>(
                                value: d,
                                child: Text(
                                  d == 'ALL' ? 'All Diets' : d,
                                  style: AppFontStyle.fontStyleW600(fontSize: 11.5, fontColor: const Color(0xFF334155)),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) controller.selectedDietary.value = val;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Category Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = controller.selectedCategory.value == cat['key'];
                        return GestureDetector(
                          onTap: () => controller.selectedCategory.value = cat['key']!,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cat['label']!,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 11,
                                fontColor: isSelected ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lunch_dining_outlined, size: 50, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 10),
                          Text(
                            'No food items match your filter',
                            style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        return _buildProductCard(context, filtered[i]);
                      },
                    ),
            ),

            // Bottom Sticky Parcel Bar
            _buildBottomParcelBar(context),
          ],
        );
      }),
    );
  }

  Widget _buildProductCard(BuildContext context, FoodBankProduct p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFF1F5F9),
              child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                  ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood_rounded, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.packageSize,
                          style: AppFontStyle.fontStyleW600(fontSize: 9.5, fontColor: const Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'FREE \$0.00',
                      style: AppFontStyle.fontStyleW800(fontSize: 11, fontColor: const Color(0xFFE11D48)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  p.name,
                  style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                  maxLines: 2,
                  softWrap: true,
                ),
                if (p.description != null && p.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    p.description!,
                    style: AppFontStyle.fontStyleW400(fontSize: 10.5, fontColor: const Color(0xFF64748B)),
                    maxLines: 2,
                    softWrap: true,
                  ),
                ],
                const SizedBox(height: 6),
                // Dietary Tags
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: p.dietaryTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action button / Counter
          Obx(() {
            final qty = controller.getProductQuantity(p.id);

            if (qty > 0) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFFE11D48)),
                      onPressed: () => controller.addToParcel(p, context),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      '$qty',
                      style: AppFontStyle.fontStyleW800(fontSize: 12, fontColor: const Color(0xFFE11D48)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16, color: Color(0xFFE11D48)),
                      onPressed: () => controller.removeFromParcel(p.id),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }

            return Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: p.isAvailable ? () => controller.addToParcel(p, context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: const Size(60, 32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  p.isAvailable ? '+ Add' : 'Out',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 11,
                    fontColor: p.isAvailable ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomParcelBar(BuildContext context) {
    return Obx(() {
      final distinctCount = controller.distinctParcelTypesCount;
      final maxLimit = controller.maxItemsLimit;
      final totalQty = controller.totalParcelItemsCount;

      if (totalQty == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Parcel: ',
                          style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF64748B)),
                        ),
                        Text(
                          '$distinctCount / $maxLimit types',
                          style: AppFontStyle.fontStyleW800(
                            fontSize: 12,
                            fontColor: distinctCount == maxLimit ? const Color(0xFFD97706) : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total: \$0.00 FREE',
                      style: AppFontStyle.fontStyleW800(fontSize: 15, fontColor: const Color(0xFFE11D48)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => controller.handleProceedToCheckout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Free Checkout ($totalQty)',
                      style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

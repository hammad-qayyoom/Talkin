import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/controller/food_assistance_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FoodCheckoutScreen extends GetView<FoodAssistanceController> {
  const FoodCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FoodAssistanceController>()) {
      Get.put(FoodAssistanceController());
    }

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
          'Confirm Assistance Request',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Obx(() {
        final parcelEntries = controller.parcel.entries.toList();

        if (parcelEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_basket_outlined, size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                Text(
                  'Your food parcel is empty',
                  style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: const Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Return to Food Catalogue', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Free Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Free Food Assistance (\$0.00)',
                            style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF065F46)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Subsidized through Notisboard Global Foundation relief allocations. Zero payment required.',
                            style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Parcel Contents Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Food Parcel Items',
                      style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),

                    ...parcelEntries.map((entry) {
                      final prod = controller.products.firstWhereOrNull((p) => p.id == entry.key);
                      if (prod == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prod.name,
                                    style: AppFontStyle.fontStyleW600(fontSize: 12.5, fontColor: const Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    prod.packageSize,
                                    style: AppFontStyle.fontStyleW400(fontSize: 10.5, fontColor: const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${entry.value}x',
                              style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFFE11D48)),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 20, color: Color(0xFFE2E8F0)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Payable', style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                        Text('FREE \$0.00', style: AppFontStyle.fontStyleW800(fontSize: 16, fontColor: const Color(0xFF10B981))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Recipient Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipient Information',
                      style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      label: 'Recipient Full Name *',
                      hint: 'e.g. John Doe',
                      controller: controller.checkoutNameController,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      label: 'Registered Beneficiary Email *',
                      hint: 'e.g. john@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.checkoutEmailController,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      label: 'Contact Phone Number *',
                      hint: 'e.g. +1 (416) 555-0123',
                      keyboardType: TextInputType.phone,
                      controller: controller.checkoutPhoneController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Fulfillment Method Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fulfillment Option',
                      style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.checkoutDeliveryType.value = 'HOME_DELIVERY',
                            child: Obx(() {
                              final isSelected = controller.checkoutDeliveryType.value == 'HOME_DELIVERY';
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.local_shipping_rounded, color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF64748B)),
                                    const SizedBox(height: 4),
                                    Text('Home Delivery', style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: const Color(0xFF0F172A))),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.checkoutDeliveryType.value = 'PICKUP_POINT',
                            child: Obx(() {
                              final isSelected = controller.checkoutDeliveryType.value == 'PICKUP_POINT';
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.store_mall_directory_rounded, color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF64748B)),
                                    const SizedBox(height: 4),
                                    Text('Depot Pickup', style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: const Color(0xFF0F172A))),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Delivery Details or Pickup selection
                    Obx(() {
                      final currentCity = controller.selectedCity.value;
                      if (controller.checkoutDeliveryType.value == 'HOME_DELIVERY') {
                        final zones = currentCity?.zones ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Delivery Zone *', style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155))),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.checkoutZoneId.value.isNotEmpty && zones.any((z) => z.id == controller.checkoutZoneId.value)
                                      ? controller.checkoutZoneId.value
                                      : (zones.isNotEmpty ? zones.first.id : null),
                                  isExpanded: true,
                                  items: zones.map((z) {
                                    return DropdownMenuItem<String>(
                                      value: z.id,
                                      child: Text(z.name, style: AppFontStyle.fontStyleW500(fontSize: 12.5, fontColor: const Color(0xFF0F172A))),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) controller.checkoutZoneId.value = val;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildTextField(
                              label: 'Street Address *',
                              hint: 'e.g. 145 Queen St W',
                              controller: controller.checkoutStreetController,
                            ),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Apt / Unit #',
                                    hint: 'e.g. Apt 4B',
                                    controller: controller.checkoutUnitController,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField(
                                    label: 'Postal Code *',
                                    hint: 'e.g. M5V 1Z4',
                                    controller: controller.checkoutPostalController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            _buildTextField(
                              label: 'Delivery Notes / Buzzer Code',
                              hint: 'e.g. Buzzer #301, leave on porch...',
                              controller: controller.checkoutNotesController,
                            ),
                          ],
                        );
                      } else {
                        final depots = currentCity?.pickupLocations ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Select Walk-In Depot *', style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155))),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.checkoutPickupLocationId.value.isNotEmpty &&
                                          depots.any((d) => d.id == controller.checkoutPickupLocationId.value)
                                      ? controller.checkoutPickupLocationId.value
                                      : (depots.isNotEmpty ? depots.first.id : null),
                                  isExpanded: true,
                                  items: depots.map((d) {
                                    return DropdownMenuItem<String>(
                                      value: d.id,
                                      child: Text(
                                        '${d.name} (${d.address})',
                                        style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: const Color(0xFF0F172A)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) controller.checkoutPickupLocationId.value = val;
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Obx(() {
                final isSubmitting = controller.isSubmittingCheckout.value;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final res = await controller.submitFreeOrderCheckout();
                            if (res['success'] == true) {
                              if (context.mounted) {
                                _showOrderSuccessDialog(context, res['data']);
                              }
                            } else {
                              Get.snackbar(
                                'Order Request Failed',
                                res['error']?.toString() ?? 'Failed to place request',
                                backgroundColor: const Color(0xFFEF4444),
                                colorText: Colors.white,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Confirm & Place Free Order (\$0.00) →',
                            style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: Colors.white),
                          ),
                  ),
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppFontStyle.fontStyleW500(fontSize: 12.5, fontColor: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
          ),
        ),
      ],
    );
  }

  void _showOrderSuccessDialog(BuildContext context, dynamic orderData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Food Parcel Confirmed!',
                style: AppFontStyle.fontStyleW800(fontSize: 18, fontColor: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                'Your food assistance parcel request has been placed with the Toronto relief team.',
                style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Order #${orderData?['orderNumber'] ?? 'FBO-CONFIRMED'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE11D48)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.offNamed(AppRoutes.foodAssistanceRequestsScreen);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Track Parcel Status →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}

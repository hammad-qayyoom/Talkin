import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/checkout_controller.dart';
import 'package:notisboard/ui/user_flow/marketplace/controller/marketplace_cart_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());
    final cart = Get.find<MarketplaceCartController>();

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
          'Checkout & Payment',
          style: AppFontStyle.fontStyleW700(
            fontSize: 18,
            fontColor: _brandDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Customer Contact Information
            _buildSectionCard(
              title: 'Customer Information',
              icon: Icons.person_outline_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: controller.firstNameController,
                        label: 'First Name *',
                        hint: 'e.g. Hammad',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: controller.lastNameController,
                        label: 'Last Name *',
                        hint: 'e.g. Qayyoom',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.emailController,
                  label: 'Delivery Email *',
                  hint: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.phoneController,
                  label: 'Phone Number',
                  hint: '+1 (555) 000-0000',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Shipping Address
            _buildSectionCard(
              title: 'Shipping Address',
              icon: Icons.location_on_outlined,
              children: [
                _buildTextField(
                  controller: controller.streetController,
                  label: 'Street Address *',
                  hint: '123 Main Street',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.apartmentController,
                  label: 'Apartment, Suite, Unit (optional)',
                  hint: 'Apt 4B',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: controller.cityController,
                        label: 'City *',
                        hint: 'e.g. Toronto',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: controller.stateController,
                        label: 'State / Province',
                        hint: 'ON',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: controller.postalCodeController,
                        label: 'Postal / Zip Code',
                        hint: 'M5V 2T6',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: controller.countryController,
                        label: 'Country *',
                        hint: 'Canada',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: controller.notesController,
                  label: 'Delivery Instructions / Notes (optional)',
                  hint: 'Leave at front door or buzzer code',
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Select Payment Gateway
            _buildSectionCard(
              title: 'Payment Gateway',
              icon: Icons.payment_rounded,
              subtitle: 'Active methods configured by admin',
              children: [
                Obx(() {
                  final methods = controller.paymentMethods;
                  if (methods.isEmpty) {
                    return Text(
                      'No payment gateways available.',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 13,
                        fontColor: AppColors.red,
                      ),
                    );
                  }

                  return Column(
                    children: methods.map((m) {
                      final isSelected = controller.selectedPaymentMethod.value == m.key;
                      return GestureDetector(
                        onTap: () => controller.selectedPaymentMethod.value = m.key,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? _brandRed.withValues(alpha: 0.05) : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? _brandRed : _softBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                margin: const EdgeInsets.only(left: 6, right: 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? _brandRed : _softBorder,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _brandRed,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.redesignAccentSoftBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(m.icon, color: _brandRed, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.title,
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 13.5,
                                        fontColor: _brandDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      m.subtitle,
                                      style: AppFontStyle.fontStyleW400(
                                        fontSize: 11.5,
                                        fontColor: AppColors.redesignSlateGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Order Review & Financial Summary
            _buildSectionCard(
              title: 'Order Review',
              icon: Icons.receipt_long_rounded,
              children: [
                ...cart.cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 12.5,
                              fontColor: _brandDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'CA\$${item.totalPrice.toStringAsFixed(2)}',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 12.5,
                            fontColor: _brandDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                _buildSummaryLine('Subtotal', 'CA\$${cart.subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 6),
                _buildSummaryLine(
                  'Shipping',
                  cart.shippingFee == 0 ? 'FREE' : 'CA\$${cart.shippingFee.toStringAsFixed(2)}',
                  valueColor: cart.shippingFee == 0 ? AppColors.green : null,
                ),
                const SizedBox(height: 6),
                _buildSummaryLine('Taxes & Fees (5%)', 'CA\$${cart.taxAmount.toStringAsFixed(2)}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total to Pay',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: _brandDark,
                      ),
                    ),
                    Text(
                      'CA\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 18,
                        fontColor: _brandRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () => controller.submitOrder(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandRed,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Text(
                    'Place Order & Pay CA\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 14.5,
                      fontColor: AppColors.white,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.redesignAccentSoftBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: _brandRed),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 15,
                  fontColor: _brandDark,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppFontStyle.fontStyleW400(
                fontSize: 11.5,
                fontColor: AppColors.redesignSlateGrey,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: _brandDark,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppFontStyle.fontStyleW500(
            fontSize: 13,
            fontColor: _brandDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFontStyle.fontStyleW400(
              fontSize: 12.5,
              fontColor: AppColors.redesignSlateGrey,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, String val, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFontStyle.fontStyleW500(
            fontSize: 12.5,
            fontColor: AppColors.redesignSlateGrey,
          ),
        ),
        Text(
          val,
          style: AppFontStyle.fontStyleW700(
            fontSize: 12.5,
            fontColor: valueColor ?? _brandDark,
          ),
        ),
      ],
    );
  }
}

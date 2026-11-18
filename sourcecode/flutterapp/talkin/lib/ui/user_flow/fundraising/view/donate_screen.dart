// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/donation_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class DonateScreen extends GetView<DonationController> {
  const DonateScreen({super.key});

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
          'Make a Donation',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: _brandDark,
          ),
        ),
      ),
      body: Obx(() {
        final currentAmount = controller.selectedAmount.value;
        final currency = controller.selectedCampaign.value?.currency ?? 'CAD';
        final symbol = currency == 'CAD' ? 'CA\$' : '\$';

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cause Summary Card
                    _buildCauseCard(),
                    const SizedBox(height: 16),

                    // Frequency Selector
                    _buildFrequencySelector(),
                    const SizedBox(height: 18),

                    // Amount Selector
                    Text(
                      'Select Donation Amount',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: _brandDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildAmountGrid(symbol),
                    const SizedBox(height: 12),

                    // Custom Amount Field
                    TextField(
                      controller: controller.customAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: controller.setCustomAmount,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 14,
                        fontColor: _brandDark,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Text(
                            symbol,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 15,
                              fontColor: _brandDark,
                            ),
                          ),
                        ),
                        hintText: 'Or enter custom amount',
                        hintStyle: AppFontStyle.fontStyleW400(
                          fontSize: 13.5,
                          fontColor: _slateGrey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _softBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: controller.isCustomAmount.value
                                ? _brandRed
                                : _softBorder,
                            width: controller.isCustomAmount.value ? 1.5 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _brandRed, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Anonymous Giving Toggle
                    GestureDetector(
                      onTap: () => controller.isAnonymous.toggle(),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Checkbox(
                            value: controller.isAnonymous.value,
                            onChanged: (v) => controller.isAnonymous.value = v ?? false,
                            activeColor: _brandRed,
                          ),
                          Expanded(
                            child: Text(
                              'Make this donation anonymous on public boards',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 13,
                                fontColor: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Donor Information
                    Text(
                      'Donor Information',
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
                      label: 'Phone (Optional)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: controller.messageController,
                      label: 'Encouragement Message (Optional)',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Payment Gateways (Strict App Admin Filter)
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

                    if (controller.availableGateways.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          'Loading configured payment providers...',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 12.5,
                            fontColor: const Color(0xFF92400E),
                          ),
                        ),
                      )
                    else
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
                  onPressed: controller.isSubmitting.value ? null : controller.submitDonation,
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
                          'Complete Donation of $symbol${currentAmount.toStringAsFixed(2)}',
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

  Widget _buildCauseCard() {
    String title = 'General Foundation Fund';
    String subtitle = '100% direct allocation to verified urgent missions';
    IconData icon = Icons.favorite_rounded;

    if (controller.donationType.value == 'CAMPAIGN' && controller.selectedCampaign.value != null) {
      final c = controller.selectedCampaign.value!;
      title = c.title;
      subtitle = 'Verified Community Campaign';
      icon = Icons.volunteer_activism_rounded;
    } else if (controller.donationType.value == 'PROGRAM' && controller.selectedProgram.value != null) {
      final p = controller.selectedProgram.value!;
      title = p.title;
      subtitle = 'Foundation Flagship Program';
      icon = Icons.public_rounded;
    }

    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentSoftBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _brandRed, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle.toUpperCase(),
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 10,
                    fontColor: _brandRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: _brandDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.frequency.value = 'one-time',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: controller.frequency.value == 'one-time' ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: controller.frequency.value == 'one-time'
                      ? [
                          BoxShadow(
                            color: _brandRed.withValues(alpha: 0.12),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'One-Time Giving',
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 12.5,
                      fontColor: controller.frequency.value == 'one-time'
                          ? _brandRed
                          : _slateGrey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.frequency.value = 'monthly',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: controller.frequency.value == 'monthly' ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: controller.frequency.value == 'monthly'
                      ? [
                          BoxShadow(
                            color: _brandRed.withValues(alpha: 0.12),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync_rounded, size: 14, color: controller.frequency.value == 'monthly' ? _brandRed : _slateGrey),
                      const SizedBox(width: 4),
                      Text(
                        'Monthly Sustainer',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 12.5,
                          fontColor: controller.frequency.value == 'monthly'
                              ? _brandRed
                              : _slateGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountGrid(String symbol) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: controller.presetAmounts.map((amt) {
        final isSelected = !controller.isCustomAmount.value && controller.selectedAmount.value == amt;
        return GestureDetector(
          onTap: () => controller.setAmount(amt),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _brandRed : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? _brandRed : _softBorder,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _brandRed.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$symbol${amt.toInt()}',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: isSelected ? Colors.white : _brandDark,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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

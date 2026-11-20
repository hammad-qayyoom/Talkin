import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/controller/food_assistance_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class BeneficiaryApplyScreen extends GetView<FoodAssistanceController> {
  const BeneficiaryApplyScreen({super.key});

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
          'Apply for Food Assistance',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Equitable & Dignified Community Relief',
                          style: AppFontStyle.fontStyleW700(fontSize: 12.5, fontColor: const Color(0xFF9F1239)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Beneficiary registration ensures food packages reach vulnerable families fairly. Once verified, you can order regular relief packages at \$0.00 cost.',
                          style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFFBE123C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form container
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('1. Contact & Identity Information'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Full Legal Name *',
                    hint: 'e.g. John Doe',
                    controller: controller.applyNameController,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Email Address *',
                    hint: 'e.g. john@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: controller.applyEmailController,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Phone Number *',
                    hint: 'e.g. +1 (416) 555-0123',
                    keyboardType: TextInputType.phone,
                    controller: controller.applyPhoneController,
                  ),

                  const SizedBox(height: 20),
                  Obx(() {
                    final currentCity = controller.selectedCity.value;
                    final cityName = currentCity?.name ?? 'Service Area';
                    return _buildSectionHeader('2. Residential Address in $cityName');
                  }),
                  const SizedBox(height: 12),

                  // Zone dropdown
                  Obx(() {
                    final currentCity = controller.selectedCity.value;
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
                              value: controller.applyZoneId.value.isNotEmpty && zones.any((z) => z.id == controller.applyZoneId.value)
                                  ? controller.applyZoneId.value
                                  : (zones.isNotEmpty ? zones.first.id : null),
                              isExpanded: true,
                              items: zones.map((z) {
                                return DropdownMenuItem<String>(
                                  value: z.id,
                                  child: Text(
                                    z.name,
                                    style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) controller.applyZoneId.value = val;
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Street Address *',
                    hint: 'e.g. 145 Queen St W',
                    controller: controller.applyStreetController,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Apt / Unit #',
                          hint: 'e.g. Apt 4B',
                          controller: controller.applyUnitController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Postal Code *',
                          hint: 'e.g. M5V 1Z4',
                          controller: controller.applyPostalController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader('3. Household Composition'),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCounter(
                        label: 'Adults (18-64)',
                        value: controller.applyAdults,
                        min: 1,
                      ),
                      _buildCounter(
                        label: 'Children (0-17)',
                        value: controller.applyChildren,
                        min: 0,
                      ),
                      _buildCounter(
                        label: 'Seniors (65+)',
                        value: controller.applySeniors,
                        min: 0,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader('4. Identity Document & KYC Type'),
                  const SizedBox(height: 12),

                  Obx(() {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.applyIdType.value,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'GOVERNMENT_PHOTO_ID', child: Text('Ontario Photo ID / Driver\'s License')),
                            DropdownMenuItem(value: 'PASSPORT', child: Text('Canadian / International Passport')),
                            DropdownMenuItem(value: 'UTILITY_BILL', child: Text('Utility Bill / Proof of Address')),
                            DropdownMenuItem(value: 'STUDENT_CARD', child: Text('University / College Student Card')),
                            DropdownMenuItem(value: 'OTHER', child: Text('Other Official Document')),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.applyIdType.value = val;
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Text(
                    '🔒 Privacy Protection: KYC documents are encrypted and reviewed solely by certified food bank coordinators. Delivery drivers cannot access your identification.',
                    style: AppFontStyle.fontStyleW400(fontSize: 10.5, fontColor: const Color(0xFF94A3B8)),
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader('5. Dietary Needs & Special Notes'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Special Dietary Notes (Optional)',
                    hint: 'e.g. 100% Halal, Peanut Allergy, Diabetic-friendly, Gluten-free...',
                    controller: controller.applyNotesController,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 26),

                  // Submit Button
                  Obx(() {
                    final isSubmitting = controller.isSubmittingApply.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final ok = await controller.submitBeneficiaryApplication();
                                if (ok) {
                                  Get.toNamed(AppRoutes.foodAssistanceRequestsScreen);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
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
                                'Submit Application for Review →',
                                style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: Colors.white),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppFontStyle.fontStyleW700(
        fontSize: 13,
        fontColor: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFontStyle.fontStyleW400(fontSize: 12.5, fontColor: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter({required String label, required RxInt value, required int min}) {
    return Obx(() {
      return Column(
        children: [
          Text(label, style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF475569))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: value.value > min ? () => value.value-- : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${value.value}',
                    style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: value.value < 15 ? () => value.value++ : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

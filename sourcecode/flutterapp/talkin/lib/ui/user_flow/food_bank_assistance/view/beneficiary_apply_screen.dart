import 'dart:io';
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
            // Notice banner (Blue / Slate Foundation Theme)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Equitable & Dignified Community Relief',
                          style: AppFontStyle.fontStyleW700(fontSize: 12.5, fontColor: const Color(0xFF1E3A8A)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Beneficiary registration ensures food packages reach vulnerable families fairly. Once verified, you can order regular relief packages at \$0.00 cost.',
                          style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF1D4ED8)),
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

                  // Responsive Household Composition Counters
                  Row(
                    children: [
                      Expanded(
                        child: _buildCounter(
                          label: 'Adults (18-64)',
                          value: controller.applyAdults,
                          min: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCounter(
                          label: 'Children (0-17)',
                          value: controller.applyChildren,
                          min: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCounter(
                          label: 'Seniors (65+)',
                          value: controller.applySeniors,
                          min: 0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildSectionHeader('4. Identity Document & KYC Type'),
                  const SizedBox(height: 12),

                  // Identity Document Type Dropdown (Theme Matched - No Pink)
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
                          dropdownColor: Colors.white,
                          focusColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
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
                  const SizedBox(height: 12),

                  // Identity Document Photo / File Upload Box
                  Obx(() {
                    final docPath = controller.applyIdDocumentPath.value;
                    final isUploading = controller.isUploadingDocument.value;

                    if (isUploading) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 2.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Uploading identity document to secure vault...',
                              style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF1E40AF)),
                            ),
                          ],
                        ),
                      );
                    }

                    if (docPath.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(docPath),
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 52,
                                  height: 52,
                                  color: const Color(0xFFE2E8F0),
                                  child: const Icon(Icons.description_rounded, color: Color(0xFF64748B)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Document Attached',
                                        style: AppFontStyle.fontStyleW700(fontSize: 12.5, fontColor: const Color(0xFF15803D)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    docPath.split('/').last,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF475569)),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: controller.pickIdDocument,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Change',
                                style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: const Color(0xFF2563EB)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                              onPressed: controller.removeIdDocument,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }

                    return InkWell(
                      onTap: controller.pickIdDocument,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.upload_file_rounded, color: Color(0xFF2563EB), size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Upload Identity Document / Photo *',
                              style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to browse gallery or capture photo of your ID (JPEG, PNG, max 15MB)',
                              textAlign: TextAlign.center,
                              style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                'Choose File',
                                style: AppFontStyle.fontStyleW700(fontSize: 11, fontColor: const Color(0xFF2563EB)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Privacy Protection: KYC documents are encrypted and reviewed solely by certified food bank coordinators. Delivery drivers cannot access your identification.',
                          style: AppFontStyle.fontStyleW400(fontSize: 10.5, fontColor: const Color(0xFF64748B)),
                        ),
                      ),
                    ],
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

                  // Submit Button (Matching Foundation Royal Blue Theme)
                  Obx(() {
                    final isSubmitting = controller.isSubmittingApply.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
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
                          backgroundColor: const Color(0xFF2563EB),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter({required String label, required RxInt value, required int min}) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: const Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: value.value > min ? () => value.value-- : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  color: const Color(0xFF2563EB),
                ),
                Text(
                  '${value.value}',
                  style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: value.value < 15 ? () => value.value++ : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

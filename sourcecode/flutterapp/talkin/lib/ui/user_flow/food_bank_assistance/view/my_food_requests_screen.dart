import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/api/food_assistance_api.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/controller/food_assistance_controller.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/model/food_assistance_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class MyFoodRequestsScreen extends GetView<FoodAssistanceController> {
  const MyFoodRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FoodAssistanceController>()) {
      Get.put(FoodAssistanceController());
    }

    final profileEmail = controller.beneficiaryProfile.value?.email;
    final checkoutEmail = controller.checkoutEmailController.text.trim();
    final defaultEmail = (profileEmail != null && profileEmail.isNotEmpty)
        ? profileEmail
        : (checkoutEmail.isNotEmpty ? checkoutEmail : (Database.fetchLoginUserProfileModel?.user?.email ?? ''));

    final searchEmailController = TextEditingController(text: defaultEmail);

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
          'My Assistance Requests',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Obx(() {
        final profile = controller.beneficiaryProfile.value;
        final orders = controller.myRequests;
        final isLoading = controller.isLoadingRequests.value;

        return RefreshIndicator(
          color: const Color(0xFFE11D48),
          onRefresh: () async {
            if (searchEmailController.text.trim().isNotEmpty) {
              await controller.loadMyRequests(searchEmailController.text.trim());
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Search Bar for instant lookup
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            hintText: 'Enter registered email...',
                            hintStyle: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => controller.loadMyRequests(searchEmailController.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Search', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (isLoading) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFFE11D48))),
                  ),
                ] else ...[
                  // Beneficiary Profile Card
                  if (profile != null) ...[
                    _buildBeneficiaryCard(context, profile),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Not registered callout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFFE11D48), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'No Beneficiary Profile Registered',
                                style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'To receive ongoing free food assistance, submit a household registration for Toronto community relief.',
                            style: AppFontStyle.fontStyleW400(fontSize: 11.5, fontColor: const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => Get.toNamed(AppRoutes.foodAssistanceApplyScreen),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 36),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Register Household Now →', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Orders Ledger
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assistance Requests Ledger',
                        style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: const Color(0xFF0F172A)),
                      ),
                      Text(
                        '${orders.length} Records',
                        style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (orders.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          Text(
                            'No Assistance Requests Found',
                            style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your completed and active food parcel orders will appear here.',
                            style: AppFontStyle.fontStyleW400(fontSize: 11.5, fontColor: const Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Get.toNamed(AppRoutes.foodAssistanceCatalogScreen),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Browse Food Catalogue →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...orders.map((ord) => _buildOrderCard(context, ord)),
                  ],
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBeneficiaryCard(BuildContext context, BeneficiaryProfile profile) {
    final isApproved = profile.status == 'APPROVED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Household Beneficiary Profile',
                style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isApproved ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  profile.status,
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 10.5,
                    fontColor: isApproved ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(profile.fullName, style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
          Text('Email: ${profile.email} • Phone: ${profile.phone}', style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B))),
          Text('Address: ${profile.streetAddress}, ${profile.postalCode}', style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B))),
          Text('Household: ${profile.totalHouseholdMembers} Members (${profile.householdAdults} adults, ${profile.householdChildren} children, ${profile.householdSeniors} seniors)', style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF334155))),

          if (isApproved) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.foodAssistanceCatalogScreen),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                elevation: 0,
                minimumSize: const Size(double.infinity, 38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('+ Request New Food Parcel →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, FoodBankOrderRecord ord) {
    Color statusBg = const Color(0xFFFFFBEB);
    Color statusColor = const Color(0xFFD97706);

    if (ord.status == 'DELIVERED') {
      statusBg = const Color(0xFFECFDF5);
      statusColor = const Color(0xFF059669);
    } else if (ord.status == 'OUT_FOR_DELIVERY') {
      statusBg = const Color(0xFFEFF6FF);
      statusColor = const Color(0xFF2563EB);
    } else if (ord.status == 'CANCELLED' || ord.status == 'DELIVERY_FAILED') {
      statusBg = const Color(0xFFFFF1F2);
      statusColor = const Color(0xFFE11D48);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ord.orderNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE11D48)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ord.status.replaceAll('_', ' '),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${ord.deliveryType == "HOME_DELIVERY" ? "🚚 Home Delivery" : "🏢 Depot Self-Pickup"} • ${_formatDate(ord.createdAt)}',
            style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF64748B)),
          ),

          if (ord.deliveryStreet != null) ...[
            const SizedBox(height: 2),
            Text(
              'To: ${ord.deliveryStreet}, ${ord.deliveryPostalCode ?? ""}',
              style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF475569)),
            ),
          ],

          if (ord.assignedDriverName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Assigned Driver: ${ord.assignedDriverName} (${ord.assignedDriverPhone ?? ""})',
              style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: const Color(0xFF0F172A)),
            ),
          ],

          const Divider(height: 18, color: Color(0xFFF1F5F9)),

          // Items list
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ord.items.map((it) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '${it.productName} (${it.quantity}x)',
                  style: AppFontStyle.fontStyleW500(fontSize: 10.5, fontColor: const Color(0xFF334155)),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cost: \$0.00 FREE', style: AppFontStyle.fontStyleW800(fontSize: 12, fontColor: const Color(0xFF10B981))),

              if (ord.status == 'SUBMITTED' || ord.status == 'APPROVED')
                TextButton(
                  onPressed: () async {
                    final ok = await FoodAssistanceApi.cancelRequest(ord.id);
                    if (ok) {
                      if (context.mounted) {
                        Utils.showToast(context, 'Request cancelled');
                      }
                      controller.loadMyRequests(ord.beneficiaryEmail);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Cancel Request', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

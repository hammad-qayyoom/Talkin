import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/food_bank_assistance/controller/food_assistance_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FoodAssistanceHomeScreen extends GetView<FoodAssistanceController> {
  const FoodAssistanceHomeScreen({super.key});

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
          'Food Bank Assistance',
          style: AppFontStyle.fontStyleW700(
            fontSize: 17,
            fontColor: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'My Requests',
            icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB)),
            onPressed: () => Get.toNamed(AppRoutes.foodAssistanceRequestsScreen),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingLocations.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }

        final city = controller.selectedCity.value;

        return RefreshIndicator(
          color: const Color(0xFF2563EB),
          onRefresh: () async {
            await controller.fetchLocationsAndProducts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E40AF), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Global Food Relief Hub',
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 11,
                                    fontColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE11D48),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '100% FREE (\$0.00)',
                              style: AppFontStyle.fontStyleW800(
                                fontSize: 10,
                                fontColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Worldwide Food Bank',
                        style: AppFontStyle.fontStyleW800(
                          fontSize: 22,
                          fontColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Providing nutritious, dignified food packages & doorstep delivery to eligible families and community members.',
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 12.5,
                          fontColor: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Key Features Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeroStat('Active Hub', city?.name ?? 'Global Hub'),
                            _buildHeroStat('Delivery Zones', '${city?.zones.length ?? 0} Active Zones'),
                            _buildHeroStat('Cycle Cooldown', '${city?.requestCooldownDays ?? 14} Days'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Beneficiary Status Card (if available)
                if (controller.beneficiaryProfile.value != null) ...[
                  _buildBeneficiaryProfileCard(controller.beneficiaryProfile.value!),
                  const SizedBox(height: 20),
                ],

                // Action Navigation Grid
                Text(
                  'Community Assistance Services',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 154,
                  ),
                  children: [
                    _buildServiceCard(
                      icon: Icons.shopping_basket_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Browse Food Parcels',
                      subtitle: 'Choose healthy staple groceries',
                      badge: 'FREE',
                      onTap: () => Get.toNamed(AppRoutes.foodAssistanceCatalogScreen),
                    ),
                    _buildServiceCard(
                      icon: Icons.assignment_ind_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Apply for Assistance',
                      subtitle: 'Household verification & KYC',
                      badge: 'Verification',
                      onTap: () => Get.toNamed(AppRoutes.foodAssistanceApplyScreen),
                    ),
                    _buildServiceCard(
                      icon: Icons.track_changes_rounded,
                      iconBg: const Color(0xFFFFF1F2),
                      iconColor: const Color(0xFFE11D48),
                      title: 'Track My Parcels',
                      subtitle: 'Real-time delivery progress',
                      badge: '${controller.myRequests.length}',
                      onTap: () => Get.toNamed(AppRoutes.foodAssistanceRequestsScreen),
                    ),
                    _buildServiceCard(
                      icon: Icons.location_on_rounded,
                      iconBg: const Color(0xFFFAF5FF),
                      iconColor: const Color(0xFF9333EA),
                      title: 'Coverage & Depots',
                      subtitle: 'GTA postal codes & walk-in hubs',
                      onTap: () => _showZonesBottomSheet(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Featured Staple Categories
                Text(
                  'Included Food Categories',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(Icons.eco_rounded, 'Fresh Fruits', const Color(0xFFE11D48)),
                      _buildCategoryChip(Icons.spa_rounded, 'Organic Veggies', const Color(0xFFBE123C)),
                      _buildCategoryChip(Icons.grain_rounded, 'Grains & Rice', const Color(0xFFD97706)),
                      _buildCategoryChip(Icons.local_drink_rounded, 'Dairy & Milk', const Color(0xFF2563EB)),
                      _buildCategoryChip(Icons.restaurant_rounded, 'Halal Meat', const Color(0xFF0284C7)),
                      _buildCategoryChip(Icons.inventory_2_rounded, 'Pantry Cans', const Color(0xFFD97706)),
                      _buildCategoryChip(Icons.sanitizer_rounded, 'Hygiene Kits', const Color(0xFF0284C7)),
                      _buildCategoryChip(Icons.emoji_food_beverage_rounded, 'Juices & Tea', const Color(0xFFEAB308)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Phase 4 Cross-Link: Donate to Food Bank
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFF2563EB), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Support the Food Bank',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 14,
                                fontColor: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Donate funds to help purchase groceries for vulnerable families.',
                              style: AppFontStyle.fontStyleW400(
                                fontSize: 11,
                                fontColor: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.foodBankDonateScreen),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        child: const Text('Donate →'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Helpline & Contact Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${city?.name ?? "Operations"} Relief Helpline',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 14,
                              fontColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dispatch & Support: ${city?.contactPhone.isNotEmpty == true ? city!.contactPhone : "Notisboard Global Support"}',
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: Colors.white.withValues(alpha:0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${city?.contactEmail.isNotEmpty == true ? city!.contactEmail : "support@notisboardglobalfoundation.org"}',
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 11.5,
                          fontColor: Colors.white.withValues(alpha:0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeroStat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: AppFontStyle.fontStyleW500(
            fontSize: 10,
            fontColor: Colors.white.withValues(alpha:0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppFontStyle.fontStyleW700(
            fontSize: 12,
            fontColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBeneficiaryProfileCard(var profile) {
    final isApproved = profile.status == 'APPROVED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved ? const Color(0xFFE11D48) : const Color(0xFFF59E0B),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Beneficiary Status',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 13,
                  fontColor: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isApproved
                      ? const Color(0xFFFFF1F2)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  profile.status,
                  style: AppFontStyle.fontStyleW800(
                    fontSize: 10,
                    fontColor: isApproved ? const Color(0xFFE11D48) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            profile.fullName,
            style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A)),
          ),
          Text(
            'Address: ${profile.streetAddress}, ${profile.postalCode}',
            style: AppFontStyle.fontStyleW400(fontSize: 11.5, fontColor: const Color(0xFF64748B)),
          ),
          if (isApproved) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.foodAssistanceCatalogScreen),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                elevation: 0,
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Build Your Food Parcel Now →', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: AppFontStyle.fontStyleW700(fontSize: 10, fontColor: const Color(0xFF475569)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppFontStyle.fontStyleW700(fontSize: 12.5, fontColor: const Color(0xFF0F172A)),
                  maxLines: 2,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFontStyle.fontStyleW400(fontSize: 10.5, fontColor: const Color(0xFF64748B)),
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(IconData icon, String title, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppFontStyle.fontStyleW600(fontSize: 11.5, fontColor: const Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  void _showZonesBottomSheet(BuildContext context) {
    final city = controller.selectedCity.value;
    if (city == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Toronto GTA Service Coverage',
                style: AppFontStyle.fontStyleW800(fontSize: 18, fontColor: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                '4 Active Delivery Zones & 2 Local Community Depots',
                style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 6),
                        Text('Delivery Zones', style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...city.zones.map((zone) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(zone.name, style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Text(
                              'Days: ${zone.deliveryDays.join(", ")}',
                              style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: zone.postalPrefixes.take(8).map((pfx) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: Text(
                                    pfx,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 6),
                        Text('Walk-In Community Depots', style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: const Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...city.pickupLocations.map((loc) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.name, style: AppFontStyle.fontStyleW700(fontSize: 13, fontColor: const Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Expanded(child: Text(loc.address, style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF475569)))),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Expanded(child: Text(loc.operatingHours, style: AppFontStyle.fontStyleW400(fontSize: 11, fontColor: const Color(0xFF64748B)))),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: Color(0xFFE11D48)),
                                const SizedBox(width: 4),
                                Expanded(child: Text(loc.contactPhone, style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: const Color(0xFFE11D48)))),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

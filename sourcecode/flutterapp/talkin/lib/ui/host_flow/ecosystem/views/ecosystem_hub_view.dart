import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/ecosystem/controllers/ecosystem_controller.dart';
import 'package:notisboard/ui/host_flow/ecosystem/models/ecosystem_status_model.dart';
import 'package:notisboard/ui/host_flow/ecosystem/views/organizer_application_view.dart';
import 'package:notisboard/ui/host_flow/ecosystem/views/organizer_portal_view.dart';
import 'package:notisboard/ui/host_flow/ecosystem/views/vendor_application_view.dart';
import 'package:notisboard/ui/host_flow/ecosystem/views/vendor_portal_view.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class EcosystemHubView extends StatelessWidget {
  const EcosystemHubView({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);
    final controller = Get.put(EcosystemController());

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.redesignBrandDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Foundation Ecosystem",
          style: AppFontStyle.fontStyleW700(
            fontSize: 18,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.redesignBrandDark),
            onPressed: () => controller.refreshAll(),
          ),
        ],
      ),
      body: GetBuilder<EcosystemController>(
        builder: (c) {
          if (c.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.redesignBrandRed),
            );
          }

          return RefreshIndicator(
            color: AppColors.redesignBrandRed,
            onRefresh: () => c.refreshAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.redesignBrandRed,
                          AppColors.redesignBrandRed.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.redesignBrandRed.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Notisboard Ecosystem Bridge",
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 16,
                                fontColor: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Expand your reach beyond consultations. Sell products on Foundation Marketplace and host events or fundraising campaigns directly synchronized with the Global Foundation.",
                          style: AppFontStyle.fontStyleW400(
                            fontSize: 13,
                            fontColor: AppColors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "Your Ecosystem Roles",
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 16,
                      fontColor: AppColors.redesignBrandDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 1. VENDOR CARD
                  _buildRoleCard(
                    context: context,
                    icon: Icons.storefront_rounded,
                    title: "Foundation Vendor (Marketplace)",
                    subtitle: "Sell physical and digital goods on the Foundation Marketplace.",
                    roleStatus: c.vendorStatus,
                    isUnlocked: c.isVendorUnlocked,
                    onApply: () => Get.to(() => const VendorApplicationView()),
                    onOpenPortal: () => Get.to(() => const VendorPortalView()),
                  ),

                  const SizedBox(height: 16),

                  // 2. ORGANIZER CARD
                  _buildRoleCard(
                    context: context,
                    icon: Icons.campaign_rounded,
                    title: "Foundation Organizer (Events & Causes)",
                    subtitle: "Organize ticketed events and launch verified charitable fundraising campaigns.",
                    roleStatus: c.organizerStatus,
                    isUnlocked: c.isOrganizerUnlocked,
                    onApply: () => Get.to(() => const OrganizerApplicationView()),
                    onOpenPortal: () => Get.to(() => const OrganizerPortalView()),
                  ),

                  const SizedBox(height: 24),
                  _buildAdminApprovalInfo(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required EcosystemRoleStatus roleStatus,
    required bool isUnlocked,
    required VoidCallback onApply,
    required VoidCallback onOpenPortal,
  }) {
    Color badgeColor;
    Color badgeBg;
    String badgeText;

    switch (roleStatus.status) {
      case 'approved':
        badgeColor = Colors.green.shade800;
        badgeBg = Colors.green.shade50;
        badgeText = "APPROVED & UNLOCKED";
        break;
      case 'pending':
      case 'under_review':
        badgeColor = Colors.amber.shade900;
        badgeBg = Colors.amber.shade50;
        badgeText = "UNDER FOUNDATION REVIEW";
        break;
      case 'changes_requested':
        badgeColor = Colors.orange.shade900;
        badgeBg = Colors.orange.shade50;
        badgeText = "CHANGES REQUESTED";
        break;
      case 'rejected':
        badgeColor = Colors.red.shade900;
        badgeBg = Colors.red.shade50;
        badgeText = "REJECTED";
        break;
      default:
        badgeColor = Colors.grey.shade700;
        badgeBg = Colors.grey.shade100;
        badgeText = "NOT APPLIED";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnlocked ? Colors.green.shade300 : AppColors.redesignSoftBorder,
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.green.shade50 : AppColors.redesignSurfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isUnlocked ? Colors.green.shade700 : AppColors.redesignBrandRed, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: AppFontStyle.fontStyleW700(fontSize: 10, fontColor: badgeColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: AppFontStyle.fontStyleW400(fontSize: 12, fontColor: AppColors.redesignMutedText, height: 1.3),
          ),

          if (roleStatus.applicationRef != null) ...[
            const SizedBox(height: 8),
            Text(
              "Application Ref: ${roleStatus.applicationRef}",
              style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.redesignMutedText),
            ),
          ],

          if (roleStatus.status == 'changes_requested' && (roleStatus.changesRequested?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                "Feedback from Foundation Admin: ${roleStatus.changesRequested}",
                style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: Colors.orange.shade900),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Actions
          if (isUnlocked)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.dashboard_rounded, size: 18),
                label: const Text("Open Management Hub"),
                onPressed: onOpenPortal,
              ),
            )
          else if (roleStatus.status == 'pending' || roleStatus.status == 'under_review')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, size: 18, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Submitted to Foundation Admin for KYC verification.",
                      style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.redesignBrandRed,
                  side: BorderSide(color: AppColors.redesignBrandRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(roleStatus.status == 'changes_requested' ? "Update Application" : "Apply Now"),
                onPressed: onApply,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminApprovalInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, color: AppColors.redesignBrandRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Applications are reviewed directly by the Notice Board Global Foundation administration team. Live updates will notify you here as soon as documents are verified.",
              style: AppFontStyle.fontStyleW400(
                fontSize: 11.5,
                fontColor: AppColors.redesignMutedText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


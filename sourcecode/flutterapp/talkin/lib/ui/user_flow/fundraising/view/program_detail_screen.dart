import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/controller/program_detail_controller.dart';
import 'package:notisboard/ui/user_flow/fundraising/shimmer/fundraising_shimmer.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class ProgramDetailScreen extends GetView<ProgramDetailController> {
  const ProgramDetailScreen({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.isLoading.value && controller.program.value == null) {
          return const CampaignDetailShimmer();
        }

        final program = controller.program.value;
        if (program == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Program Details')),
            body: const Center(child: Text('Program not found.')),
          );
        }

        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App Bar with Image
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    backgroundColor: AppColors.redesignBrandRedDeep,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                      onPressed: () => Get.back(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: program.featuredImage != null && program.featuredImage!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: program.featuredImage!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const AppImageShimmer(
                                borderRadius: BorderRadius.zero,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: _accentSoftBg,
                                child: Icon(Icons.public_rounded, color: _brandRed.withValues(alpha: 0.5), size: 50),
                              ),
                            )
                          : Container(
                              color: _accentSoftBg,
                              child: Icon(Icons.public_rounded, color: _brandRed.withValues(alpha: 0.5), size: 50),
                            ),
                    ),
                  ),

                  // Program Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Region Pill
                          if (program.region != null && program.region!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _accentSoftBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _brandRed.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.public_rounded, size: 12, color: _brandRed),
                                  const SizedBox(width: 4),
                                  Text(
                                    program.region!,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 11,
                                      fontColor: _brandRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            program.title,
                            style: AppFontStyle.fontStyleW800(
                              fontSize: 22,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Impact Banner
                          if (program.impact != null && program.impact!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.redesignBrandRed,
                                    AppColors.redesignBrandRedDeep,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _brandRed.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      program.icon ?? '🌍',
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MEASURABLE PROGRAM IMPACT',
                                          style: AppFontStyle.fontStyleW700(
                                            fontSize: 10.5,
                                            fontColor: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          program.impact!,
                                          style: AppFontStyle.fontStyleW800(
                                            fontSize: 17,
                                            fontColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Program Overview
                          Text(
                            'Program Overview & Mandate',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 16,
                              fontColor: _brandDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (program.content != null && program.content!.isNotEmpty)
                                ? program.content!
                                : (program.description ?? 'Program details available on official foundation portal.'),
                            style: AppFontStyle.fontStyleW400(
                              fontSize: 13.5,
                              fontColor: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Direct Aid Transparency Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _softBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.verified_user_rounded, color: _brandRed, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '100% Direct Allocation Guarantee',
                                        style: AppFontStyle.fontStyleW700(
                                          fontSize: 13.5,
                                          fontColor: _brandDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Every dollar contributed to this program is directly mobilized for field equipment, medical relief, or operational supply lines with zero hidden deductions.',
                                        style: AppFontStyle.fontStyleW400(
                                          fontSize: 12,
                                          fontColor: _slateGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom Action
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
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.donationScreen,
                      arguments: {
                        'program': program,
                        'donationType': 'PROGRAM',
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Support This Program',
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
}

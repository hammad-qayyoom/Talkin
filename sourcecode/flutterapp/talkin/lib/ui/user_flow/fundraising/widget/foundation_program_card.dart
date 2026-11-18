import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/fundraising/model/fundraising_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class FoundationProgramCard extends StatelessWidget {
  final FoundationProgram program;

  const FoundationProgramCard({
    super.key,
    required this.program,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _slateGrey = AppColors.redesignSlateGrey;
  static final Color _accentSoftBg = AppColors.redesignAccentSoftBg;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.programDetailScreen,
          arguments: program,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Icon Badge & Region
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: program.featuredImage != null && program.featuredImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: program.featuredImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const AppImageShimmer(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            errorWidget: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Icon badge
                if (program.icon != null && program.icon!.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        program.icon!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                // Region badge
                if (program.region != null && program.region!.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.public_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            program.region!,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 10,
                              fontColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    program.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 16,
                      fontColor: _brandDark,
                    ),
                  ),
                  if (program.description != null && program.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      program.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW400(
                        fontSize: 12.5,
                        fontColor: _slateGrey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Impact metric pill
                  if (program.impact != null && program.impact!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF059669)),
                          const SizedBox(width: 5),
                          Text(
                            'Impact: ${program.impact}',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 11.5,
                              fontColor: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),

                  // Support Program Action
                  SizedBox(
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Support Program',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _accentSoftBg,
      child: Center(
        child: Icon(Icons.volunteer_activism_rounded, color: _brandRed.withValues(alpha: 0.35), size: 40),
      ),
    );
  }
}

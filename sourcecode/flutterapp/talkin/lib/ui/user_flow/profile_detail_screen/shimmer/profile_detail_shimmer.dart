import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:notisboard/utils/app_color.dart';

class ProfileDetailShimmer extends StatelessWidget {
  const ProfileDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final isTablet = width >= 760;
        final heroHeight =
            (width * (isTablet ? 0.58 : 0.95)).clamp(300.0, 520.0).toDouble();

        Widget chip({double w = 90}) {
          return Container(
            height: 28,
            width: w,
            decoration: BoxDecoration(
              color: AppColors.redesignShimmerBase,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }

        return Shimmer.fromColors(
          baseColor: AppColors.redesignShimmerBase,
          highlightColor: AppColors.white,
          child: Column(
            children: [
              Container(
                height: heroHeight,
                width: double.infinity,
                color: AppColors.redesignShimmerBaseAlt,
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.redesignSoftBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 66,
                              width: 66,
                              decoration: BoxDecoration(
                                color: AppColors.redesignShimmerBase,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 20,
                                    width: 170,
                                    decoration: BoxDecoration(
                                      color: AppColors.redesignShimmerBase,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      chip(w: 88),
                                      const SizedBox(width: 8),
                                      chip(w: 118),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        chip(w: 150),
                        const SizedBox(height: 12),
                        Container(
                          height: 46,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.redesignShimmerBase,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 22,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.redesignShimmerBase,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.redesignShimmerBase,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: width * 0.74,
                          decoration: BoxDecoration(
                            color: AppColors.redesignShimmerBase,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            chip(w: 120),
                            const SizedBox(width: 8),
                            chip(w: 116),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redesignSurfaceSoft,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.redesignShimmerBase,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.redesignShimmerBase,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 44,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.redesignShimmerBase,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.redesignShimmerBase,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(
                    2,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 96,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.redesignShimmerBase,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfileDetailButtonShimmer extends StatelessWidget {
  const ProfileDetailButtonShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.redesignShimmerBase,
      highlightColor: AppColors.white,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.redesignSoftBorder),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.redesignShimmerBase,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.redesignShimmerBase,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

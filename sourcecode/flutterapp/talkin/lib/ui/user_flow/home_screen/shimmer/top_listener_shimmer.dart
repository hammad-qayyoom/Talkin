import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/utils.dart';

class TopListenerShimmer extends StatelessWidget {
  const TopListenerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget shimmerCard({double bottomPadding = 14}) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.redesignShimmerCard,
            border: Border.all(color: AppColors.redesignSoftBorder),
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                width: 68,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              12.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 86,
                    width: 86,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 18,
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            10.width,
                            Container(
                              height: 32,
                              width: 32,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        8.height,
                        Container(
                          height: 13,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        10.height,
                        Row(
                          children: [
                            for (int i = 0; i < 2; i++)
                              Expanded(
                                child: Container(
                                  height: 20,
                                  margin: const EdgeInsets.only(
                                      bottom: 5, right: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.redesignShimmerChip,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.height,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  10.width,
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: AppColors.redesignShimmerTopBase,
      highlightColor: AppColors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 700;

          if (!isTablet) {
            return ListView.builder(
              itemCount: 4,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => shimmerCard(),
            );
          }

          final columns = constraints.maxWidth >= 1200 ? 3 : 2;
          const spacing = 14.0;
          final cardWidth =
              ((constraints.maxWidth - (spacing * (columns - 1))) / columns)
                  .clamp(280.0, 520.0)
                  .toDouble();

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
              4,
              (index) => SizedBox(
                width: cardWidth,
                child: shimmerCard(bottomPadding: 0),
              ),
            ),
          );
        },
      ),
    );
  }
}

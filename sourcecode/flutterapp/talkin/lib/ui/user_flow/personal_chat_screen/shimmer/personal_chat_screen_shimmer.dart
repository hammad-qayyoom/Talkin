import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';

class PersonalChatScreenShimmer extends StatelessWidget {
  const PersonalChatScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.redesignShimmerBase,
      highlightColor: AppColors.white,
      child: ListView.builder(
        itemCount: 12,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Container(
                  constraints:
                      BoxConstraints(maxWidth: Get.width * (isMe ? 0.62 : 0.7)),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.redesignDarkGradientEnd
                        : AppColors.redesignSurfaceInput,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isMe ? 14 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 14),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.redesignSoftBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 11,
                        width: Get.width * 0.44,
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.white.withValues(alpha: 0.28)
                              : AppColors.redesignShimmerBase,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 11,
                        width: Get.width * 0.28,
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.white.withValues(alpha: 0.28)
                              : AppColors.redesignShimmerBase,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

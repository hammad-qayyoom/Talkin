import 'package:flutter/material.dart';
import 'package:notisboard/utils/app_color.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    required this.isVerified,
    this.size = 18,
    this.margin = const EdgeInsets.only(left: 6),
  });

  final bool isVerified;
  final double size;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    if (!isVerified) {
      return const SizedBox.shrink();
    }

    final iconSize = size * 0.62;

    return Container(
      margin: margin,
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.blue,
        border: Border.all(color: AppColors.white, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check_rounded,
        size: iconSize,
        color: AppColors.white,
      ),
    );
  }
}

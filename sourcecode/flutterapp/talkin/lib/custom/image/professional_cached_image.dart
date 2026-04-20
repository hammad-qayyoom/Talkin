import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:shimmer/shimmer.dart';

class AppImageShimmer extends StatelessWidget {
  const AppImageShimmer({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final resolvedBase = baseColor ?? AppColors.redesignShimmerBase;
    final resolvedHighlight = highlightColor ?? AppColors.white.withValues(alpha: 0.82);

    return Shimmer.fromColors(
      baseColor: resolvedBase,
      highlightColor: resolvedHighlight,
      period: const Duration(milliseconds: 1150),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.redesignShimmerBaseAlt,
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : (borderRadius ?? BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class ProfessionalCachedImage extends StatelessWidget {
  const ProfessionalCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 220),
    this.fadeOutDuration = const Duration(milliseconds: 90),
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();

    if (url.isEmpty) {
      return _buildError();
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      placeholderFadeInDuration: const Duration(milliseconds: 120),
      placeholder: (_, __) => placeholder ?? _buildShimmer(),
      errorWidget: (_, __, ___) => errorWidget ?? _buildError(),
    );
  }

  Widget _buildShimmer() {
    return AppImageShimmer(
      width: width,
      height: height,
      shape: shape,
      borderRadius: borderRadius,
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(12)),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: AppColors.darkGrey.withValues(alpha: 0.72),
      ),
    );
  }
}

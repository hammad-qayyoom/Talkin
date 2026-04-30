// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';

String _resolveImageUrl(String image) {
  final value = image.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('data:image/')) return value;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('//')) {
    return 'https:$value';
  }
  if (value.startsWith('www.')) {
    return 'https://$value';
  }
  if (value.startsWith('${Uri.parse(Api.baseUrl).host}/')) {
    return 'https://$value';
  }

  final normalized = value.startsWith('/') ? value.substring(1) : value;
  return '${Api.baseUrl}$normalized';
}

Widget _avatarPlaceholder(String assetPath) {
  return Stack(
    fit: StackFit.expand,
    children: [
      const AppImageShimmer(),
      Center(
        child: Opacity(
          opacity: 0.72,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ],
  );
}

Widget _messagePlaceholder({
  required double iconHeight,
  required Color iconTint,
}) {
  return Stack(
    fit: StackFit.expand,
    children: [
      Container(
        color: AppColors.lightGrey.withValues(alpha: 0.6),
        child: const AppImageShimmer(
          baseColor: Color(0xFFE8ECF1),
        ),
      ),
      Center(
        child: Image.asset(
          AppAsset.imagePlaceHolder,
          height: iconHeight,
          color: iconTint,
        ),
      ),
    ],
  );
}

class CustomProfileImage extends StatelessWidget {
  final String image;
  BoxFit? fit;
  CustomProfileImage({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(image);
    if (imageUrl.isEmpty) {
      return Image.asset(AppAsset.profilePlaceHolder, fit: fit ?? BoxFit.cover);
    }

    return ProfessionalCachedImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.cover,
      placeholder: _avatarPlaceholder(AppAsset.profilePlaceHolder),
      errorWidget: Image.asset(
        AppAsset.profilePlaceHolder,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}

class CustomListenerProfileImage extends StatelessWidget {
  final String image;
  BoxFit? fit;
  CustomListenerProfileImage({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(image);
    if (imageUrl.isEmpty) {
      return Image.asset(AppAsset.listenerPlaceHolder,
          fit: fit ?? BoxFit.cover);
    }

    return ProfessionalCachedImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.cover,
      placeholder: _avatarPlaceholder(AppAsset.listenerPlaceHolder),
      errorWidget: Image.asset(
        AppAsset.listenerPlaceHolder,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}

class SendMessageImage extends StatelessWidget {
  final String image;
  BoxFit? fit;
  SendMessageImage({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(image);
    if (imageUrl.isEmpty) {
      return Image.asset(AppAsset.profilePlaceHolder, fit: fit ?? BoxFit.cover);
    }

    final placeholder = _messagePlaceholder(
      iconHeight: 50,
      iconTint: AppColors.onBoardingTxt.withValues(alpha: 0.6),
    );

    return ProfessionalCachedImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.cover,
      placeholder: placeholder,
      errorWidget: placeholder,
    );
  }
}

class SendMessageImageFullScreen extends StatelessWidget {
  final String image;
  BoxFit? fit;
  SendMessageImageFullScreen({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(image);
    if (imageUrl.isEmpty) {
      return Image.asset(AppAsset.profilePlaceHolder, fit: fit ?? BoxFit.cover);
    }

    final placeholder = SizedBox(
      width: Get.height,
      height: Get.width,
      child: _messagePlaceholder(
        iconHeight: 160,
        iconTint: AppColors.onBoardingTxt.withValues(alpha: 0.7),
      ),
    );

    return ProfessionalCachedImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.cover,
      placeholder: placeholder,
      errorWidget: Center(
        child: Image.asset(
          AppAsset.imagePlaceHolder,
          height: 160,
        ),
      ),
    );
  }
}

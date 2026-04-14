import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_profile_response_model.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_review_model.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/shimmer/profile_detail_shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class TopImageView extends StatelessWidget {
  const TopImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heroWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final isTablet = heroWidth >= 760;
        final heroHeight = (heroWidth * (isTablet ? 0.58 : 0.95))
            .clamp(300.0, 520.0)
            .toDouble();

        return GetBuilder<ProfileDetailScreenController>(
          id: Constant.listenerProfile,
          builder: (controller) {
            return SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SendMessageImageFullScreen(
                    image: controller.listenerProfileModel?.data?.image ?? '',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.56, 1],
                        colors: [
                          AppColors.black.withValues(alpha: 0.08),
                          AppColors.transparent,
                          AppColors.black.withValues(alpha: 0.26),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class UserProfileInfoView extends StatelessWidget {
  const UserProfileInfoView({super.key});

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.redesignStatusSuccessBg;
      case 'on call':
        return AppColors.redesignAccentSoftBg;
      default:
        return AppColors.redesignSurfaceNeutral;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.redesignStatusSuccessDark;
      case 'on call':
        return AppColors.redesignBrandRed;
      default:
        return AppColors.redesignMutedText;
    }
  }

  Color _statusDotColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.redesignStatusSuccess;
      case 'on call':
        return AppColors.redesignBrandRed;
      default:
        return AppColors.redesignMutedText;
    }
  }

  void _copyUniqueId({
    required BuildContext context,
    required ProfileDetailScreenController controller,
    required String uniqueId,
  }) {
    if (uniqueId.trim().isEmpty) {
      return;
    }

    if (!controller.isToastVisible) {
      Utils.copyText(uniqueId);
      Utils.showToast(context, 'Copied');
      controller.isToastVisible = true;
      Future.delayed(const Duration(seconds: 2), () {
        controller.isToastVisible = false;
      });
    }
  }

  void _openPosts(ProfileDetailScreenController controller) {
    final targetExpertId =
        (controller.listenerId ?? controller.expertId ?? '').toString().trim();
    if (targetExpertId.isEmpty) {
      return;
    }

    Get.toNamed(
      AppRoutes.feedScreen,
      arguments: {
        'standalone': true,
        'title': 'Profile Posts',
        'expertId': targetExpertId,
        'showComposer': false,
      },
    );
  }

  Widget _buildSlotChips({
    required String title,
    required List<Map<String, dynamic>> slots,
    required ProfileDetailScreenController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFontStyle.fontStyleW600(
            fontSize: 12,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        const SizedBox(height: 8),
        slots.isEmpty
            ? Text(
                'No slots available',
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: AppColors.redesignMutedText,
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots
                    .map(
                      (slot) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: AppColors.redesignSoftBorder),
                        ),
                        child: Text(
                          controller.formatSlotLabel(slot),
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 10,
                            fontColor: AppColors.redesignBrandDark,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildPriceTile({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFontStyle.fontStyleW500(
              fontSize: 12,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppFontStyle.fontStyleW700(
              fontSize: 16,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 760;
    final isWideTablet = width >= 980;

    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        final ListenerData? data = controller.listenerProfileModel?.data;
        if (data == null) {
          return const SizedBox.shrink();
        }

        final name = (data.name ?? 'Expert').trim().isEmpty
            ? 'Expert'
            : (data.name ?? 'Expert').trim();
        final ageLabel = data.age == null ? '' : ', ${data.age}';
        final statusLabel = (data.statusLabel ?? 'Offline').trim().isEmpty
            ? 'Offline'
            : (data.statusLabel ?? 'Offline').trim();
        final uniqueId = (data.uniqueId ?? '').toString();
        final topics = (data.talkTopics ?? const <String>[])
            .where((item) => item.trim().isNotEmpty)
            .toList();

        Widget aboutSection() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Self Intro',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                (data.selfIntro ?? '').trim().isEmpty
                    ? 'No introduction added yet.'
                    : (data.selfIntro ?? ''),
                style: AppFontStyle.fontStyleW500(
                  fontSize: 14,
                  fontColor: AppColors.redesignMutedText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: 20,
                    color: AppColors.redesignMutedText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${EnumLocale.txtLanguage.name.tr} : ${(data.language ?? const <String>[]).join(', ')}',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 15,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                ],
              ),
              if (topics.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topics
                      .map(
                        (topic) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redesignSurfaceSoft,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.redesignSoftBorder,
                            ),
                          ),
                          child: Text(
                            topic,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 12,
                              fontColor: AppColors.redesignMutedText,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          );
        }

        Widget pricingSection() {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.redesignSurfaceSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.redesignSoftBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Pricing',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 18,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceTile(
                        title: 'Audio',
                        value: '${data.ratePrivateAudioCall ?? 0} credits',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriceTile(
                        title: 'Video',
                        value: '${data.ratePrivateVideoCall ?? 0} credits',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Available Slots',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 17,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 10),
                controller.isSlotsPreviewLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSlotChips(
                            title: 'Audio Slots',
                            slots: controller.audioSlotsPreview,
                            controller: controller,
                          ),
                          const SizedBox(height: 12),
                          _buildSlotChips(
                            title: 'Video Slots',
                            slots: controller.videoSlotsPreview,
                            controller: controller,
                          ),
                        ],
                      ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.redesignSoftBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: isTablet ? 76 : 66,
                      width: isTablet ? 76 : 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.redesignBrandRed
                              .withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomProfileImage(
                          image: data.image ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name$ageLabel',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: isTablet ? 28 : 18,
                              fontColor: AppColors.redesignBrandDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBackground(statusLabel),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 8,
                                      width: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _statusDotColor(statusLabel),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusLabel,
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 11,
                                        fontColor:
                                            _statusTextColor(statusLabel),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (uniqueId.trim().isNotEmpty)
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () => _copyUniqueId(
                                    context: context,
                                    controller: controller,
                                    uniqueId: uniqueId,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.redesignSurfaceSoft,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.redesignSoftBorder,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'ID: $uniqueId',
                                          style: AppFontStyle.fontStyleW600(
                                            fontSize: 11,
                                            fontColor:
                                                AppColors.redesignBrandRed,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 14,
                                          color: AppColors.redesignBrandRed,
                                        ),
                                      ],
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
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.redesignAccentSoftBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.redesignCoinText,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${data.totalCoins ?? 0} Session Credit',
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 12,
                            fontColor: AppColors.redesignCoinText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openPosts(controller),
                    icon: const Icon(Icons.dynamic_feed_rounded, size: 18),
                    label: Text(
                      'View Posts',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 14,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.redesignSoftBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      foregroundColor: AppColors.redesignBrandDark,
                      backgroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isWideTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: aboutSection()),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: pricingSection()),
                    ],
                  )
                else ...[
                  aboutSection(),
                  const SizedBox(height: 16),
                  pricingSection(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class StatusView extends StatelessWidget {
  const StatusView({super.key});

  IconData _iconAt(int index) {
    switch (index) {
      case 0:
        return Icons.call_rounded;
      case 1:
        return Icons.star_rounded;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: List.generate(
              controller.statsList.length,
              (index) {
                final item = controller.statsList[index];
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index == controller.statsList.length - 1 ? 0 : 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.redesignSoftBorder),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: AppColors.redesignAccentSoftBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _iconAt(index),
                            size: 20,
                            color: AppColors.redesignBrandRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title']?.toString() ?? '',
                          textAlign: TextAlign.center,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 11,
                            fontColor: AppColors.redesignMutedText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['count']?.toString().isEmpty == true
                              ? '0'
                              : item['count']?.toString() ?? '0',
                          textAlign: TextAlign.center,
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 16,
                            fontColor: AppColors.redesignBrandDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ReviewShow extends StatelessWidget {
  const ReviewShow({super.key});

  Widget _reviewCard({
    required Review review,
    required double rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.redesignSurfaceSoft,
                ),
                clipBehavior: Clip.hardEdge,
                child: CustomListenerProfileImage(
                  image: review.profilePic ?? '',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.fullName ?? '',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 15,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StarRating(rating: rating, size: 16),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceInput,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  review.time ?? '',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 10,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.review ?? '',
            style: AppFontStyle.fontStyleW500(
              fontSize: 13,
              fontColor: AppColors.redesignMutedText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.idGetListenerReview,
      builder: (controller) {
        final List<Review> reviews = controller.reviews ?? [];
        if (reviews.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      EnumLocale.txtReviews.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 24,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.allReviewScreen,
                        arguments: controller.listenerId,
                      );
                    },
                    child: Text(
                      EnumLocale.txtViewAll.name.tr,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: AppColors.redesignBrandRed,
                      ),
                    ),
                  ),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final topReviews = reviews.take(4).toList();
                  final showGrid = constraints.maxWidth >= 920;

                  if (!showGrid) {
                    return ListView.separated(
                      itemCount: topReviews.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final review = topReviews[index];
                        return _reviewCard(
                          review: review,
                          rating: (review.rating ?? 0).toDouble(),
                        );
                      },
                    );
                  }

                  final cardWidth = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: topReviews
                        .map(
                          (review) => SizedBox(
                            width: cardWidth,
                            child: _reviewCard(
                              review: review,
                              rating: (review.rating ?? 0).toDouble(),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfileBottomButtonView extends StatelessWidget {
  const ProfileBottomButtonView({super.key});

  void _openChat(ProfileDetailScreenController controller) {
    Get.toNamed(
      AppRoutes.personalChatScreen,
      arguments: [
        controller.listenerProfileModel?.data?.id,
        controller.listenerProfileModel?.data?.name,
        controller.listenerProfileModel?.data?.statusLabel,
        controller.listenerProfileModel?.data?.image,
        controller.listenerProfileModel?.data?.ratePrivateAudioCall,
        controller.listenerProfileModel?.data?.ratePrivateVideoCall,
        controller.listenerProfileModel?.data?.isFake,
        controller.listenerProfileModel?.data?.video,
        controller.listenerProfileModel?.data?.isAvailableForPrivateVideoCall,
        controller.listenerProfileModel?.data?.isAvailableForPrivateAudioCall,
      ],
    );
  }

  void _openBookSession(ProfileDetailScreenController controller) {
    Get.toNamed(
      AppRoutes.userBookSessionScreen,
      arguments: {
        'listenerId': controller.listenerProfileModel?.data?.id ?? '',
        'listenerName': controller.listenerProfileModel?.data?.name ?? '',
        'listenerImage': controller.listenerProfileModel?.data?.image ?? '',
        'availableForPrivateAudioCall': controller
                .listenerProfileModel?.data?.isAvailableForPrivateAudioCall ??
            false,
        'availableForPrivateVideoCall': controller
                .listenerProfileModel?.data?.isAvailableForPrivateVideoCall ??
            false,
        'ratePrivateAudioCall':
            controller.listenerProfileModel?.data?.ratePrivateAudioCall ?? 0,
        'ratePrivateVideoCall':
            controller.listenerProfileModel?.data?.ratePrivateVideoCall ?? 0,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        if (controller.isLoading) {
          return const ProfileDetailButtonShimmer();
        }

        final hasProfile = (controller.listenerProfileModel?.data?.id ?? '')
            .toString()
            .trim()
            .isNotEmpty;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.redesignSoftBorder),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed:
                          hasProfile ? () => _openChat(controller) : null,
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 20),
                      label: Text(
                        EnumLocale.txtChatNow.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 15,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        foregroundColor: AppColors.redesignBrandDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: hasProfile
                          ? () => _openBookSession(controller)
                          : null,
                      icon: const Icon(Icons.calendar_month_rounded, size: 20),
                      label: Text(
                        'Book Session',
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 15,
                          fontColor: AppColors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: AppColors.white,
                        backgroundColor: AppColors.redesignBrandDark,
                        disabledBackgroundColor: AppColors.redesignSoftBorder,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final int maxStars;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final difference = rating - index;
        final isFilled = difference >= 1;
        final isHalf = difference >= 0.5 && difference < 1;

        return Icon(
          isFilled
              ? Icons.star_rounded
              : isHalf
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: (isFilled || isHalf)
              ? AppColors.rateStarColor
              : AppColors.redesignSoftBorder,
        );
      }),
    );
  }
}

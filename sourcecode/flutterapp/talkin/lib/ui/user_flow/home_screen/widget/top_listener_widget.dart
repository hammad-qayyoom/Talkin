import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:notisboard/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/auth_guard.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/font_style.dart';

class TopListenerWidget extends StatelessWidget {
  const TopListenerWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDarkAlt;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  Widget _buildListenerCard({
    required TopListeners listener,
    required VoidCallback onViewProfile,
    required VoidCallback onBookSession,
    double bottomMargin = 12,
  }) {
    final status = (listener.statusLabel ?? 'Available').trim().isEmpty
        ? 'Available'
        : listener.statusLabel!.trim();
    final topics =
        (listener.talkTopics ?? []).where((e) => e.trim().isNotEmpty).toList();
    final firstTopic = topics.isNotEmpty ? topics.first : 'General';
    final language = (listener.language ?? []).isEmpty
        ? 'English'
        : listener.language!.first;
    final rating = listener.rating ?? 5.0;
    final name = listener.name ?? 'Expert';
    final isVerified = listener.isVerifiedBadge ?? true;
    final experience = listener.experience ?? '5';

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 360;
        final avatarSize = isCompact ? 68.0 : 74.0;

        return Container(
          margin: EdgeInsets.only(bottom: bottomMargin),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _softBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              GestureDetector(
                onTap: onViewProfile,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: avatarSize,
                    width: avatarSize,
                    color: AppColors.redesignAvatarSurface,
                    child: CustomListenerProfileImage(
                      image: listener.image ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Center Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + Verified Badge
                    GestureDetector(
                      onTap: onViewProfile,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 14.5,
                                fontColor: _brandDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          VerifiedBadge(
                            isVerified: isVerified,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Badges row 1
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 9.5,
                              fontColor: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB300)),
                              const SizedBox(width: 2),
                              Text(
                                '${rating.toStringAsFixed(1)} rating',
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 9.5,
                                  fontColor: AppColors.redesignMutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.business_center_outlined, size: 11, color: Color(0xFF757575)),
                              const SizedBox(width: 2),
                              Text(
                                '$experience Exp',
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 9.5,
                                  fontColor: AppColors.redesignMutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Badges row 2
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language_rounded, size: 11, color: Color(0xFF757575)),
                              const SizedBox(width: 2),
                              Text(
                                language,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 9.5,
                                  fontColor: AppColors.redesignMutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            firstTopic,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 9.5,
                              fontColor: AppColors.redesignMutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right Column Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onViewProfile,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: _brandDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Profile',
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 11,
                              fontColor: _brandDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onBookSession,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: _brandRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Book Session',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeScreenController homeController =
        Get.find<HomeScreenController>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isLargeTabletScreen = screenWidth >= 1100;
    final isTabletScreen = screenWidth >= 760;
    final horizontalInset = isLargeTabletScreen
        ? 28.0
        : isTabletScreen
            ? 22.0
            : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Top Experts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTabletScreen ? 20 : 16.5,
                    fontColor: _brandDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.topListenersViewAll,
                    arguments: {
                      'categoryId': homeController.selectedCategoryId,
                    },
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: isTabletScreen ? 13.5 : 12,
                        fontColor: _brandRed,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _brandRed,
                      size: isTabletScreen ? 15 : 13,
                    ),
                  ],
                ),
              ),
            ],
          ).paddingOnly(bottom: 10),
          GetBuilder<HomeScreenController>(
            id: Constant.idGetListener,
            builder: (controller) {
              return controller.isLoading
                  ? const TopListenerShimmer()
                  : controller.topListenersModel?.data?.isEmpty == true
                      ? Image.asset(AppAsset.noListenerFound).paddingAll(50)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final visibleListeners =
                                controller.topListeners.toList();

                            Widget buildListenerItem(
                              TopListeners listener, {
                              double bottomMargin = 16,
                            }) {
                              return _buildListenerCard(
                                listener: listener,
                                bottomMargin: bottomMargin,
                                onViewProfile: () {
                                  Get.delete<ProfileDetailScreenController>();
                                  Get.toNamed(
                                    AppRoutes.profileDetailScreenView,
                                    arguments: listener.profileRouteArguments,
                                  );
                                },
                                onBookSession: () {
                                  if (!AuthGuard.requireLogin(
                                    message:
                                        'Please log in to book sessions with experts.',
                                  )) {
                                    return;
                                  }
                                  Get.toNamed(
                                    AppRoutes.userBookSessionScreen,
                                    arguments: listener.sessionBookingArguments,
                                  );
                                },
                              );
                            }

                            if (!isTabletScreen) {
                              return ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: visibleListeners.length,
                                itemBuilder: (context, index) {
                                  return buildListenerItem(
                                    visibleListeners[index],
                                  );
                                },
                              );
                            }

                            final columns =
                                constraints.maxWidth >= 1200 ? 3 : 2;
                            const spacing = 14.0;
                            final cardWidth = ((constraints.maxWidth -
                                        (spacing * (columns - 1))) /
                                    columns)
                                .clamp(280.0, 520.0)
                                .toDouble();

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (final listener in visibleListeners)
                                  SizedBox(
                                    width: cardWidth,
                                    child: buildListenerItem(
                                      listener,
                                      bottomMargin: 0,
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:notisboard/ui/user_flow/top_listeners_view_all/controller/top_listeners_view_all_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/auth_guard.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class TopListenersViewAllAppBar extends StatelessWidget {
  const TopListenersViewAllAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return Container(
      color: AppColors.redesignScreenBackground,
      padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 12),
      child: Row(
        children: [
          _HeaderActionButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: Get.back,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              EnumLocale.txtTopListener.name.tr,
              style: AppFontStyle.fontStyleW700(
                fontSize: isTablet ? 28 : 20,
                fontColor: AppColors.redesignBrandDark,
              ),
            ),
          ),
          _HeaderTrailingButton(
            onTap: () {
              Get.toNamed(AppRoutes.searchScreen);
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class _HeaderTrailingButton extends StatelessWidget {
  const _HeaderTrailingButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: AppColors.redesignSurfaceNeutralAlt,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            Icons.search_rounded,
            size: 19,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class TopListenersViewAllView extends StatelessWidget {
  const TopListenersViewAllView({super.key});

  Widget _summaryBanner({
    required int total,
    required bool isTablet,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 14,
        vertical: isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDark,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total Top Experts',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 16 : 14,
                    fontColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Discover and book sessions quickly',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: isTablet ? 12 : 11,
                    fontColor: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(double horizontalInset) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(horizontalInset, 22, horizontalInset, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Column(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.redesignScreenBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.groups_2_rounded,
                  color: AppColors.redesignBrandRed,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No experts found',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 18,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Top experts will appear here once available.',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 13,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopListenersViewAllController>(
      id: Constant.idGetListener,
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isTablet = width >= 760;
            final horizontalInset = width >= 1100
                ? 28.0
                : isTablet
                    ? 22.0
                    : 16.0;
            final columns = isTablet ? 2 : 1;
            const spacing = 14.0;
            final availableWidth =
                (width - (horizontalInset * 2)).clamp(0.0, double.infinity);
            final cardWidth = columns == 1
                ? availableWidth
                : ((availableWidth - (spacing * (columns - 1))) / columns)
                    .clamp(300.0, 560.0)
                    .toDouble();

            if (controller.isLoading) {
              return TopListenerShimmer()
                  .paddingSymmetric(horizontal: horizontalInset, vertical: 12);
            }

            return RefreshIndicator(
              onRefresh: () async => controller.onRefresh(),
              child: controller.topListeners.isEmpty
                  ? _emptyState(horizontalInset)
                  : ListView(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        horizontalInset,
                        10,
                        horizontalInset,
                        22,
                      ),
                      children: [
                        _summaryBanner(
                          total: controller.topListeners.length,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 14),
                        if (columns == 1)
                          ...controller.topListeners.map(
                            (listener) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TopExpertCard(
                                listener: listener,
                                onProfileTap: () {
                                  Get.toNamed(
                                    AppRoutes.profileDetailScreenView,
                                    arguments: listener.profileRouteArguments,
                                  );
                                },
                                onBookTap: () {
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
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: controller.topListeners
                                .map(
                                  (listener) => SizedBox(
                                    width: cardWidth,
                                    child: _TopExpertCard(
                                      listener: listener,
                                      onProfileTap: () {
                                        Get.toNamed(
                                          AppRoutes.profileDetailScreenView,
                                          arguments:
                                              listener.profileRouteArguments,
                                        );
                                      },
                                      onBookTap: () {
                                        if (!AuthGuard.requireLogin(
                                          message:
                                              'Please log in to book sessions with experts.',
                                        )) {
                                          return;
                                        }
                                        Get.toNamed(
                                          AppRoutes.userBookSessionScreen,
                                          arguments:
                                              listener.sessionBookingArguments,
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        GetBuilder<TopListenersViewAllController>(
                          id: Constant.idPaginationListener,
                          builder: (_) {
                            return controller.isPaginationLoading
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.redesignBrandRed,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
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

class _TopExpertCard extends StatelessWidget {
  const _TopExpertCard({
    required this.listener,
    required this.onProfileTap,
    required this.onBookTap,
  });

  final TopListeners listener;
  final VoidCallback onProfileTap;
  final VoidCallback onBookTap;

  Color _statusBackground(String status) {
    final value = status.trim().toLowerCase();
    if (value == 'available') {
      return AppColors.redesignStatusSuccess;
    }
    if (value == 'on call') {
      return AppColors.redesignBrandRed;
    }
    return AppColors.redesignSurfaceNeutral;
  }

  Color _statusTextColor(String status) {
    final value = status.trim().toLowerCase();
    if (value == 'available' || value == 'on call') {
      return AppColors.white;
    }
    return AppColors.redesignMutedText;
  }

  Widget _metaPill({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.redesignMutedText,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.redesignMutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: Text(
        label,
        style: AppFontStyle.fontStyleW500(
          fontSize: 10,
          fontColor: AppColors.redesignMutedText,
        ),
      ),
    );
  }

  Widget _buttonLabel({
    required String text,
    required Color color,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: AppFontStyle.fontStyleW600(
          fontSize: 14,
          fontColor: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = (listener.statusLabel ?? 'Offline').trim().isEmpty
        ? 'Offline'
        : listener.statusLabel!.trim();
    final isTablet = MediaQuery.sizeOf(context).width >= 760;
    final isCompact = MediaQuery.sizeOf(context).width < 420;
    final topics = (listener.talkTopics ?? const <String>[])
        .where((item) => item.trim().isNotEmpty)
        .toList();
    final visibleTopics = topics.take(3).toList();
    final remainingTopics = topics.length - visibleTopics.length;
    final language = (listener.language ?? const <String>[]).isEmpty
        ? 'Unknown'
        : listener.language!.first;
    final experience = (listener.experience ?? '').trim().isNotEmpty
        ? '${listener.experience} Exp'
        : '${listener.callCount ?? 0} Sessions';
    final name = (listener.name ?? 'Expert').trim().isEmpty
        ? 'Expert'
        : listener.name!.trim();
    final ageSuffix = listener.age == null ? '' : ', ${listener.age}';
    final isVerified = listener.isVerifiedBadge == true;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onProfileTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.redesignSoftBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              width: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    AppColors.redesignBrandRed,
                    AppColors.redesignBrandRed.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isTablet ? 90 : 80,
                  width: isTablet ? 90 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.redesignSurfaceNeutral,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CustomListenerProfileImage(
                    image: listener.image ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '$name$ageSuffix',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.fontStyleW700(
                                      fontSize: isTablet ? 20 : 18,
                                      fontColor: AppColors.redesignBrandDark,
                                    ),
                                  ),
                                ),
                                VerifiedBadge(
                                  isVerified: isVerified,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBackground(status),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 10,
                                fontColor: _statusTextColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _metaPill(
                            icon: Icons.language_rounded,
                            label: language,
                          ),
                          _metaPill(
                            icon: Icons.work_outline_rounded,
                            label: experience,
                          ),
                          if ((listener.uniqueId ?? '').trim().isNotEmpty)
                            _metaPill(
                              icon: Icons.badge_outlined,
                              label: listener.uniqueId!.trim(),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (visibleTopics.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...visibleTopics.map(_topicChip),
                  if (remainingTopics > 0) _topicChip('+$remainingTopics more'),
                ],
              ),
            ],
            const SizedBox(height: 14),
            if (isCompact)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: onProfileTap,
                      icon: const Icon(Icons.person_outline_rounded, size: 18),
                      label: _buttonLabel(
                        text: 'Profile',
                        color: AppColors.redesignBrandDark,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        side: BorderSide(color: AppColors.redesignSoftBorder),
                        foregroundColor: AppColors.redesignBrandDark,
                        backgroundColor: AppColors.redesignSurfaceSoft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: onBookTap,
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: _buttonLabel(
                        text: 'Book Session',
                        color: AppColors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        elevation: 0,
                        backgroundColor: AppColors.redesignBrandDark,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: onProfileTap,
                        icon:
                            const Icon(Icons.person_outline_rounded, size: 18),
                        label: _buttonLabel(
                          text: 'Profile',
                          color: AppColors.redesignBrandDark,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          side: BorderSide(color: AppColors.redesignSoftBorder),
                          foregroundColor: AppColors.redesignBrandDark,
                          backgroundColor: AppColors.redesignSurfaceSoft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: onBookTap,
                        icon:
                            const Icon(Icons.calendar_month_rounded, size: 18),
                        label: _buttonLabel(
                          text: 'Book Session',
                          color: AppColors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          elevation: 0,
                          backgroundColor: AppColors.redesignBrandDark,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

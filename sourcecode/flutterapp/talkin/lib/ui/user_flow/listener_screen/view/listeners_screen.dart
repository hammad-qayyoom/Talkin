import 'package:notisboard/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/dialog/exit_app_dialog.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:notisboard/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:notisboard/ui/user_flow/listener_screen/widget/listeners_screen_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/auth_guard.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/font_style.dart';

class ListenersScreen extends StatelessWidget {
  const ListenersScreen({super.key});

  static final Color _screenBackground = AppColors.redesignScreenBackground;
  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  Widget _buildEmptyState({required double horizontalInset}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalInset, 26, horizontalInset, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _softBorder),
          ),
          child: Column(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: _screenBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.groups_2_rounded,
                  color: _brandRed,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                EnumLocale.txtNoExpertsFound.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 18,
                  fontColor: _brandDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                EnumLocale.txtTryAnotherLanguageOrTalkTopicFilter.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 13,
                  fontColor: _mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpertsList({
    required BuildContext context,
    required ListenersScreenController controller,
    required double horizontalInset,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1240
            ? 3
            : width >= 760
                ? 2
                : 1;
        const spacing = 14.0;
        final availableWidth = width - (horizontalInset * 2);
        final cardWidth = columns == 1
            ? availableWidth
            : ((availableWidth - (spacing * (columns - 1))) / columns)
                .clamp(280.0, 520.0)
                .toDouble();

        final cards = controller.allListener
            .map(
              (listener) => _ExpertCard(
                listener: listener,
                onProfileTap: () {
                  Get.toNamed(
                    AppRoutes.profileDetailScreenView,
                    arguments: listener.profileRouteArguments,
                  );
                },
                onBookTap: () {
                  if (!AuthGuard.requireLogin(
                    message: 'Please log in to book sessions with experts.',
                  )) {
                    return;
                  }
                  Get.toNamed(
                    AppRoutes.userBookSessionScreen,
                    arguments: listener.sessionBookingArguments,
                  );
                },
              ),
            )
            .toList();

        return RefreshIndicator(
          color: _brandRed,
          backgroundColor: AppColors.white,
          onRefresh: () async => controller.onRefresh(),
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding:
                EdgeInsets.fromLTRB(horizontalInset, 0, horizontalInset, 20),
            children: [
              if (columns == 1)
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: card,
                  ),
                )
              else
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width: cardWidth,
                          child: card,
                        ),
                      )
                      .toList(),
                ),
              GetBuilder<ListenersScreenController>(
                id: Constant.idPaginationListener,
                builder: (logic) => Visibility(
                  visible: logic.isPaginationLoading,
                  child: Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Center(
                      child: CircularProgressIndicator(color: _brandRed),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || (Get.isDialogOpen ?? false)) {
          return;
        }

        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: AppColors.transparent,
            surfaceTintColor: AppColors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: _screenBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(132),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxContentWidth =
                  constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: maxContentWidth,
                  child: const ListenersAppBarView(),
                ),
              );
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, viewportConstraints) {
            final viewportWidth = viewportConstraints.maxWidth;
            final maxContentWidth =
                viewportWidth >= 760 ? 980.0 : viewportWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: GetBuilder<ListenersScreenController>(
                  id: Constant.idAllListener,
                  builder: (controller) {
                    return LayoutBuilder(
                      builder: (context, contentConstraints) {
                        final width = contentConstraints.maxWidth;
                        final horizontalInset = width >= 1100
                            ? 28.0
                            : width >= 760
                                ? 22.0
                                : 16.0;

                        return Column(
                          children: [
                            ListenersTopButtonView(
                              horizontalInset: horizontalInset,
                            ),
                            Expanded(
                              child: controller.isLoading
                                  ? TopListenerShimmer().paddingSymmetric(
                                      horizontal: horizontalInset,
                                      vertical: 8,
                                    )
                                  : controller.allListener.isEmpty
                                      ? _buildEmptyState(
                                          horizontalInset: horizontalInset,
                                        )
                                      : _buildExpertsList(
                                          context: context,
                                          controller: controller,
                                          horizontalInset: horizontalInset,
                                        ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final TopListeners listener;
  final VoidCallback onProfileTap;
  final VoidCallback onBookTap;

  const _ExpertCard({
    required this.listener,
    required this.onProfileTap,
    required this.onBookTap,
  });

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _chipSurface = AppColors.redesignSurfaceSoft;

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.redesignStatusSuccess;
      case 'on call':
        return _brandRed;
      default:
        return AppColors.redesignSurfaceNeutral;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'on call':
        return AppColors.white;
      default:
        return _mutedText;
    }
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _chipSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _mutedText),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _chipSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _softBorder),
      ),
      child: Text(
        label,
        style: AppFontStyle.fontStyleW500(
          fontSize: 10,
          fontColor: _mutedText,
        ),
      ),
    );
  }

  Widget _buildButtonLabel({
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
    final topics = (listener.talkTopics ?? [])
        .where((item) => item.trim().isNotEmpty)
        .toList();
    final visibleTopics = topics.take(3).toList();
    final remainingTopics = topics.length - visibleTopics.length;
    final name = listener.name ?? 'Expert';
    final language = (listener.language ?? []).isEmpty
        ? 'Unknown'
        : listener.language!.first;
    final rating = listener.rating ?? 0;
    final isVerified = listener.isVerifiedBadge == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final imageSize = isCompact ? 78.0 : 86.0;
        final titleFontSize = isCompact ? 18.0 : 22.0;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _softBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                        AppColors.redesignAccentGradientEnd
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onProfileTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        height: imageSize,
                        width: imageSize,
                        decoration: BoxDecoration(
                          color: AppColors.redesignAvatarSurface,
                          borderRadius: BorderRadius.circular(18),
                        ),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Text(
                                          name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFontStyle.fontStyleW700(
                                            fontSize: titleFontSize,
                                            fontColor: _brandDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      VerifiedBadge(
                                        isVerified: isVerified,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                if (rating > 0)
                                  _buildTag(
                                    label:
                                        '${rating.toStringAsFixed(1)} rating',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildMetaItem(
                                  icon: Icons.language_rounded,
                                  value: language,
                                ),
                                _buildMetaItem(
                                  icon: Icons.work_outline_rounded,
                                  value: '${listener.experience ?? '0'} Exp',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...visibleTopics.map((topic) => _buildTag(label: topic)),
                    if (remainingTopics > 0)
                      _buildTag(label: '+$remainingTopics more'),
                  ],
                ),
                const SizedBox(height: 14),
                if (isCompact)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: onProfileTap,
                          icon: const Icon(Icons.person_outline_rounded,
                              size: 18),
                          label: _buildButtonLabel(
                            text: 'Profile',
                            color: _brandDark,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            side: BorderSide(color: _softBorder),
                            foregroundColor: _brandDark,
                            backgroundColor: _chipSurface,
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
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                          ),
                          label: _buildButtonLabel(
                            text: 'Book Session',
                            color: AppColors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            elevation: 0,
                            backgroundColor: _brandDark,
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
                            icon: const Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                            ),
                            label: _buildButtonLabel(
                              text: 'Profile',
                              color: _brandDark,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              side: BorderSide(color: _softBorder),
                              foregroundColor: _brandDark,
                              backgroundColor: _chipSurface,
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
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                            ),
                            label: _buildButtonLabel(
                              text: 'Book Session',
                              color: AppColors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              elevation: 0,
                              backgroundColor: _brandDark,
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
      },
    );
  }
}

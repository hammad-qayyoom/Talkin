import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:notisboard/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:notisboard/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class TopListenerWidget extends StatelessWidget {
  const TopListenerWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDarkAlt;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _softSurface = AppColors.redesignSurfaceSoft;

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

  Widget _buildMetaItem({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _softSurface,
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
        color: _softSurface,
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

  Widget _buildListenerCard({
    required TopListeners listener,
    required VoidCallback onViewProfile,
    required VoidCallback onBookSession,
    double bottomMargin = 16,
  }) {
    final status = (listener.statusLabel ?? 'Offline').trim().isEmpty
        ? 'Offline'
        : listener.statusLabel!.trim();
    final topics =
        (listener.talkTopics ?? []).where((e) => e.trim().isNotEmpty).toList();
    final visibleTopics = topics.take(3).toList();
    final remainingTopics = topics.length - visibleTopics.length;
    final language = (listener.language ?? []).isEmpty
        ? 'Unknown'
        : listener.language!.first;
    final rating = listener.rating ?? 0;
    final name = listener.name ?? 'Expert';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final imageSize = isCompact ? 78.0 : 86.0;
        final titleFontSize = isCompact ? 18.0 : 22.0;

        return Container(
          margin: EdgeInsets.only(bottom: bottomMargin),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _softBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 18,
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
                  onTap: onViewProfile,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        height: imageSize,
                        width: imageSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppColors.redesignAvatarSurface,
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
                                const SizedBox(width: 8),
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: _softSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _softBorder),
                                  ),
                                  child: Icon(
                                    Icons.arrow_outward_rounded,
                                    size: 16,
                                    color: _brandDark,
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
                          onPressed: onViewProfile,
                          icon: const Icon(Icons.person_outline_rounded,
                              size: 18),
                          label: Text(
                            'Profile',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 14,
                              fontColor: _brandDark,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _softBorder),
                            foregroundColor: _brandDark,
                            backgroundColor: _softSurface,
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
                          onPressed: onBookSession,
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                          ),
                          label: Text(
                            'Book Session',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 14,
                              fontColor: AppColors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
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
                            onPressed: onViewProfile,
                            icon: const Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Profile',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 14,
                                fontColor: _brandDark,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _softBorder),
                              foregroundColor: _brandDark,
                              backgroundColor: _softSurface,
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
                            onPressed: onBookSession,
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Book Session',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 14,
                                fontColor: AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
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
    final titleSize = isLargeTabletScreen
        ? 34.0
        : isTabletScreen
            ? 30.0
            : 26.0;
    final viewAllSize = isTabletScreen ? 17.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  EnumLocale.txtTopListener.name.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: titleSize,
                    fontColor: _brandDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.topListenersViewAll,
                    arguments: {
                      'categoryId': homeController.selectedCategoryId,
                    },
                  );
                },
                child: Text(
                  EnumLocale.txtViewAll.name.tr,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: viewAllSize,
                    fontColor: _brandRed,
                  ),
                ),
              ),
            ],
          ).paddingOnly(bottom: 14),
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
                                controller.topListeners.take(4).toList();

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
                                    arguments: listener.id,
                                  );
                                },
                                onBookSession: () {
                                  Get.toNamed(
                                    AppRoutes.userBookSessionScreen,
                                    arguments: {
                                      'listenerId': listener.id ?? '',
                                      'listenerName': listener.name ?? '',
                                      'listenerImage': listener.image ?? '',
                                      'availableForPrivateAudioCall': listener
                                              .isAvailableForPrivateAudioCall ??
                                          false,
                                      'availableForPrivateVideoCall': listener
                                              .isAvailableForPrivateVideoCall ??
                                          false,
                                      'ratePrivateAudioCall':
                                          listener.ratePrivateAudioCall ?? 0,
                                      'ratePrivateVideoCall':
                                          listener.ratePrivateVideoCall ?? 0,
                                    },
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

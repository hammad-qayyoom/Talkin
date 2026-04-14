import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/notification_clear_dialog.dart';
import 'package:talk_in/ui/host_flow/host_notification/shimmer/notification_shimmer.dart';
import 'package:talk_in/ui/user_flow/user_notification/controller/user_notification_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class UserNotificationAppBar extends StatelessWidget {
  const UserNotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.redesignScreenBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: Get.back,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EnumLocale.txtNotification.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 22,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Updates about sessions and account activity',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              GetBuilder<UserNotificationController>(
                id: Constant.idUserNotification,
                builder: (controller) {
                  final hasNotifications =
                      controller.notificationList.isNotEmpty;

                  return IgnorePointer(
                    ignoring: !hasNotifications,
                    child: Opacity(
                      opacity: hasNotifications ? 1 : 0.55,
                      child: GestureDetector(
                        onTap: () {
                          Get.dialog(
                            barrierColor:
                                AppColors.black.withValues(alpha: 0.8),
                            Dialog(
                              backgroundColor: AppColors.transparent,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              elevation: 0,
                              child: NotificationClearDialog(
                                onConfirm: controller.clearNotificationUser,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.redesignSoftBorder),
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAsset.filterClearIcon,
                              height: 23,
                              width: 23,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
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
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class UserNotificationView extends StatelessWidget {
  const UserNotificationView({super.key});

  Color _categoryBackground(String title) {
    final value = title.trim().toLowerCase();
    if (value.contains('booked')) {
      return AppColors.redesignStatusInfoBg;
    }
    if (value.contains('settled')) {
      return AppColors.redesignStatusSuccessBg;
    }
    if (value.contains('reminder')) {
      return AppColors.redesignAccentSoftBg;
    }
    return AppColors.redesignSurfaceNeutral;
  }

  Color _categoryTextColor(String title) {
    final value = title.trim().toLowerCase();
    if (value.contains('booked')) {
      return AppColors.redesignStatusInfoText;
    }
    if (value.contains('settled')) {
      return AppColors.redesignStatusSuccessDark;
    }
    if (value.contains('reminder')) {
      return AppColors.redesignBrandRed;
    }
    return AppColors.redesignMutedText;
  }

  IconData _notificationIcon(String title) {
    final value = title.trim().toLowerCase();
    if (value.contains('booked')) {
      return Icons.event_available_outlined;
    }
    if (value.contains('settled')) {
      return Icons.currency_exchange_rounded;
    }
    if (value.contains('reminder')) {
      return Icons.notifications_active_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  Widget _summaryBanner(int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
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
                  '$totalCount Notifications',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 14,
                    fontColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Recent updates and alerts',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
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

  Widget _notificationCard({
    required String title,
    required String message,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: _categoryBackground(title),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _notificationIcon(title),
              size: 18,
              color: _categoryTextColor(title),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.isEmpty ? 'Notification' : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 18,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                    if (date.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 11,
                          fontColor: AppColors.redesignTextMeta,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 13,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserNotificationController>(
      id: Constant.idUserNotification,
      builder: (controller) {
        if (controller.isLoading) {
          return const Expanded(child: NotificationShimmer());
        }

        final notifications = controller.notificationList;

        if (notifications.isEmpty) {
          return Expanded(
            child: RefreshIndicator(
              color: AppColors.redesignBrandRed,
              backgroundColor: AppColors.white,
              onRefresh: controller.onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _summaryBanner(0),
                  const SizedBox(height: 50),
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 52,
                    color: AppColors.redesignSoftBorder,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Notifications',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 20,
                      fontColor: AppColors.redesignBrandDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your latest session and account updates will appear here.',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.redesignMutedText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Expanded(
          child: RefreshIndicator(
            color: AppColors.redesignBrandRed,
            backgroundColor: AppColors.white,
            onRefresh: controller.onRefresh,
            child: ListView.separated(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: notifications.length + 2,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _summaryBanner(notifications.length);
                }

                if (index == notifications.length + 1) {
                  return GetBuilder<UserNotificationController>(
                    id: Constant.idPaginationListener,
                    builder: (_) {
                      return controller.isPaginationLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  );
                }

                final item = notifications[index - 1];

                return _notificationCard(
                  title: item.title ?? '',
                  message: item.message ?? '',
                  date: item.date ?? '',
                );
              },
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/host_notification/controller/host_notification_controller.dart';
import 'package:notisboard/ui/host_flow/host_notification/shimmer/notification_shimmer.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class HostNotificationAppBar extends StatelessWidget {
  const HostNotificationAppBar({super.key});

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
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
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
                        fontSize: 19,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Updates about sessions and account activity',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 11,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              GetBuilder<HostNotificationController>(
                id: Constant.idUserNotification,
                builder: (controller) {
                  final hasNotifications =
                      controller.hostNotificationList.isNotEmpty;

                  return IgnorePointer(
                    ignoring: !hasNotifications,
                    child: Opacity(
                      opacity: hasNotifications ? 1 : 0.55,
                      child: GestureDetector(
                        onTap: () {
                          Utils.showConfirmationSnackBar(
                            context,
                            title: EnumLocale.txtNotification.name.tr,
                            message:
                                EnumLocale.txtSureClearNotification.name.tr,
                            confirmText: EnumLocale.txtSure.name.tr,
                            cancelText: EnumLocale.txtCancel.name.tr,
                            icon: Icons.notifications_active_outlined,
                            onConfirm: controller.clearNotificationListener,
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.redesignSoftBorder),
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAsset.filterClearIcon,
                              height: 21,
                              width: 21,
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
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class HostNotificationView extends StatelessWidget {
  const HostNotificationView({super.key});

  Color _categoryBackground(String title) {
    final value = title.trim().toLowerCase();
    if (value.contains('booked') || value.contains('booking')) {
      return AppColors.redesignStatusInfoBg;
    }
    if (value.contains('settled') || value.contains('withdrawal')) {
      return AppColors.redesignStatusSuccessBg;
    }
    if (value.contains('reminder')) {
      return AppColors.redesignAccentSoftBg;
    }
    return AppColors.redesignSurfaceNeutral;
  }

  Color _categoryTextColor(String title) {
    final value = title.trim().toLowerCase();
    if (value.contains('booked') || value.contains('booking')) {
      return AppColors.redesignStatusInfoText;
    }
    if (value.contains('settled') || value.contains('withdrawal')) {
      return AppColors.redesignStatusSuccessDark;
    }
    if (value.contains('reminder')) {
      return AppColors.redesignBrandRed;
    }
    return AppColors.redesignMutedText;
  }

  IconData _notificationIcon(String title) {
    final value = title.trim().toLowerCase();
    if (value.contains('booked') || value.contains('booking')) {
      return Icons.event_available_outlined;
    }
    if (value.contains('settled') || value.contains('withdrawal')) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.redesignBrandRed,
            AppColors.redesignBrandRedDark,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalCount Notifications',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 13,
                    fontColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Recent updates and alerts',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: _categoryBackground(title),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              _notificationIcon(title),
              size: 16,
              color: _categoryTextColor(title),
            ),
          ),
          const SizedBox(width: 8),
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
                          fontSize: 14,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                    if (date.trim().isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 10,
                          fontColor: AppColors.redesignTextMeta,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
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
    return GetBuilder<HostNotificationController>(
      id: Constant.idUserNotification,
      builder: (controller) {
        if (controller.isLoading) {
          return const Expanded(child: NotificationShimmer());
        }

        final notifications = controller.hostNotificationList;

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
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                children: [
                  _summaryBanner(0),
                  const SizedBox(height: 42),
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 44,
                    color: AppColors.redesignSoftBorder,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No Notifications',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 18,
                      fontColor: AppColors.redesignBrandDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your latest session and account updates will appear here.',
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 11,
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              itemCount: notifications.length + 2,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _summaryBanner(notifications.length);
                }

                if (index == notifications.length + 1) {
                  return GetBuilder<HostNotificationController>(
                    id: Constant.idPaginationListener,
                    builder: (_) {
                      return controller.isPaginationLoading
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.redesignBrandRed,
                                ),
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

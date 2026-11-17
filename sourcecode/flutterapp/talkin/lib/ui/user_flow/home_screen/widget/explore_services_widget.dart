import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class ExploreServicesWidget extends StatelessWidget {
  const ExploreServicesWidget({super.key});

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  void _onServiceTap(BuildContext context, String serviceName, int? navIndex) {
    if (navIndex != null && Get.isRegistered<BottomBarController>()) {
      final bottomBar = Get.find<BottomBarController>();
      bottomBar.selectIndex = navIndex;
      bottomBar.update([Constant.idBottomBar]);
      return;
    }

    Utils.showToast(context, '$serviceName is coming soon to the app!');
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isTablet = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 12 : 9,
            horizontal: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _softBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: isTablet ? 38 : 32,
                width: isTablet ? 38 : 32,
                decoration: BoxDecoration(
                  color: _brandRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: _brandRed,
                  size: isTablet ? 20 : 18,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: isTablet ? 12 : 11,
                    fontColor: _brandDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 760;
    final isLargeTablet = screenWidth >= 1100;
    final horizontalInset = isLargeTablet
        ? 28.0
        : isTablet
            ? 22.0
            : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalInset, 6, horizontalInset, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Explore Services',
                style: AppFontStyle.fontStyleW700(
                  fontSize: isTablet ? 20 : 16.5,
                  fontColor: _brandDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (Get.isRegistered<BottomBarController>()) {
                    final bottomBar = Get.find<BottomBarController>();
                    bottomBar.selectIndex = 2; // Experts/Listeners tab
                    bottomBar.update([Constant.idBottomBar]);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: isTablet ? 13.5 : 12,
                        fontColor: _brandRed,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _brandRed,
                      size: isTablet ? 15 : 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceCard(
                context: context,
                icon: Icons.people_outline_rounded,
                label: 'Experts',
                isTablet: isTablet,
                onTap: () => _onServiceTap(context, 'Experts', 2),
              ),
              _buildServiceCard(
                context: context,
                icon: Icons.calendar_today_outlined,
                label: 'Events',
                isTablet: isTablet,
                onTap: () => _onServiceTap(context, 'Events', null),
              ),
              _buildServiceCard(
                context: context,
                icon: Icons.volunteer_activism_outlined,
                label: 'Fundraising',
                isTablet: isTablet,
                onTap: () => _onServiceTap(context, 'Fundraising', null),
              ),
              _buildServiceCard(
                context: context,
                icon: Icons.shopping_bag_outlined,
                label: 'Shop',
                isTablet: isTablet,
                onTap: () => _onServiceTap(context, 'Shop', null),
              ),
              _buildServiceCard(
                context: context,
                icon: Icons.all_inbox_rounded,
                label: 'Food Bank',
                isTablet: isTablet,
                onTap: () => _onServiceTap(context, 'Food Bank', null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


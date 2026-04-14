import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/report_block_ui_bottom_sheet.dart';
import 'package:talk_in/custom/bottom_sheet/report_bottom_sheet.dart';
import 'package:talk_in/custom/dialog/block_dialog.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/shimmer/profile_detail_shimmer.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/widget/profile_detail_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class ProfileDetailScreenView extends StatelessWidget {
  const ProfileDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      bottomNavigationBar: const ProfileBottomButtonView(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth = constraints.maxWidth >= 1400
                ? 1180.0
                : constraints.maxWidth >= 760
                    ? 920.0
                    : constraints.maxWidth;

            return Stack(
              children: [
                Positioned.fill(
                  child: GetBuilder<ProfileDetailScreenController>(
                    id: Constant.listenerProfile,
                    builder: (controller) {
                      return RefreshIndicator(
                        color: AppColors.redesignBrandRed,
                        backgroundColor: AppColors.white,
                        onRefresh: controller.onRefresh,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.only(
                                bottom: controller.isLoading ? 12 : 112,
                              ),
                              children: [
                                controller.isLoading
                                    ? const ProfileDetailShimmer()
                                    : const _ProfileDetailContent(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 12,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _TopFloatingActions(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileDetailContent extends StatelessWidget {
  const _ProfileDetailContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TopImageView(),
        Transform.translate(
          offset: const Offset(0, -24),
          child: const Column(
            children: [
              UserProfileInfoView(),
              StatusView(),
              ReviewShow(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopFloatingActions extends StatelessWidget {
  const _TopFloatingActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: Get.back,
        ),
        const Spacer(),
        _ActionIconButton(
          icon: Icons.more_horiz_rounded,
          onTap: () {
            showMoreOptionsBottomSheet(
              context: context,
              isHost: Database.isListener,
              userId: Database.loginUserId,
              onBlock: () {
                Get.dialog(
                  barrierColor: AppColors.black.withValues(alpha: 0.8),
                  Dialog(
                    backgroundColor: AppColors.transparent,
                    shadowColor: AppColors.transparent,
                    surfaceTintColor: AppColors.transparent,
                    elevation: 0,
                    child: BlockDialog(
                      hostId: '',
                      isHost: Database.isListener,
                      userId: Database.loginUserId,
                    ),
                  ),
                );
              },
              onReport: () {
                final profileController =
                    Get.find<ProfileDetailScreenController>();
                ReportBottomSheetUi.show(
                  context: context,
                  reportType: 'user',
                  targetId: profileController.listenerId ?? '',
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
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
            color: AppColors.white.withValues(alpha: 0.88),
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

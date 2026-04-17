import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/dialog/exit_app_dialog.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:notisboard/ui/host_flow/host_home_screen/widget/host_home_screen_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/utils.dart';

class HostHomeScreen extends GetView<HostHomeScreenController> {
  const HostHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.redesignScreenBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width >= 1200
                ? 28.0
                : width >= 760
                    ? 22.0
                    : 16.0;
            final maxContentWidth = width >= 760 ? 980.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: GetBuilder<HostHomeScreenController>(
                  builder: (controller) {
                    return RefreshIndicator(
                      color: AppColors.redesignBrandRed,
                      backgroundColor: AppColors.white,
                      onRefresh: () async => controller.onRefresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: const HostTopHomeView(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: const HostImageView(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: horizontalPadding,
                                right: horizontalPadding,
                                top: 16,
                              ),
                              child: const PermissionView(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: const HostStatisticsCard(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                0,
                                horizontalPadding,
                                28,
                              ),
                              child: const NoteView(),
                            ),
                          ),
                        ],
                      ),
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

// canPop: false,
// onPopInvoked: (bool didPop) {
// // Get.dialog(
// //   barrierColor: AppColors.black.withValues(alpha: 0.8),
// //   Dialog(
// //     backgroundColor: AppColors.transparent,
// //     shadowColor: Colors.transparent,
// //     surfaceTintColor: Colors.transparent,
// //     elevation: 0,
// //     child: const ExitAppDialog(),
// //   ),
// // );
// if (didPop) {
// return;
// }
// },

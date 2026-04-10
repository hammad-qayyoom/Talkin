import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/find_more_widget.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/home_app_bar_widget.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/top_listener_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

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
            shadowColor: AppColors.transparent,
            surfaceTintColor: AppColors.transparent,
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
            final maxContentWidth = width >= 1400 ? 1280.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: GetBuilder<HomeScreenController>(
                  id: Constant.idGetListener,
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
                            child: HomeAppBarWidget().paddingSymmetric(
                              horizontal: horizontalPadding,
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: FindMoreWidget(),
                          ),
                          const SliverToBoxAdapter(
                            child: TopListenerWidget(),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 12),
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

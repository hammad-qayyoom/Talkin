import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/dialog/exit_app_dialog.dart';
import 'package:notisboard/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:notisboard/ui/user_flow/home_screen/widget/explore_services_widget.dart';
import 'package:notisboard/ui/user_flow/home_screen/widget/find_more_widget.dart';
import 'package:notisboard/ui/user_flow/home_screen/widget/food_bank_banner_widget.dart';
import 'package:notisboard/ui/user_flow/home_screen/widget/home_app_bar_widget.dart';
import 'package:notisboard/ui/user_flow/home_screen/widget/top_listener_widget.dart';
import 'package:notisboard/ui/user_flow/home_screen/widget/upcoming_events_widget.dart';
import 'package:notisboard/ui/user_flow/home_screen/widget/user_growth_spotlight_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/utils.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

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
                child: GetBuilder<HomeScreenController>(
                  id: Constant.idGetListener,
                  builder: (controller) {
                    return RefreshIndicator(
                      color: AppColors.redesignBrandRed,
                      backgroundColor: AppColors.white,
                      onRefresh: () async => controller.onRefresh(),
                      child: CustomScrollView(
                        controller: controller.scrollController,
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
                            child: ExploreServicesWidget(),
                          ),
                          const SliverToBoxAdapter(
                            child: UserGrowthSpotlightWidget(),
                          ),
                          const SliverToBoxAdapter(
                            child: FoodBankBannerWidget(),
                          ),
                          const SliverToBoxAdapter(
                            child: FindMoreWidget(),
                          ),
                          const SliverToBoxAdapter(
                            child: TopListenerWidget(),
                          ),
                          const SliverToBoxAdapter(
                            child: UpcomingEventsWidget(),
                          ),
                          GetBuilder<HomeScreenController>(
                            id: Constant.idPaginationListener,
                            builder: (controller) {
                              if (controller.isPaginationLoading) {
                                return SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.redesignBrandRed,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SliverToBoxAdapter(
                                child: SizedBox(height: 12),
                              );
                            },
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

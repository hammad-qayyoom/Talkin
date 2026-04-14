import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/coin_plan_widget.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/my_wallet_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class MyWalletScreen extends GetView<MyWalletController> {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: GetBuilder<MyWalletController>(builder: (controller) {
        return SafeArea(
          child: Column(
            children: [
              const MyWalletScreenAppBar(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxContentWidth = constraints.maxWidth >= 1100
                        ? 980.0
                        : constraints.maxWidth >= 760
                            ? 760.0
                            : constraints.maxWidth;

                    return RefreshIndicator(
                      color: AppColors.redesignBrandRed,
                      backgroundColor: AppColors.white,
                      onRefresh: () async {
                        await controller.onRefresh();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: maxContentWidth),
                            child: const Column(
                              children: [
                                MyWalletScreenTopView(),
                                SizedBox(height: 12),
                                CoinPlanWidget(),
                                SizedBox(height: 12),
                                WalletGuideView(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/dialog/exit_app_dialog.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/host_flow/host_wallet_screen/controller/host_wallet_screen_controller.dart';
import 'package:notisboard/ui/host_flow/host_wallet_screen/widget/host_wallet_screen_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class HostWalletScreen extends StatefulWidget {
  const HostWalletScreen({super.key});

  @override
  State<HostWalletScreen> createState() => _HostWalletScreenState();
}

class _HostWalletScreenState extends State<HostWalletScreen> {
  final HostWalletScreenController hostWalletScreenController =
      Get.put(HostWalletScreenController());

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
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.redesignScreenBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxContentWidth =
                  constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    children: [
                      const HostWalletScreenAppBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          child: Column(
                            children: [
                              const HostWalletScreenTopView(),
                              const SizedBox(height: 12),
                              const WithdrawCoinView(),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => Get.toNamed(AppRoutes.hostBoostScreen),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.redesignBrandRed.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.redesignBrandRed.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.rocket_launch_rounded,
                                        color: AppColors.redesignBrandRed,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Boost Your Profile',
                                              style: TextStyle(
                                                color: AppColors.redesignBrandRed,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              'Use your wallet balance to get more visibility',
                                              style: TextStyle(
                                                color: AppColors.redesignMutedText,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.redesignBrandRed.withValues(alpha: 0.6),
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              BottomView(
                                controller: hostWalletScreenController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

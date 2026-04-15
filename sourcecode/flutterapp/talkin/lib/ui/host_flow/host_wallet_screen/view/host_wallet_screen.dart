import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/ui/host_flow/host_wallet_screen/controller/host_wallet_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_wallet_screen/widget/host_wallet_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

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
    final width = MediaQuery.sizeOf(context).width;
    final maxContentWidth = width >= 1100
        ? 980.0
        : width >= 760
            ? 760.0
            : width;

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
        body: SafeArea(
          child: Column(
            children: [
              const HostWalletScreenAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Column(
                        children: [
                          const HostWalletScreenTopView(),
                          const SizedBox(height: 12),
                          const WithdrawCoinView(),
                          const SizedBox(height: 12),
                          BottomView(
                            controller: hostWalletScreenController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

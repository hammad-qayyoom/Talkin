import 'package:flutter/material.dart';
import 'package:notisboard/ui/host_flow/host_withdraw_coin_screen/widget/host_withdraw_coin_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class HostWithdrawCoinScreen extends StatelessWidget {
  const HostWithdrawCoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxContentWidth = width >= 1100
        ? 980.0
        : width >= 760
            ? 760.0
            : width;

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: const Column(
                children: [
                  HostWithdrawCoinAppBar(),
                  SizedBox(height: 12),
                  HostWithdrawCoinTopView(),
                  SizedBox(height: 12),
                  HostWithdrawCoinView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

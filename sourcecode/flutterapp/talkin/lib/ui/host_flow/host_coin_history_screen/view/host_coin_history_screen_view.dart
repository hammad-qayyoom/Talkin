import 'package:flutter/material.dart';
import 'package:notisboard/ui/host_flow/host_coin_history_screen/widget/host_coin_history_screen_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class HostCoinHistoryScreen extends StatelessWidget {
  const HostCoinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.lightPurple,
        automaticallyImplyLeading: false,
        flexibleSpace: const HostCoinHistoryScreenAppBar(),
      ),
      body: Column(
        children: [
          HostCoinHistoryScreenTabBar(),
          HostCoinHistoryScreenTabBarScreen(),
        ],
      ),
    );
  }
}

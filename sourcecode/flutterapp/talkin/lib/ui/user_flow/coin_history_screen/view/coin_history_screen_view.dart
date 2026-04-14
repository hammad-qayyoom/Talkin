import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/widget/coin_history_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class CoinHistoryScreen extends StatelessWidget {
  const CoinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        child: Column(
          children: const [
            CoinHistoryScreenAppBar(),
            CoinHistoryScreenTabBar(),
            CoinHistoryScreenTabBarScreen(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/setting_screen/widget/setting_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        child: Column(
          children: const [
            SettingScreenAppBar(),
            Expanded(
              child: SettingView(),
            ),
          ],
        ),
      ),
    );
  }
}

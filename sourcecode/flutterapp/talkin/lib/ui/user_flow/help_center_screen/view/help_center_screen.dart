import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/widget/help_center_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        child: Column(
          children: const [
            HelpCenterAppBar(),
            Expanded(
              child: HelpCenterScreenView(),
            ),
          ],
        ),
      ),
    );
  }
}

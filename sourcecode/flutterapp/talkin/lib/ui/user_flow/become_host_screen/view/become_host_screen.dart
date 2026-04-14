import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/widget/become_host_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class BecomeHostScreen extends StatelessWidget {
  const BecomeHostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        child: Column(
          children: const [
            BecomeHostScreenAppBar(),
            Expanded(
              child: BecomeHostScreenView(),
            ),
          ],
        ),
      ),
    );
  }
}

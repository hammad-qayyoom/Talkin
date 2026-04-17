import 'package:flutter/material.dart';
import 'package:notisboard/ui/user_flow/my_profile_screen/widget/my_profile_screen_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/utils.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth =
                constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: const Column(
                  children: [
                    MyProfileTopView(),
                    Expanded(
                      child: ProfileOptionsView(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

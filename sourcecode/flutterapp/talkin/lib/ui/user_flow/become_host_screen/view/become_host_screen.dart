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
                    BecomeHostScreenAppBar(),
                    Expanded(
                      child: BecomeHostScreenView(),
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

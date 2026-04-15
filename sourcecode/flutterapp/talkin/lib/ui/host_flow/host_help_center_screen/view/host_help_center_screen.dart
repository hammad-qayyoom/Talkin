import 'package:flutter/material.dart';
import 'package:talk_in/ui/host_flow/host_help_center_screen/widget/host_help_center_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostHelpCenterScreen extends StatelessWidget {
  const HostHelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HostHelpCenterAppBar(),
                    Expanded(child: HostHelpCenterView()),
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

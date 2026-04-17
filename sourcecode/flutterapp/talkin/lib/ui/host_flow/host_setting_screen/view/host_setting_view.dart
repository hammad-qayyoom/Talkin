import 'package:flutter/material.dart';
import 'package:notisboard/ui/host_flow/host_setting_screen/widget/host_setting_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/utils.dart';

class HostSettingScreen extends StatelessWidget {
  const HostSettingScreen({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HostSettingScreenAppBar(),
                    Expanded(child: HostSettingView()),
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

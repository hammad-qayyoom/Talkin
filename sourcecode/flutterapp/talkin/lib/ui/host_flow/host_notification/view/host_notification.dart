import 'package:flutter/material.dart';
import 'package:talk_in/ui/host_flow/host_notification/widget/host_notification_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostNotificationScreen extends StatelessWidget {
  const HostNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxContentWidth = width >= 760 ? 980.0 : width;

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(88),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: const HostNotificationAppBar(),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: const Column(
              children: [
                HostNotificationView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

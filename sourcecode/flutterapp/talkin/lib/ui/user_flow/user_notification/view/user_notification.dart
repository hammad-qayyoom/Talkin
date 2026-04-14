import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/user_notification/widget/user_notification_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class UserNotificationScreen extends StatelessWidget {
  const UserNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(96),
        child: UserNotificationAppBar(),
      ),
      body: const SafeArea(
        top: false,
        child: Column(
          children: [
            UserNotificationView(),
          ],
        ),
      ),
    );
  }
}

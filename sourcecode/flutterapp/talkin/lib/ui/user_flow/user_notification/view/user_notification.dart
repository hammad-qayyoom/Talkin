import 'package:flutter/material.dart';
import 'package:notisboard/ui/user_flow/user_notification/widget/user_notification_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class UserNotificationScreen extends StatelessWidget {
  const UserNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(96),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth =
                constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: maxContentWidth,
                child: const UserNotificationAppBar(),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth =
                constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: maxContentWidth,
                child: const Column(
                  children: [
                    UserNotificationView(),
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

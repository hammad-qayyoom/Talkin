import 'package:flutter/material.dart';
import 'package:notisboard/ui/user_flow/incoming_call_screen/widget/incoming_call_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: const IncomingCallView(),
      ),
    );
  }
}

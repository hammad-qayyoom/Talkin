import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fake_outgoing_call_screen/controller/fake_outgoing_call_controller.dart';
import 'package:notisboard/ui/user_flow/fake_outgoing_call_screen/widget/fake_outgoing_call_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/utils.dart';

class FakeOutgoingCallScreen extends StatelessWidget {
  const FakeOutgoingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder<FakeOutgoingCallController>(
            id: Constant.idVideoCall,
            builder: (controller) {
              Utils.showLog(
                  'controller.callType  ////////////${controller.callType}');
              return controller.callType == 'audio'
                  ? const FakeAudioOutgoingCallView()
                  : const FakeOutgoingCallView();
              // return controller.callType == 'audio' ? const FakeAudioOutgoingCallView() : const FakeOutgoingCallView();
            }),
      ),
    );
  }
}

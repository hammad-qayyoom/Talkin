import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/host_verification_listeners_detail_screen/widget/host_verification_listeners_detail_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostVerificationListenersDetailScreen extends StatelessWidget {
  const HostVerificationListenersDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(96),
        child: HostVerificationListenersDetailAppBar(),
      ),
      bottomNavigationBar: const HostVerificationListenersDetailBottomButton(),
      body: GestureDetector(
        onTap: () {
          final FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: const Column(
              children: [
                HostVerificationListenersDetailView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

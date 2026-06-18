import 'package:flutter/material.dart';
import 'package:notisboard/ui/host_flow/manual_verification_screen/widget/manual_verification_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/utils.dart';

class ManualVerificationScreen extends StatelessWidget {
  const ManualVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(76),
        child: ManualVerificationAppBar(),
      ),
      body: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final maxContentWidth = screenWidth >= 760 ? 980.0 : double.infinity;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: GestureDetector(
                onTap: () {
                  final currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus &&
                      currentFocus.focusedChild != null) {
                    currentFocus.focusedChild?.unfocus();
                  }
                },
                child: SafeArea(
                  top: false,
                  child: const ManualVerificationBody(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/widget/host_verification_widget.dart';
import 'package:notisboard/utils/app_color.dart';

class HostVerificationScreen extends StatelessWidget {
  const HostVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HostVerificationBottomButton(),
      backgroundColor: AppColors.redesignScreenBackground,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(76),
        child: HostVerificationAppBar(),
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
                        HostVerificationUploadImageView(),
                        SizedBox(height: 12),
                        HostVerificationFillFormView(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

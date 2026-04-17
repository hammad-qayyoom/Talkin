import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/fill_profile_screen/widget/fill_profile_screen_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/utils.dart';

class FillProfileScreen extends StatelessWidget {
  const FillProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Utils.showToast(
              Get.context!, EnumLocale.txtPleaseFillProfile.name.tr);
        }
      },
      child: Scaffold(
        bottomNavigationBar: saveProfileButton(),
        backgroundColor: AppColors.redesignScreenBackground,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild?.unfocus();
            }
          },
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxContentWidth =
                    constraints.maxWidth >= 760 ? 980.0 : constraints.maxWidth;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -110,
                          right: -80,
                          child: Container(
                            height: 260,
                            width: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.redesignBrandRed
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 210,
                          left: -120,
                          child: Container(
                            height: 250,
                            width: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.redesignBrandDark
                                  .withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            const FillProfileScreenAppBar(),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 22),
                                child: const Column(
                                  children: [
                                    FillProfileImageView(),
                                    SizedBox(height: 12),
                                    FillProfileEditInfoView(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

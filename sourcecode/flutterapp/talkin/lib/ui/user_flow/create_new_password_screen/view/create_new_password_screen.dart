import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_background/app_background.dart';
import 'package:notisboard/ui/user_flow/create_new_password_screen/widget/create_new_password_widget.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const CreateNewPasswordAppBar(),
      ),
      body: AppBackground(
        child: Column(
          children: [
            CreateNewPasswordDescriptionView(),
            Spacer(),
            CreateNewPasswordButtonView(),
            Spacer(),
          ],
        ).paddingOnly(left: 18, right: 18, top: 18),
      ),
    );
  }
}

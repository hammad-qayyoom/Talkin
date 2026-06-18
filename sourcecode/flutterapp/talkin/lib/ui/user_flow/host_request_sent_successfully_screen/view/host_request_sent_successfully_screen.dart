import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';
import 'package:notisboard/ui/user_flow/host_request_sent_successfully_screen/controller/host_request_sent_successfully_controller.dart';
import 'package:notisboard/ui/user_flow/host_request_sent_successfully_screen/widget/host_request_successfully_widget.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';

class HostRequestSentSuccessfullyScreen
    extends GetView<HostRequestSentSuccessfullyController> {
  const HostRequestSentSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      bottomNavigationBar: GetBuilder<BecomeHostScreenController>(
        builder: (controller) {
          final isRejected =
              controller.listenersRequestCheckModel?.data?.status == 3;

          return BackHomeButton(
            showTryAgain: isRejected,
            tryAgainOnTap: () {
              Get.toNamed(AppRoutes.hostVerificationScreen);
            },
            onTap: () {
              if (controller.listenersRequestCheckModel?.data?.status == 2) {
                Database.onSetIsListener(true);
                log("Database.isListeners :: ${Database.isListeners}");
                Get.offAllNamed(AppRoutes.splashScreenPage);
              } else {
                Get.toNamed(AppRoutes.bottomBar);
              }
            },
          );
        },
      ),
      body: GetBuilder<BecomeHostScreenController>(builder: (controller) {
        final maxContentWidth =
            MediaQuery.sizeOf(context).width >= 760 ? 980.0 : double.infinity;

        return RefreshIndicator(
          onRefresh: () => controller.onRefresh(),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: const Column(
                  children: [
                    TopView(),
                    InfoView(),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

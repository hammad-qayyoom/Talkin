import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/ui/host_flow/manual_verification_screen/controller/manual_verification_controller.dart';
import 'package:notisboard/ui/host_flow/manual_verification_screen/model/verification_status_model.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class ManualVerificationAppBar extends StatelessWidget {
  const ManualVerificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      color: AppColors.redesignScreenBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: Get.back,
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.redesignSoftBorder),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppColors.redesignBrandDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Blue Tick Verification',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: screenWidth >= 760 ? 28 : 20,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManualVerificationBody extends StatelessWidget {
  const ManualVerificationBody({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManualVerificationController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.redesignMutedText),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 14,
                      fontColor: AppColors.redesignMutedText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryAppButton(
                    onTap: () => controller.fetchVerificationStatus(),
                    height: 40,
                    color: AppColors.redesignBrandRed,
                    borderColor: AppColors.redesignBrandRed,
                    child: Text(
                      'Retry',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final statusData = controller.verificationStatusData.value;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AutoVerificationSection(statusData),
              const SizedBox(height: 20),
              _ManualVerificationSection(controller, statusData),
            ],
          ),
        );
      },
    );
  }
}

class _AutoVerificationSection extends StatelessWidget {
  const _AutoVerificationSection(this.statusData);
  final VerificationStatusData? statusData;

  @override
  Widget build(BuildContext context) {
    final sessionsRemaining = statusData?.sessionsRemaining ?? 0;
    final threshold = statusData?.autoBadgeThreshold ?? 0;
    final completed = statusData?.completedSessions ?? 0;
    final isEnabled = statusData?.autoBadgeEnabled ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Automatic Blue Tick',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              if (statusData?.isVerifiedBadge == true &&
                  statusData?.verifiedBadgeType == 'auto_sessions')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Earned',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 11,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isEnabled)
            Text(
              'Automatic verification is currently disabled by admin.',
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.redesignMutedText,
              ),
            )
          else ...[
            Text(
              'Complete $threshold sessions to get the blue tick automatically. You have completed $completed sessions so far.',
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
            const SizedBox(height: 12),
            if (sessionsRemaining > 0) ...[
              LinearProgressIndicator(
                value: threshold > 0 ? completed / threshold : 0,
                backgroundColor: AppColors.redesignSoftBorder,
                color: AppColors.redesignBrandRed,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '$sessionsRemaining more session${sessionsRemaining == 1 ? '' : 's'} needed',
                style: AppFontStyle.fontStyleW600(
                  fontSize: 12,
                  fontColor: AppColors.redesignMutedText,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ManualVerificationSection extends StatelessWidget {
  const _ManualVerificationSection(this.controller, this.statusData);
  final ManualVerificationController controller;
  final VerificationStatusData? statusData;

  @override
  Widget build(BuildContext context) {
    final isPending = statusData?.isManuallyPending ?? false;
    final isApproved = statusData?.isManuallyApproved ?? false;
    final isRejected = statusData?.isManuallyRejected ?? false;
    final isNotApplied = statusData?.isNotApplied ?? false;
    final alreadyVerified = statusData?.isVerifiedBadge == true &&
        statusData?.verifiedBadgeType == 'manual';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.redesignBrandRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 20,
                  color: AppColors.redesignBrandRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Manual Blue Tick',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Under Review',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 11,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              if (isApproved || alreadyVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Verified',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 11,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              if (isRejected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Rejected',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 11,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isNotApplied) ...[
            Text(
              'Celebrities and public figures can apply for a blue tick by submitting evidence documents. Admin will review and approve manually.',
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.redesignMutedText,
              ),
            ),
            const SizedBox(height: 16),
            _DocumentUploadSection(controller),
            const SizedBox(height: 16),
            _SubmitButton(controller),
            if (controller.submitMessage.value.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SubmitMessage(controller),
            ],
          ] else if (isPending) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_bottom_rounded,
                    size: 20,
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your verification request is under review. Admin will respond within a few days.',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 13,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isRejected) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.red.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cancel_rounded,
                        size: 20,
                        color: AppColors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your verification was rejected.',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.redesignBrandDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((statusData?.manualVerificationRejectionReason ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Reason: ${statusData!.manualVerificationRejectionReason}',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 13,
                        fontColor: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'You can submit new documents for re-verification.',
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.redesignMutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DocumentUploadSection(controller),
                  const SizedBox(height: 16),
                  _SubmitButton(controller),
                  if (controller.submitMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SubmitMessage(controller),
                  ],
                ],
              ),
            ),
          ] else if (isApproved || alreadyVerified) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: AppColors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are verified with a manual blue tick.',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 13,
                        fontColor: AppColors.redesignBrandDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentUploadSection extends StatelessWidget {
  const _DocumentUploadSection(this.controller);
  final ManualVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents (PDF, JPG, PNG)',
          style: AppFontStyle.fontStyleW600(
            fontSize: 13,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Up to ${ManualVerificationController.maxFiles} files. You are sharing this with the admin for review purposes.',
          style: AppFontStyle.fontStyleW500(
            fontSize: 11,
            fontColor: AppColors.redesignMutedText,
          ),
        ),
        const SizedBox(height: 10),
        if (controller.selectedFiles.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(controller.selectedFiles.length, (index) {
              final file = controller.selectedFiles[index];
              final fileName = file.path.split('/').last;
              return Chip(
                avatar: Icon(
                  fileName.endsWith('.pdf')
                      ? Icons.picture_as_pdf_rounded
                      : Icons.image_rounded,
                  size: 16,
                ),
                label: Text(
                  fileName,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => controller.removeFile(index),
              );
            }),
          ),
          const SizedBox(height: 10),
        ],
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: controller.selectedFiles.length >= ManualVerificationController.maxFiles
                ? null
                : controller.pickFiles,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.redesignSoftBorder,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.redesignSurfaceSoft,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: AppColors.redesignMutedText,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to select files',
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 13,
                      fontColor: AppColors.redesignMutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton(this.controller);
  final ManualVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PrimaryAppButton(
        onTap: controller.isSubmitting.value ? null : controller.submitVerification,
        height: 48,
        color: AppColors.redesignBrandRed,
        borderColor: AppColors.redesignBrandRed,
        child: Center(
          child: controller.isSubmitting.value
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Submit for Review',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 15,
                    fontColor: AppColors.white,
                  ),
                ),
        ),
      );
    });
  }
}

class _SubmitMessage extends StatelessWidget {
  const _SubmitMessage(this.controller);
  final ManualVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final success = controller.submitSuccess.value;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: success
              ? AppColors.redesignStatusSuccess.withValues(alpha: 0.08)
              : AppColors.redesignBrandRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: success
                ? AppColors.redesignStatusSuccess.withValues(alpha: 0.25)
                : AppColors.redesignBrandRed.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              size: 20,
              color: success
                  ? AppColors.redesignStatusSuccess
                  : AppColors.redesignBrandRed,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.submitMessage.value,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 13,
                  fontColor: AppColors.redesignBrandDark,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

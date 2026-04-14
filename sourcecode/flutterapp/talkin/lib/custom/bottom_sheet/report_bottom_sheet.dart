import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:talk_in/custom/bottom_sheet/api/moderation_report_api.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class ReportBottomSheetUi {
  static RxInt selectedReportType = 0.obs;

  static RxBool isLoading = false.obs;

  static const List<String> reportReasonCodes = [
    'spam',
    'nudity_or_sexual_activity',
    'hate_speech_or_symbols',
    'violence_or_dangerous_organization',
    'false_information',
    'bullying_or_harassment',
    'scam_or_fraud',
    'intellectual_property_violation',
    'suicide_or_self_injury',
    'drugs',
    'eating_disorders',
    'something_else',
    'child_abuse',
    'others',
  ];

  // static List<Data> reportTypes = [];
  static List reportTypes = [
    EnumLocale.txtItIsSpam.name.tr,
    EnumLocale.txtNudityOrSexualActivity.name.tr,
    EnumLocale.txtHateSpeechOrSymbols.name.tr,
    EnumLocale.txtViolenceOrDangerousOrganization.name.tr,
    EnumLocale.txtFalseInformation.name.tr,
    EnumLocale.txtBullyingOrHarassment.name.tr,
    EnumLocale.txtScamOrFraud.name.tr,
    EnumLocale.txtIntellectualPropertyViolation.name.tr,
    EnumLocale.txtSuicideOrSelfInjury.name.tr,
    EnumLocale.txtDrugs.name.tr,
    EnumLocale.txtEatingDisorders.name.tr,
    EnumLocale.txtSomethingElse.name.tr,
    EnumLocale.txtChildAbuse.name.tr,
    EnumLocale.txtOthers.name.tr,
  ];

  static Future<void> onSendReport({
    required String reportType,
    required String targetId,
  }) async {
    if (targetId.trim().isEmpty) {
      Get.back();
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      return;
    }

    isLoading.value = true;

    final selectedIndex =
        selectedReportType.value.clamp(0, reportTypes.length - 1);
    final reasonCode = reportReasonCodes[selectedIndex];
    final reasonText = reportTypes[selectedIndex].toString();

    final response = await ModerationReportApi.submitReport(
      reportType: reportType,
      targetId: targetId,
      reasonCode: reasonCode,
      reasonText: reasonText,
    );

    isLoading.value = false;
    Get.back();

    if ((response?['status'] ?? false) == true) {
      Utils.showToast(Get.context!, EnumLocale.txtReportSendSuccess.name.tr);
      return;
    }

    final message = response?['message']?.toString() ??
        EnumLocale.txtSomeThingWentWrong.name.tr;
    Utils.showToast(Get.context!, message);
  }

  static void show({
    required BuildContext context,
    String reportType = 'user',
    String targetId = '',
    Callback? onComplete,
  }) async {
    ReportBottomSheetUi.selectedReportType.value = 0;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final maxHeight = mediaQuery.size.height * 0.82;

        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.redesignSheetBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 5,
                              width: 44,
                              decoration: BoxDecoration(
                                color: AppColors.redesignSheetHandle,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              EnumLocale.txtReport.name.tr,
                              style: AppFontStyle.fontStyleW700(
                                fontColor: AppColors.redesignSheetTitle,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: AppColors.transparent,
                        child: InkWell(
                          onTap: Get.back,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.redesignSheetBg,
                              border: Border.all(
                                color: AppColors.redesignSheetCloseBorder,
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 24,
                              color: AppColors.redesignSheetCloseIcon,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColors.redesignSheetDivider, height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: reportTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return Obx(
                        () {
                          final isSelected = selectedReportType.value == index;
                          return Material(
                            color: AppColors.transparent,
                            child: InkWell(
                              onTap: () => selectedReportType.value = index,
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.redesignReportOptionSelectedBg
                                      : AppColors.redesignReportOptionBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors
                                            .redesignReportOptionSelectedBorder
                                        : AppColors.redesignReportOptionBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ReportRadioButtonUi(isSelected: isSelected),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        reportTypes[index] ?? '',
                                        style: AppFontStyle.fontStyleW500(
                                          fontColor: isSelected
                                              ? AppColors
                                                  .redesignReportOptionSelectedText
                                              : AppColors
                                                  .redesignReportOptionText,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Obx(
                  () {
                    if (isLoading.value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: SizedBox(
                          height: 26,
                          width: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: AppColors.redesignReportLoading,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                          14,
                          8,
                          14,
                          mediaQuery.padding.bottom > 0
                              ? mediaQuery.padding.bottom + 8
                              : 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: Get.back,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .redesignReportSecondaryButtonBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors
                                          .redesignReportSecondaryButtonBorder,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      EnumLocale.txtCancel.name.tr,
                                      style: AppFontStyle.fontStyleW700(
                                        fontColor: AppColors
                                            .redesignReportSecondaryButtonText,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await onSendReport(
                                    reportType: reportType,
                                    targetId: targetId,
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.redesignReportPrimaryButtonBg,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      EnumLocale.txtReport.name.tr,
                                      style: AppFontStyle.fontStyleW700(
                                        fontColor: AppColors
                                            .redesignReportPrimaryButtonText,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => onComplete?.call());
  }
}

class ReportRadioButtonUi extends StatelessWidget {
  const ReportRadioButtonUi({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      color: AppColors.transparent,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.redesignReportRadioActive
                  : AppColors.redesignReportRadioInactive,
            ),
            child: Container(
              height: 18,
              width: 18,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.redesignReportRadioBorderActive
                      : AppColors.redesignReportRadioBorderInactive,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

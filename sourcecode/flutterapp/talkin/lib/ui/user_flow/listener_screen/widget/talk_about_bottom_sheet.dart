import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class TalkAboutBottomSheet extends StatefulWidget {
  const TalkAboutBottomSheet({super.key});

  @override
  State<TalkAboutBottomSheet> createState() => _TalkAboutBottomSheetState();
}

class _TalkAboutBottomSheetState extends State<TalkAboutBottomSheet> {
  final ListenersScreenController controller = Get.find();

  static final Color _brandRed = AppColors.redesignBrandRed;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;
  static final Color _chipSurface = AppColors.redesignSurfaceSoft;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: GetBuilder<ListenersScreenController>(
                id: Constant.talkAboutTopic,
                builder: (controller) {
                  final selectedCount = controller.selectedTopics.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 5,
                          width: 54,
                          decoration: BoxDecoration(
                            color: _softBorder,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: _brandRed.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.question_answer_rounded,
                                color: _brandRed,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                EnumLocale.txtTalkAbout.name.tr,
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 22,
                                  fontColor: _brandDark,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: _chipSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _softBorder),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: _mutedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Text(
                          EnumLocale.txtSelectTalkaboutTxt.name.tr,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 13,
                            fontColor: _mutedText,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: selectedCount > 0
                                    ? _brandRed.withValues(alpha: 0.10)
                                    : _chipSurface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                selectedCount > 0
                                    ? '$selectedCount selected'
                                    : EnumLocale.txtAll.name.tr,
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 11,
                                  fontColor: selectedCount > 0
                                      ? _brandRed
                                      : _mutedText,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (selectedCount > 0)
                              TextButton(
                                onPressed: () {
                                  controller.clearSelectedTopics();
                                },
                                child: Text(
                                  EnumLocale.txtClear.name.tr,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 12,
                                    fontColor: _brandRed,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: controller.talkTopic.isEmpty
                            ? Center(
                                child: Text(
                                  EnumLocale.txtNoTopicsAvailable.name.tr,
                                  style: AppFontStyle.fontStyleW500(
                                    fontSize: 13,
                                    fontColor: _mutedText,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  12,
                                ),
                                itemCount: controller.talkTopic.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final topic = controller.talkTopic[index];
                                  final isSelected =
                                      controller.selectedTopics.contains(index);

                                  return Material(
                                    color: AppColors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () {
                                        controller.selectTopic(index);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 160),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? _brandRed.withValues(
                                                  alpha: 0.08)
                                              : AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected
                                                ? _brandRed
                                                : _softBorder,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                topic.name.toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    AppFontStyle.fontStyleW600(
                                                  fontSize: 14,
                                                  fontColor: isSelected
                                                      ? _brandRed
                                                      : _brandDark,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              height: 22,
                                              width: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? _brandRed
                                                    : AppColors.white,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? _brandRed
                                                      : _softBorder,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? Icon(
                                                      Icons.check_rounded,
                                                      size: 15,
                                                      color: AppColors.white,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      controller.filterListenerByTalkTopic();
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: _brandDark,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      EnumLocale.txtSubmit.name.tr,
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 15,
                                        fontColor: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (selectedCount > 0) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        controller.clearSelectedTopics();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: _softBorder),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        foregroundColor: _brandDark,
                                        backgroundColor: _chipSurface,
                                      ),
                                      child: Text(
                                        EnumLocale.txtClear.name.tr,
                                        style: AppFontStyle.fontStyleW600(
                                          fontSize: 15,
                                          fontColor: _brandDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

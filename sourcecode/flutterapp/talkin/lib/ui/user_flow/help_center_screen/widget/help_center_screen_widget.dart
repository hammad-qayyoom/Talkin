import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/controller/help_center_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterAppBar extends StatelessWidget {
  const HelpCenterAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 760;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              Utils.onChangeStatusBar(brightness: Brightness.dark);
              Get.back();
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtHelpCenter.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 28 : 22,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Support, issue reporting and FAQs',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: isTablet ? 12 : 11,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.redesignAccentSoftBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 18,
              color: AppColors.redesignBrandRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.redesignBrandDark,
          ),
        ),
      ),
    );
  }
}

class HelpCenterScreenView extends GetView<HelpCenterScreenController> {
  const HelpCenterScreenView({super.key});

  Future<void> _openIssueMail() async {
    final helpdeskEmail = Database.settingApiModel?.data?.helpdeskEmail ?? '';
    final userEmail =
        Database.fetchLoginUserProfileModel?.user?.email ?? 'no-reply@talkin';

    if (helpdeskEmail.trim().isEmpty) {
      Get.snackbar('Error', 'Helpdesk email not available');
      return;
    }

    final emailUri = Uri(
      scheme: 'mailto',
      path: helpdeskEmail,
      queryParameters: {
        'subject': 'Support Request from $userEmail',
        'body': 'User Email: $userEmail\n\nPlease describe your issue here.',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar('Error', 'Could not open email client');
    }
  }

  Widget _buildFaqLoading() {
    return Column(
      children: const [
        _FaqLoadingTile(),
        SizedBox(height: 10),
        _FaqLoadingTile(),
        SizedBox(height: 10),
        _FaqLoadingTile(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 760;

        return RefreshIndicator(
          color: AppColors.redesignBrandRed,
          backgroundColor: AppColors.white,
          onRefresh: () async {
            await controller.getFaqData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.redesignBrandRed,
                        AppColors.redesignBrandRedDeep,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.redesignBrandRed.withValues(alpha: 0.24),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Support Desk',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 11,
                                  fontColor: AppColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              EnumLocale.txtNeedAnyHelpFAQ.name.tr,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: isTablet ? 30 : 24,
                                fontColor: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              EnumLocale.txtHelpCenterDescription.name.tr,
                              maxLines: isTablet ? 5 : 4,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: isTablet ? 14 : 12,
                                fontColor:
                                    AppColors.white.withValues(alpha: 0.9),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: isTablet ? 86 : 72,
                        width: isTablet ? 86 : 72,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            AppAsset.helpCenterBlur,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: _openIssueMail,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.redesignSoftBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: AppColors.redesignSurfaceSoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Image.asset(
                                AppAsset.helpCenterGirl,
                                height: 32,
                                width: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EnumLocale.txtHaveAnIssue.name.tr,
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 17,
                                    fontColor: AppColors.redesignBrandDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Send us a detailed support request by email.',
                                  style: AppFontStyle.fontStyleW500(
                                    fontSize: 11,
                                    fontColor: AppColors.redesignMutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: AppColors.redesignSurfaceInput,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColors.redesignSoftBorder,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.redesignMutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  EnumLocale.txtFrequentlyAskedQuestions.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: isTablet ? 22 : 18,
                    fontColor: AppColors.redesignBrandDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Quick answers before you submit your request',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: isTablet ? 13 : 11,
                    fontColor: AppColors.redesignMutedText,
                  ),
                ),
                const SizedBox(height: 10),
                GetBuilder<HelpCenterScreenController>(
                  id: Constant.idFAQListeners,
                  builder: (controller) {
                    if (controller.isLoading) {
                      return _buildFaqLoading();
                    }

                    if (controller.faqList.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.redesignSoftBorder,
                          ),
                        ),
                        child: Text(
                          'No FAQs available right now.',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.redesignMutedText,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(
                        controller.faqList.length,
                        (index) {
                          final faq = controller.faqList[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == controller.faqList.length - 1
                                  ? 0
                                  : 10,
                            ),
                            child: _FaqTile(
                              title: (faq.question ?? '').trim(),
                              answer: (faq.answer ?? '').trim(),
                              isExpanded: controller.expandedIndex == index,
                              onTap: () => controller.toggleExpansion(index),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.title,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  final String title;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final safeTitle = title.isEmpty ? 'Question' : title;
    final safeAnswer = answer.isEmpty ? 'No answer available.' : answer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppColors.redesignBrandRed.withValues(alpha: 0.28)
              : AppColors.redesignSoftBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isExpanded ? 0.04 : 0.025),
            blurRadius: isExpanded ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        safeTitle,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: isExpanded ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.redesignMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.topCenter,
              heightFactor: isExpanded ? 1 : 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  safeAnswer,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: AppColors.redesignMutedText,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqLoadingTile extends StatelessWidget {
  const _FaqLoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
    );
  }
}

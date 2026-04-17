import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/app_button/primary_app_button.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';
import 'package:notisboard/ui/user_flow/host_request_sent_successfully_screen/shimmer/host_request_successfully_shimmer.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class _RequestStatusVisual {
  const _RequestStatusVisual({
    required this.label,
    required this.badgeBackground,
    required this.badgeText,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroGradient,
  });

  final String label;
  final Color badgeBackground;
  final Color badgeText;
  final String heroTitle;
  final String heroSubtitle;
  final List<Color> heroGradient;
}

_RequestStatusVisual _resolveStatusVisual(int? status) {
  if (status == 2) {
    return const _RequestStatusVisual(
      label: 'Approved',
      badgeBackground: Color(0xFFE6F6ED),
      badgeText: Color(0xFF0F8C3D),
      heroTitle: 'Expert Request Approved',
      heroSubtitle:
          'Your expert profile has been approved and is now active in the app.',
      heroGradient: [
        Color(0xFF1C9C4D),
        Color(0xFF0F7A3A),
      ],
    );
  }

  if (status == 3) {
    return _RequestStatusVisual(
      label: 'Declined',
      badgeBackground: AppColors.redesignBrandRed,
      badgeText: AppColors.white,
      heroTitle: 'Expert Request Needs Updates',
      heroSubtitle:
          'Please review the feedback below, update your details, and submit again.',
      heroGradient: [
        AppColors.redesignBrandDark,
        AppColors.redesignBrandDarkAlt,
      ],
    );
  }

  return _RequestStatusVisual(
    label: 'Pending',
    badgeBackground: AppColors.redesignSurfaceNeutral,
    badgeText: AppColors.redesignMutedText,
    heroTitle: 'Expert Request Sent Successfully',
    heroSubtitle:
        'Our team is reviewing your details and will update you soon.',
    heroGradient: [
      AppColors.redesignBrandRed,
      AppColors.redesignBrandRedDeep,
    ],
  );
}

class InfoTile extends StatelessWidget {
  final String title;
  final String data;

  const InfoTile({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final value = data.trim().isEmpty ? '--' : data.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              title,
              style: AppFontStyle.fontStyleW600(
                fontSize: 14,
                fontColor: AppColors.redesignTextMeta,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppFontStyle.fontStyleW700(
                fontSize: 15,
                fontColor: AppColors.redesignBrandDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackHomeButton extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? tryAgainOnTap;
  final bool showTryAgain;

  const BackHomeButton({
    super.key,
    this.onTap,
    this.tryAgainOnTap,
    this.showTryAgain = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.redesignSoftBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              if (showTryAgain) ...[
                Expanded(
                  child: PrimaryAppButton(
                    onTap: tryAgainOnTap,
                    color: AppColors.white,
                    borderColor: AppColors.redesignSoftBorder,
                    borderRadius: 16,
                    height: 54,
                    text: EnumLocale.txtTryAgain.name.tr,
                    textStyle: AppFontStyle.fontStyleW700(
                      fontSize: 15,
                      fontColor: AppColors.redesignBrandDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: PrimaryAppButton(
                  onTap: onTap,
                  color: AppColors.redesignBrandDark,
                  borderRadius: 16,
                  height: 54,
                  text: EnumLocale.txtBackToHome.name.tr,
                  textStyle: AppFontStyle.fontStyleW700(
                    fontSize: 17,
                    fontColor: AppColors.white,
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

class TopView extends StatelessWidget {
  const TopView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BecomeHostScreenController>(
      builder: (controller) {
        final statusVisual = _resolveStatusVisual(
            controller.listenersRequestCheckModel?.data?.status);
        final topInset = MediaQuery.paddingOf(context).top;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, topInset + 14, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: statusVisual.heroGradient,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: statusVisual.heroGradient.first.withValues(alpha: 0.35),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -36,
                right: -44,
                child: Container(
                  height: 170,
                  width: 170,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expert Verification',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 13,
                            fontColor: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusVisual.heroTitle,
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 37,
                            fontColor: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusVisual.heroSubtitle,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 13,
                            height: 1.45,
                            fontColor: AppColors.white.withValues(alpha: 0.86),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.36),
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      AppAsset.requestSentImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class InfoView extends StatelessWidget {
  const InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BecomeHostScreenController>(
      builder: (controller) {
        final data = controller.listenersRequestCheckModel?.data;
        final dateTimeParts = controller.getFormattedDateParts(data?.date);
        final statusVisual = _resolveStatusVisual(data?.status);
        final profileImage =
            (data?.image ?? Database.loginUserProfilePic).trim();

        if (controller.isLoading && data == null) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: HostRequestSuccessfullyShimmer(),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.redesignSoftBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 76,
                      width: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.redesignSoftBorder,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomProfileImage(image: profileImage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (data?.name ?? Database.loginUserName)
                                    .trim()
                                    .isEmpty
                                ? Database.loginUserName
                                : data!.name!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 32,
                              fontColor: AppColors.redesignBrandDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (data?.email ?? Database.loginUserEmail)
                                    .trim()
                                    .isEmpty
                                ? Database.loginUserNickName
                                : (data?.email ?? Database.loginUserEmail)
                                    .trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 13,
                              fontColor: AppColors.redesignMutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusVisual.badgeBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusVisual.label,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: statusVisual.badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  color: AppColors.redesignSoftBorder,
                  height: 1,
                ),
                const SizedBox(height: 16),
                InfoTile(
                  title: '${EnumLocale.txtRequestID.name.tr} :',
                  data: data?.uniqueId ?? '',
                ),
                InfoTile(
                  title: '${EnumLocale.txtListenersName.name.tr} :',
                  data: data?.name ?? '',
                ),
                InfoTile(
                  title: '${EnumLocale.txtMailId.name.tr} :',
                  data: data?.email ?? '',
                ),
                InfoTile(
                  title: '${EnumLocale.txtAddress.name.tr} :',
                  data: data?.location ?? '',
                ),
                InfoTile(
                  title: '${EnumLocale.txtRequestDate.name.tr} :',
                  data: dateTimeParts['date'] ?? '',
                ),
                InfoTile(
                  title: '${EnumLocale.txtRequestTime.name.tr} :',
                  data: dateTimeParts['time'] ?? '',
                ),
                if ((data?.status ?? 0) == 3 &&
                    (data?.reason ?? '').trim().isNotEmpty) ...[
                  _DetailPanel(
                    title: '${EnumLocale.txtReason.name.tr} :',
                    value: data?.reason ?? '',
                  ),
                  const SizedBox(height: 12),
                ],
                _DetailPanel(
                  title: '${EnumLocale.txtIntroduction.name.tr} :',
                  value: data?.selfIntro ?? '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final detail = value.trim().isEmpty ? '--' : value.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFontStyle.fontStyleW700(
            fontSize: 15,
            fontColor: AppColors.redesignBrandDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.redesignSurfaceNeutralAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.redesignSoftBorder),
          ),
          child: Text(
            detail,
            style: AppFontStyle.fontStyleW500(
              fontSize: 14,
              height: 1.5,
              fontColor: AppColors.redesignBrandDark,
            ),
          ),
        ),
      ],
    );
  }
}

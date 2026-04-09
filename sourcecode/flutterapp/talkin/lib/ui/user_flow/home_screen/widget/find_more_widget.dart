import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class FindMoreWidget extends StatelessWidget {
  const FindMoreWidget({super.key});

  static const List<List<Color>> _categoryPalette = [
    [Color(0xFF4E47C8), Color(0xFF6A64DE)],
    [Color(0xFFE0C552), Color(0xFFEDD77A)],
    [Color(0xFFA8D2C3), Color(0xFFBFE1D5)],
    [Color(0xFFE3B79C), Color(0xFFF0CCB6)],
    [Color(0xFF6A89CF), Color(0xFF8CA7E2)],
  ];

  String? _resolveCategoryImageUrl(String? imagePath) {
    final normalized = (imagePath ?? '').trim();
    if (normalized.isEmpty) return null;

    if (normalized.startsWith('http')) {
      return normalized;
    }

    if (normalized.startsWith('/')) {
      return '${Api.baseUrl}${normalized.substring(1)}';
    }

    return '${Api.baseUrl}$normalized';
  }

  IconData _resolveFallbackIcon(TalkTopic category) {
    final combined =
        '${category.icon ?? ''} ${category.name ?? ''}'.toLowerCase();

    if (combined.contains('doctor') ||
        combined.contains('medical') ||
        combined.contains('stethoscope')) {
      return Icons.medical_services_outlined;
    }

    if (combined.contains('family') || combined.contains('relationship')) {
      return Icons.family_restroom_outlined;
    }

    if (combined.contains('mental') || combined.contains('mind')) {
      return Icons.psychology_outlined;
    }

    if (combined.contains('work') ||
        combined.contains('career') ||
        combined.contains('office')) {
      return Icons.work_outline_rounded;
    }

    return Icons.category_outlined;
  }

  Widget _buildCategoryCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required int paletteIndex,
    String? imagePath,
    TalkTopic? category,
  }) {
    final palette = _categoryPalette[paletteIndex % _categoryPalette.length];
    final imageUrl = _resolveCategoryImageUrl(imagePath);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 86,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.appColor
                      : AppColors.white.withValues(alpha: 0.75),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: imageUrl == null
                    ? Center(
                        child: Icon(
                          category == null
                              ? Icons.grid_view_rounded
                              : _resolveFallbackIcon(category),
                          color: AppColors.white,
                          size: 28,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Icon(
                            category == null
                                ? Icons.grid_view_rounded
                                : _resolveFallbackIcon(category),
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            category == null
                                ? Icons.grid_view_rounded
                                : _resolveFallbackIcon(category),
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW600(
                fontSize: 12,
                fontColor:
                    isSelected ? AppColors.appColor : AppColors.appDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeScreenController homeController =
        Get.find<HomeScreenController>();

    return Column(
      children: [
        Image.asset(AppAsset.homeCallPerson, height: 112, width: 334)
            .paddingOnly(top: 28, left: 20, right: 20),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: [0, 1],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xffF3F7FF),
                Color(0xffF3F7FF).withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                EnumLocale.txtHomeFastLalk.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(
                    fontSize: 18, fontColor: AppColors.appColor),
              ).paddingOnly(top: 8),
              Text(
                EnumLocale.txtHomeDescription.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                    fontSize: 12, fontColor: AppColors.grey),
              ).paddingOnly(top: 4, bottom: 10),
              Center(
                child: PrimaryAppButton(
                  height: 40,
                  // height: Get.height * 0.056,
                  // width: Get.width * 0.5,
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.allListeners,
                      arguments: {
                        'categoryId': homeController.selectedCategoryId,
                      },
                    )?.then(
                      (value) async {
                        UserCoinModel? userCoinModel;
                        userCoinModel = await UserCoinApi.callApi();
                        if (userCoinModel?.status == true) {
                          Database.onSetUserCoin(
                              (userCoinModel?.coin ?? 0).toString());
                        }
                      },
                    );
                  },
                  widget: Image.asset(
                    AppAsset.arrowUp,
                    height: 15,
                    width: 15,
                  ),
                  text: EnumLocale.txtFindMoreListener.name.tr,
                  textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 14, fontColor: AppColors.white),
                ).paddingOnly(
                    bottom: 10,
                    left: Get.width * 0.22,
                    right: Get.width * 0.22),
              ),
              Center(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.userGroupSessionsScreen);
                    },
                    child: Text(
                      'Explore Group Sessions',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 13,
                        fontColor: AppColors.appColor,
                      ),
                    ),
                  ),
                ).paddingOnly(
                  bottom: 8,
                  left: Get.width * 0.2,
                  right: Get.width * 0.2,
                ),
              ),
              GetBuilder<HomeScreenController>(
                id: Constant.idHomeCategories,
                builder: (controller) {
                  final categories = controller.homeCategories;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Show all categories',
                        style: AppFontStyle.fontStyleW600(
                            fontSize: 13, fontColor: AppColors.appTextColor),
                      ).paddingOnly(bottom: 10, left: 4),
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildCategoryCard(
                                label: 'All',
                                isSelected:
                                    controller.selectedCategoryId == null,
                                onTap: () =>
                                    controller.selectHomeCategory(null),
                                paletteIndex: 0,
                              );
                            }

                            final category = categories[index - 1];
                            final categoryId = (category.id ?? '').trim();
                            final isSelected = categoryId.isNotEmpty &&
                                controller.selectedCategoryId == categoryId;

                            return _buildCategoryCard(
                              label: (category.name ?? '').trim().isEmpty
                                  ? 'Category'
                                  : category.name!.trim(),
                              isSelected: isSelected,
                              onTap: () => controller.selectHomeCategory(
                                categoryId.isEmpty ? null : categoryId,
                              ),
                              paletteIndex: index,
                              imagePath: category.image,
                              category: category,
                            );
                          },
                        ),
                      ),
                    ],
                  ).paddingOnly(left: 10, right: 10, bottom: 8);
                },
              ),
            ],
          ).paddingSymmetric(horizontal: 10),
        )
      ],
    );
  }
}

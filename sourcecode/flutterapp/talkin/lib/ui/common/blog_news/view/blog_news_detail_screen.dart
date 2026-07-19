import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/ui/common/blog_news/controller/blog_news_controller.dart';
import 'package:notisboard/ui/common/blog_news/model/blog_news_model.dart';
import 'package:notisboard/ui/common/blog_news/widget/blog_content_renderer.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:share_plus/share_plus.dart';

class BlogNewsDetailScreen extends StatefulWidget {
  const BlogNewsDetailScreen({super.key});

  @override
  State<BlogNewsDetailScreen> createState() => _BlogNewsDetailScreenState();
}

class _BlogNewsDetailScreenState extends State<BlogNewsDetailScreen> {
  final BlogNewsController controller = Get.find<BlogNewsController>();
  BlogNewsItem? initialItem;
  String slugOrId = '';

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is Map) {
      initialItem = Get.arguments['item'];
      slugOrId = Get.arguments['slugOrId']?.toString() ?? initialItem?.slug ?? initialItem?.id ?? '';
    }
    if (slugOrId.isNotEmpty) {
      controller.fetchBlogDetail(slugOrId: slugOrId, initialItem: initialItem);
    }
  }

  String _cleanUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      final base = Api.baseUrl.endsWith('/')
          ? Api.baseUrl.substring(0, Api.baseUrl.length - 1)
          : Api.baseUrl;
      return '$base$url';
    }
    return '${Api.baseUrl}$url';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return 'Recent';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return 'Recent';
    }
  }

  void _shareArticle(BlogNewsItem? item) {
    if (item == null) return;
    final slug = item.slug ?? item.id ?? '';
    final shareUrl = '${Api.baseUrl}blog/$slug';
    Share.share(shareUrl);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final topInset = mediaQuery.padding.top;
    final isTablet = width >= 760;
    final maxContentWidth = width >= 1100 ? 980.0 : width;

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              Container(
                color: AppColors.redesignScreenBackground,
                padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 12),
                child: Row(
                  children: [
                    _DetailIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () async {
                        Get.back();
                        await 0.2.delay();
                        Utils.onChangeStatusBar(brightness: Brightness.dark);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Article Detail',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: isTablet ? 22 : 18,
                          fontColor: AppColors.redesignBrandDark,
                        ),
                      ),
                    ),
                    GetBuilder<BlogNewsController>(
                      id: Constant.idBlogNewsDetail,
                      builder: (ctrl) {
                        final item = ctrl.currentDetailItem ?? initialItem;
                        return _DetailIconButton(
                          icon: Icons.share_rounded,
                          onTap: () => _shareArticle(item),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GetBuilder<BlogNewsController>(
                  id: Constant.idBlogNewsDetail,
                  builder: (ctrl) {
                    final item = ctrl.currentDetailItem ?? initialItem;

                    if (ctrl.isDetailLoading && item == null) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    if (item == null) {
                      return Center(
                        child: Text(
                          'Article not found',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 16,
                            fontColor: AppColors.redesignMutedText,
                          ),
                        ),
                      );
                    }

                    final imageUrl = _cleanUrl(item.coverImage);
                    final dateText = _formatDate(item.publishedAt ?? item.createdAt);
                    final authorName = (item.author ?? '').trim().isNotEmpty ? (item.author ?? '').trim() : 'Notisboard Team';

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Container(
                              height: isTablet ? 320 : 220,
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.redesignSoftBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withValues(alpha: 0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.lightGrey,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.lightGrey,
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    size: 40,
                                    color: AppColors.redesignMutedText,
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.redesignBrandRed.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.redesignBrandRed.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  authorName.toUpperCase(),
                                  style: AppFontStyle.fontStyleW700(
                                    fontSize: 11,
                                    fontColor: AppColors.redesignBrandRed,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: AppColors.redesignMutedText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateText,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 12,
                                  fontColor: AppColors.redesignMutedText,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.redesignSurfaceNeutralAlt,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: AppColors.redesignSoftBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility_outlined,
                                      size: 13,
                                      color: AppColors.redesignMutedText,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.views ?? 0}',
                                      style: AppFontStyle.fontStyleW600(
                                        fontSize: 11,
                                        fontColor: AppColors.redesignMutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.title ?? 'Untitled Article',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: isTablet ? 26 : 22,
                              fontColor: AppColors.redesignBrandDark,
                              height: 1.35,
                            ),
                          ),
                          if ((item.summary ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.redesignSoftBorder),
                              ),
                              child: Text(
                                (item.summary ?? '').trim(),
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: isTablet ? 16 : 15,
                                  fontColor: AppColors.redesignBrandDark.withValues(alpha: 0.88),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Divider(color: AppColors.redesignSoftBorder, height: 1),
                          const SizedBox(height: 20),
                          if (ctrl.isDetailLoading && ((item.content ?? '').trim().isEmpty))
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else
                            BlogContentRenderer(
                              htmlContent: item.content ?? '',
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailIconButton extends StatelessWidget {
  const _DetailIconButton({
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/ui/common/blog_news/controller/blog_news_controller.dart';
import 'package:notisboard/ui/common/blog_news/shimmer/blog_news_shimmer.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class BlogNewsListScreen extends StatelessWidget {
  const BlogNewsListScreen({super.key, this.isBottomTab = false});

  final bool isBottomTab;

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
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Recent';
    }
  }

  int _calculateReadTime(String? content, String? summary) {
    final text = '${summary ?? ''} ${content ?? ''}';
    final words = text.split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final topInset = mediaQuery.padding.top;
    final isTablet = width >= 760;
    final maxContentWidth = width >= 1100 ? 980.0 : width;

    final BlogNewsController controller = Get.isRegistered<BlogNewsController>()
        ? Get.find<BlogNewsController>()
        : Get.put(BlogNewsController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!isBottomTab) ...[
                          _HeaderIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () async {
                              Get.back();
                              await 0.2.delay();
                              Utils.onChangeStatusBar(brightness: Brightness.dark);
                            },
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notisboard Blog & News',
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: isTablet ? 24 : 19,
                                  fontColor: AppColors.redesignBrandDark,
                                ),
                              ),
                              Text(
                                'Official updates, tips, and announcements',
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: isTablet ? 13 : 11,
                                  fontColor: AppColors.redesignMutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.redesignBrandRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.redesignSoftBorder),
                          ),
                          child: Icon(
                            Icons.newspaper_rounded,
                            size: 20,
                            color: AppColors.redesignBrandRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GetBuilder<BlogNewsController>(
                      init: controller,
                      id: Constant.idBlogNewsList,
                      builder: (controller) {
                        return Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.redesignSoftBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.searchController,
                            onChanged: (val) {
                              controller.onSearchChanged(val);
                            },
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 14,
                              fontColor: AppColors.redesignBrandDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search articles, news, announcements...',
                              hintStyle: AppFontStyle.fontStyleW500(
                                fontSize: 13,
                                fontColor: AppColors.redesignMutedText,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppColors.redesignMutedText,
                                size: 22,
                              ),
                              suffixIcon: controller.searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: AppColors.redesignMutedText,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        controller.searchController.clear();
                                        controller.onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GetBuilder<BlogNewsController>(
                  init: controller,
                  id: Constant.idBlogNewsList,
                  builder: (controller) {
                    if (controller.isLoading) {
                      return const BlogNewsShimmer();
                    }

                    if (controller.blogList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColors.redesignSurfaceSoft,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.article_outlined,
                                size: 40,
                                color: AppColors.redesignMutedText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No articles found',
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 18,
                                fontColor: AppColors.redesignBrandDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.searchQuery.isNotEmpty
                                  ? 'No results match your search query.'
                                  : 'Check back soon for latest news and updates.',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 13,
                                fontColor: AppColors.redesignMutedText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!controller.isMoreLoading &&
                            controller.hasMore &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          controller.fetchMoreBlogs();
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        color: AppColors.redesignBrandRed,
                        onRefresh: () async {
                          await controller.fetchBlogList(isRefresh: true);
                        },
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          itemCount: controller.blogList.length + (controller.isMoreLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.blogList.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }

                            final item = controller.blogList[index];
                            final imageUrl = _cleanUrl(item.coverImage);
                            final dateText = _formatDate(item.publishedAt ?? item.createdAt);
                            final readTime = _calculateReadTime(item.content, item.summary);

                            return GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.blogNewsDetailScreen,
                                  arguments: {
                                    'item': item,
                                    'slugOrId': item.slug?.isNotEmpty == true ? item.slug : item.id,
                                  },
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(18),
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
                                    if (imageUrl.isNotEmpty)
                                      Stack(
                                        children: [
                                          Container(
                                            height: isTablet ? 220 : 180,
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(18),
                                              ),
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
                                                  size: 32,
                                                  color: AppColors.redesignMutedText,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.black.withValues(alpha: 0.65),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.remove_red_eye_rounded,
                                                    size: 13,
                                                    color: AppColors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${item.views ?? 0}',
                                                    style: AppFontStyle.fontStyleW700(
                                                      fontSize: 11,
                                                      fontColor: AppColors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.redesignSurfaceNeutralAlt,
                                                  borderRadius: BorderRadius.circular(999),
                                                  border: Border.all(color: AppColors.redesignSoftBorder),
                                                ),
                                                child: Text(
                                                  ((item.author ?? '').trim().isNotEmpty
                                                          ? (item.author ?? '').trim()
                                                          : 'Notisboard Team')
                                                      .toUpperCase(),
                                                  style: AppFontStyle.fontStyleW700(
                                                    fontSize: 10,
                                                    fontColor: AppColors.redesignBrandRed,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 13,
                                                color: AppColors.redesignMutedText,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$readTime min read • $dateText',
                                                style: AppFontStyle.fontStyleW500(
                                                  fontSize: 11,
                                                  fontColor: AppColors.redesignMutedText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            item.title ?? 'Untitled Article',
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: isTablet ? 19 : 17,
                                              fontColor: AppColors.redesignBrandDark,
                                            ),
                                          ),
                                          if ((item.summary ?? '').trim().isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              (item.summary ?? '').trim(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppFontStyle.fontStyleW500(
                                                fontSize: isTablet ? 14 : 13,
                                                fontColor: AppColors.redesignMutedText,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Text(
                                                'Read Full Article',
                                                style: AppFontStyle.fontStyleW700(
                                                  fontSize: 13,
                                                  fontColor: AppColors.redesignBrandRed,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 16,
                                                color: AppColors.redesignBrandRed,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';

class BlogContentRenderer extends StatelessWidget {
  final String htmlContent;

  const BlogContentRenderer({
    super.key,
    required this.htmlContent,
  });

  String _cleanUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      final base = Api.baseUrl.endsWith('/') ? Api.baseUrl.substring(0, Api.baseUrl.length - 1) : Api.baseUrl;
      return '$base$url';
    }
    return '${Api.baseUrl}$url';
  }

  List<Widget> _parseHtmlToWidgets(BuildContext context, String content) {
    if (content.trim().isEmpty) return [const SizedBox()];

    List<Widget> widgets = [];

    // Split by block tags (<p>, <h1>..<h6>, <ul>, <ol>, <li>, <blockquote>, <img>, <pre>)
    final RegExp blockRegex = RegExp(
      r'<(h[1-6]|p|blockquote|ul|ol|li|img|pre)[^>]*>(.*?)</\1>|<img[^>]*>',
      caseSensitive: false,
      dotAll: true,
    );

    int lastIndex = 0;
    for (final Match match in blockRegex.allMatches(content)) {
      if (match.start > lastIndex) {
        final String preText = _stripTagsAndEntities(content.substring(lastIndex, match.start));
        if (preText.trim().isNotEmpty) {
          widgets.add(_buildParagraph(preText.trim()));
        }
      }
      lastIndex = match.end;

      final String fullTag = match.group(0) ?? '';
      final String tagType = (match.group(1) ?? (fullTag.toLowerCase().startsWith('<img') ? 'img' : 'p')).toLowerCase();
      final String innerHtml = match.group(2) ?? '';

      if (tagType == 'img') {
        final RegExp srcRegex = RegExp('src=["\']([^"\']+)["\']', caseSensitive: false);
        final srcMatch = srcRegex.firstMatch(fullTag);
        if (srcMatch != null && srcMatch.group(1) != null) {
          final String imgUrl = _cleanUrl(srcMatch.group(1)!);
          widgets.add(_buildImage(imgUrl));
        }
      } else if (tagType.startsWith('h')) {
        final String headingText = _stripTagsAndEntities(innerHtml).trim();
        if (headingText.isNotEmpty) {
          widgets.add(_buildHeading(headingText, tagType));
        }
      } else if (tagType == 'blockquote') {
        final String quoteText = _stripTagsAndEntities(innerHtml).trim();
        if (quoteText.isNotEmpty) {
          widgets.add(_buildBlockquote(quoteText));
        }
      } else if (tagType == 'li') {
        final String liText = _stripTagsAndEntities(innerHtml).trim();
        if (liText.isNotEmpty) {
          widgets.add(_buildListItem(liText));
        }
      } else if (tagType == 'ul' || tagType == 'ol') {
        final RegExp liRegex = RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true);
        final liMatches = liRegex.allMatches(innerHtml);
        if (liMatches.isNotEmpty) {
          for (final li in liMatches) {
            final liContent = _stripTagsAndEntities(li.group(1) ?? '').trim();
            if (liContent.isNotEmpty) {
              widgets.add(_buildListItem(liContent));
            }
          }
        } else {
          final String textContent = _stripTagsAndEntities(innerHtml).trim();
          if (textContent.isNotEmpty) {
            widgets.add(_buildParagraph(textContent));
          }
        }
      } else {
        // <p> or <pre>
        final String pText = _stripTagsAndEntities(innerHtml).trim();
        if (pText.isNotEmpty) {
          widgets.add(_buildParagraph(pText));
        }
      }
    }

    if (lastIndex < content.length) {
      final String postText = _stripTagsAndEntities(content.substring(lastIndex));
      if (postText.trim().isNotEmpty) {
        widgets.add(_buildParagraph(postText.trim()));
      }
    }

    if (widgets.isEmpty) {
      final String rawClean = _stripTagsAndEntities(content).trim();
      if (rawClean.isNotEmpty) {
        widgets.add(_buildParagraph(rawClean));
      }
    }

    return widgets;
  }

  String _stripTagsAndEntities(String input) {
    String text = input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '');
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SelectableText(
        text,
        style: AppFontStyle.fontStyleW500(
          fontSize: 15,
          fontColor: AppColors.redesignBrandDark.withValues(alpha: 0.9),
          height: 1.65,
        ),
      ),
    );
  }

  Widget _buildHeading(String text, String tag) {
    double fontSize = 20;
    if (tag == 'h1') fontSize = 24;
    if (tag == 'h2') fontSize = 22;
    if (tag == 'h3') fontSize = 20;
    if (tag == 'h4') fontSize = 18;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: SelectableText(
        text,
        style: AppFontStyle.fontStyleW700(
          fontSize: fontSize,
          fontColor: AppColors.redesignBrandDark,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBlockquote(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceNeutralAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: AppColors.redesignBrandRed,
            width: 4,
          ),
        ),
      ),
      child: SelectableText(
        text,
        style: AppFontStyle.fontStyleW600(
          fontSize: 15,
          fontColor: AppColors.redesignBrandDark.withValues(alpha: 0.85),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 10),
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: AppColors.redesignBrandRed,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: SelectableText(
              text,
              style: AppFontStyle.fontStyleW500(
                fontSize: 15,
                fontColor: AppColors.redesignBrandDark.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.redesignSoftBorder),
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: AppColors.lightGrey,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 140,
          color: AppColors.lightGrey,
          child: const Center(
            child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseHtmlToWidgets(context, htmlContent),
    );
  }
}

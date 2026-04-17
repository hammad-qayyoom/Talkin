import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/custom_chat_time/custom_format_chat_time.dart';
import 'package:notisboard/custom/custom_profile/custom_profile_image.dart';
import 'package:notisboard/routes/app_routes.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/font_style.dart';

class ChatScreenAppBarView extends StatelessWidget {
  const ChatScreenAppBarView({super.key});

  static final Color _screenBackground = AppColors.redesignScreenBackground;
  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final isTablet = MediaQuery.sizeOf(context).width >= 760;

    return Container(
      color: _screenBackground,
      padding: EdgeInsets.only(
        top: topInset + (isTablet ? 14 : 10),
        left: isTablet ? 22 : 16,
        right: isTablet ? 22 : 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          const SizedBox(width: 46),
          Expanded(
            child: Text(
              EnumLocale.txtChats.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW700(
                fontSize: isTablet ? 38 : 22,
                fontColor: _brandDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.chatListSearchView);
            },
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _softBorder),
              ),
              child: Center(
                child: Image.asset(
                  AppAsset.searchIcon,
                  height: 22,
                  color: _brandDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatViewItem extends StatelessWidget {
  final String name;
  final String image;
  final String? lastMsgTime;
  final String? lastMsg;
  final int index;
  final int unReadCount;
  final void Function()? onTap;

  const ChatViewItem({
    super.key,
    required this.name,
    required this.image,
    required this.index,
    this.onTap,
    required this.unReadCount,
    this.lastMsgTime,
    this.lastMsg,
  });

  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  String _messagePreview(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return 'Start a conversation';
    }

    final lower = text.toLowerCase();
    if (lower.contains('audio call')) return 'Audio call';
    if (lower.contains('video call')) return 'Video call';
    if (lower.contains('image')) return 'Photo message';
    if (lower.contains('audio')) return 'Audio message';

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 760;
    final avatarSize = isTablet ? 64.0 : 56.0;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(isTablet ? 14 : 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _softBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: avatarSize,
              width: avatarSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.redesignSurfaceNeutral,
              ),
              clipBehavior: Clip.hardEdge,
              child: CustomProfileImage(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: isTablet ? 20 : 16,
                      fontColor: _brandDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _messagePreview(lastMsg ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: isTablet ? 15 : 13,
                      fontColor: _mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CustomFormatChatTime.convert(lastMsgTime ?? ''),
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 11,
                    fontColor: _mutedText,
                  ),
                ),
                const SizedBox(height: 10),
                if (unReadCount > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.redesignBrandRed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        unReadCount > 99 ? '99+' : unReadCount.toString(),
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 11,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchChatViewItem extends StatelessWidget {
  final String name;
  final String image;
  final String lastMsg;
  final String lastMsgTime;
  final int index;
  final bool isOnline;
  final void Function()? onTap;

  const SearchChatViewItem({
    super.key,
    required this.name,
    required this.image,
    required this.index,
    this.onTap,
    required this.lastMsg,
    required this.lastMsgTime,
    required this.isOnline,
  });

  static final Color _brandDark = AppColors.redesignBrandDark;
  static final Color _mutedText = AppColors.redesignMutedText;
  static final Color _softBorder = AppColors.redesignSoftBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _softBorder),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.redesignSurfaceNeutral,
                  ),
                  child: CustomProfileImage(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline
                          ? AppColors.redesignStatusSuccess
                          : _mutedText,
                      border: Border.all(color: AppColors.white, width: 1.2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 15,
                      fontColor: _brandDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: _mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              CustomFormatChatTime.convert(lastMsgTime),
              style: AppFontStyle.fontStyleW500(
                fontSize: 11,
                fontColor: _mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

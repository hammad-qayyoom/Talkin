import re
with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/view/feed_screen.dart', 'r') as f:
    text = f.read()

replacement = """      if (post.mediaType == 'video') {
        final url = _toAbsoluteUrl(post.mediaUrl);
        return _PostVideoPlayer(url: url);
      }"""

old_code = """      if (post.mediaType == 'video') {
        final url = _toAbsoluteUrl(post.mediaUrl);

        return GestureDetector(
          onTap: () => _openExternal(url),
          child: Container(
            height: 230,
            width: Get.width,
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.white,
                  size: 56,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to open video',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 14,
                    fontColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }"""

text = text.replace(old_code, replacement)

with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/view/feed_screen.dart', 'w') as f:
    f.write(text)

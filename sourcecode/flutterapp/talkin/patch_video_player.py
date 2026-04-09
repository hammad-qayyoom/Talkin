import re
with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/view/feed_screen.dart', 'r') as f:
    text = f.read()

# Add import
if "import 'package:video_player/video_player.dart';" not in text:
    text = text.replace("import 'package:url_launcher/url_launcher.dart';", "import 'package:url_launcher/url_launcher.dart';\nimport 'package:video_player/video_player.dart';")

# Recreate _PostVideoPlayer
video_player_code = """
class _PostVideoPlayer extends StatefulWidget {
  const _PostVideoPlayer({required this.url});
  final String url;

  @override
  State<_PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<_PostVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
    } else {
      _controller.play();
      _isPlaying = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        height: 230,
        width: Get.width,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              if (!_isPlaying)
                Container(
                  color: AppColors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.white,
                      size: 56,
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
"""

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

text += "\n" + video_player_code

with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/view/feed_screen.dart', 'w') as f:
    f.write(text)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notisboard/custom/image/professional_cached_image.dart';
import 'package:notisboard/custom/verified_badge/verified_badge.dart';
import 'package:notisboard/ui/user_flow/feed_screen/api/feed_api.dart';
import 'package:notisboard/ui/user_flow/feed_screen/controller/feed_screen_controller.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:video_player/video_player.dart';

class FeedAuthorProfileScreen extends StatefulWidget {
  const FeedAuthorProfileScreen({super.key});

  @override
  State<FeedAuthorProfileScreen> createState() =>
      _FeedAuthorProfileScreenState();
}

class _FeedAuthorProfileScreenState extends State<FeedAuthorProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<FeedPostItem> _posts = <FeedPostItem>[];

  bool _isLoading = true;
  bool _isPaginationLoading = false;
  bool _hasMore = true;

  int _page = 1;
  final int _limit = 10;

  String _userId = '';
  String _expertId = '';
  String _displayName = '';
  String _profileImage = '';
  bool _isVerifiedBadge = false;

  bool get _isExpert => _expertId.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _readArguments();
    _scrollController.addListener(_onScroll);
    _fetchPosts(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is! Map<String, dynamic>) return;

    _userId = (args['userId'] ?? '').toString().trim();
    _expertId = (args['expertId'] ?? '').toString().trim();
    _displayName = (args['name'] ?? '').toString().trim();
    _profileImage = (args['profilePic'] ?? '').toString().trim();
    _isVerifiedBadge = _parseBool(args['isVerifiedBadge']) ?? false;
  }

  bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (['true', '1', 'yes'].contains(normalized)) return true;
      if (['false', '0', 'no'].contains(normalized)) return false;
    }
    return null;
  }

  void _onScroll() {
    if (!_hasMore || _isLoading || _isPaginationLoading) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 220) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts({bool reset = false}) async {
    final filterUserId = _userId.trim();
    final filterExpertId = _expertId.trim();

    if (filterUserId.isEmpty && filterExpertId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPaginationLoading = false;
          _hasMore = false;
        });
      }
      return;
    }

    if (_isLoading || _isPaginationLoading) {
      if (!reset) return;
    }

    if (reset) {
      _page = 1;
      _hasMore = true;
      _posts.clear();
      if (mounted) {
        setState(() {
          _isLoading = true;
          _isPaginationLoading = false;
        });
      }
    } else {
      if (!_hasMore) return;
      if (mounted) {
        setState(() {
          _isPaginationLoading = true;
        });
      }
    }

    final response = await FeedApi.fetchFeed(
      start: _page,
      limit: _limit,
      userId: filterUserId.isEmpty ? null : filterUserId,
      expertId: filterExpertId.isEmpty ? null : filterExpertId,
    );

    final ok = response['status'] == true;
    if (ok) {
      final fetched = response['data'] is List<dynamic>
          ? (response['data'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(FeedPostItem.fromJson)
              .toList()
          : <FeedPostItem>[];

      if (reset) {
        _posts
          ..clear()
          ..addAll(fetched);
      } else {
        final existingIds = _posts.map((e) => e.id).toSet();
        for (final post in fetched) {
          if (!existingIds.contains(post.id)) {
            _posts.add(post);
          }
        }
      }

      if (_posts.isNotEmpty) {
        final first = _posts.first;
        if (_displayName.trim().isEmpty) {
          _displayName = first.displayName;
        }
        if (_profileImage.trim().isEmpty) {
          _profileImage = first.authorProfilePic;
        }
        _isVerifiedBadge = _isVerifiedBadge || first.isAuthorVerified;
      }

      final total = int.tryParse((response['total'] ?? 0).toString()) ?? 0;
      if (total > 0) {
        _hasMore = _posts.length < total;
      } else {
        _hasMore = fetched.length >= _limit;
      }

      if (fetched.isNotEmpty) {
        _page += 1;
      }
    } else {
      _hasMore = false;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isPaginationLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaPostsCount = _posts.where((e) => e.mediaUrls.isNotEmpty).length;
    final engagement = _posts.fold<int>(
      0,
      (sum, p) => sum + p.likeCount + p.commentCount + p.shareCount,
    );

    return Scaffold(
      backgroundColor: AppColors.redesignScreenBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchPosts(reset: true),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  profileImage: _profileImage,
                  displayName: _displayName,
                  isVerified: _isVerifiedBadge,
                  roleLabel: _isExpert ? 'Expert' : 'User',
                  postsCount: _posts.length,
                  mediaCount: mediaPostsCount,
                  engagementCount: engagement,
                ),
              ),
              if (_isLoading && _posts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.appColor),
                    ),
                  ),
                )
              else if (_posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderColor.withValues(alpha: 0.75),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: AppColors.appColor,
                            size: 28,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No posts to show',
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 15,
                              fontColor: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'This profile has not posted anything yet.',
                            textAlign: TextAlign.center,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 12,
                              fontColor: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return _ProfilePostCard(post: post).paddingOnly(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      top: index == 0 ? 0 : 0,
                    );
                  },
                ),
              if (_isPaginationLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.appColor,
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profileImage,
    required this.displayName,
    required this.isVerified,
    required this.roleLabel,
    required this.postsCount,
    required this.mediaCount,
    required this.engagementCount,
  });

  final String profileImage;
  final String displayName;
  final bool isVerified;
  final String roleLabel;
  final int postsCount;
  final int mediaCount;
  final int engagementCount;

  @override
  Widget build(BuildContext context) {
    final resolvedName = displayName.trim().isEmpty ? 'Profile' : displayName;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.appColor.withValues(alpha: 0.9),
                      AppColors.redesignProfileGradientEnd,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Material(
                  color: AppColors.white.withValues(alpha: 0.24),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    roleLabel,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 11,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: -28,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: ClipOval(
                      child: _ProfileAvatar(image: profileImage),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        resolvedName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 21,
                          fontColor: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    VerifiedBadge(
                      isVerified: isVerified,
                      size: 20,
                      margin: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Community timeline',
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _HeaderStatTile(
                        title: 'Posts',
                        value: '$postsCount',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _HeaderStatTile(
                        title: 'Media',
                        value: '$mediaCount',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _HeaderStatTile(
                        title: 'Engagement',
                        value: '$engagementCount',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    final trimmed = image.trim();
    if (trimmed.isEmpty) {
      return Container(
        color: AppColors.lightGrey,
        child: Icon(
          Icons.person_rounded,
          color: AppColors.darkGrey,
          size: 32,
        ),
      );
    }

    return ProfessionalCachedImage(
      imageUrl: _absoluteUrl(trimmed),
      fit: BoxFit.cover,
      placeholder: const AppImageShimmer(),
      errorWidget: Container(
        color: AppColors.lightGrey,
        child: Icon(
          Icons.person_rounded,
          color: AppColors.darkGrey,
          size: 32,
        ),
      ),
    );
  }
}

class _HeaderStatTile extends StatelessWidget {
  const _HeaderStatTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceCardAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppFontStyle.fontStyleW700(
              fontSize: 15,
              fontColor: AppColors.appColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({required this.post});

  final FeedPostItem post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _relativeTime(post.createdAt),
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 12,
                    fontColor: AppColors.grey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redesignSurfaceChipAlt,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  post.mediaUrls.isNotEmpty
                      ? (post.mediaType == 'video' ? 'Video' : 'Photo')
                      : 'Text',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 10,
                    fontColor: AppColors.appColor,
                  ),
                ),
              ),
            ],
          ),
          if (post.content.trim().isNotEmpty)
            Text(
              post.content,
              style: AppFontStyle.fontStyleW500(
                fontSize: 14,
                fontColor: AppColors.black,
                height: 1.45,
              ),
            ).paddingOnly(top: 8),
          if (post.mediaUrls.isNotEmpty)
            _ProfileMedia(post: post).paddingOnly(top: 10),
          Row(
            children: [
              _SmallCountPill(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.red,
                count: post.likeCount,
              ),
              const SizedBox(width: 6),
              _SmallCountPill(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.darkGrey,
                count: post.commentCount,
              ),
              const SizedBox(width: 6),
              _SmallCountPill(
                icon: Icons.share_outlined,
                iconColor: AppColors.darkGrey,
                count: post.shareCount,
              ),
            ],
          ).paddingOnly(top: 12),
        ],
      ),
    );
  }
}

class _SmallCountPill extends StatelessWidget {
  const _SmallCountPill({
    required this.icon,
    required this.iconColor,
    required this.count,
  });

  final IconData icon;
  final Color iconColor;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.redesignSurfaceCardAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: AppFontStyle.fontStyleW600(
              fontSize: 12,
              fontColor: AppColors.appColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMedia extends StatelessWidget {
  const _ProfileMedia({required this.post});

  final FeedPostItem post;

  @override
  Widget build(BuildContext context) {
    if (post.mediaType == 'video') {
      final rawVideoUrl = post.mediaUrl.trim().isNotEmpty
          ? post.mediaUrl
          : (post.mediaUrls.isNotEmpty ? post.mediaUrls.first : '');

      return _ProfileVideoPlayer(url: _absoluteUrl(rawVideoUrl));
    }

    if (post.mediaUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ProfessionalCachedImage(
          imageUrl: _absoluteUrl(post.mediaUrls.first),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          placeholder: const AppImageShimmer(
            height: 220,
          ),
          errorWidget: Container(
            width: double.infinity,
            height: 220,
            color: AppColors.lightGrey,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.darkGrey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: post.mediaUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ProfessionalCachedImage(
              imageUrl: _absoluteUrl(post.mediaUrls[index]),
              width: 200,
              fit: BoxFit.cover,
              placeholder: const AppImageShimmer(
                width: 200,
              ),
              errorWidget: Container(
                width: 200,
                color: AppColors.lightGrey,
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileVideoPlayer extends StatefulWidget {
  const _ProfileVideoPlayer({required this.url});

  final String url;

  @override
  State<_ProfileVideoPlayer> createState() => _ProfileVideoPlayerState();
}

class _ProfileVideoPlayerState extends State<_ProfileVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  static const double _targetAspectRatio = 16 / 9;

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
    } else {
      _controller.play();
    }
    setState(() {});
  }

  Future<void> _openFullScreen() async {
    if (!_initialized) return;

    final wasPlaying = _controller.value.isPlaying;
    final currentPosition = _controller.value.position;

    _controller.pause();
    setState(() {});

    final result =
        await Navigator.of(context).push<_FeedAuthorFullscreenPlaybackResult>(
      MaterialPageRoute(
        builder: (_) => _FeedAuthorFullscreenVideoPlayer(
          url: widget.url,
          initialPosition: currentPosition,
          autoPlay: wasPlaying,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      await _controller.seekTo(result.position);
      if (result.wasPlaying) {
        await _controller.play();
      }
    } else if (wasPlaying) {
      await _controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _targetAspectRatio,
          child: Container(
            width: Get.width,
            color: AppColors.black.withValues(alpha: 0.88),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _openFullScreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _targetAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller.value.size.width > 0
                      ? _controller.value.size.width
                      : 1,
                  height: _controller.value.size.height > 0
                      ? _controller.value.size.height
                      : 1,
                  child: VideoPlayer(_controller),
                ),
              ),
              if (!_controller.value.isPlaying)
                Container(
                  color: AppColors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.white,
                      size: 56,
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 10,
                child: InkWell(
                  onTap: _openFullScreen,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.fullscreen_rounded,
                      size: 20,
                      color: AppColors.white,
                    ),
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

class _FeedAuthorFullscreenPlaybackResult {
  const _FeedAuthorFullscreenPlaybackResult({
    required this.position,
    required this.wasPlaying,
  });

  final Duration position;
  final bool wasPlaying;
}

class _FeedAuthorFullscreenVideoPlayer extends StatefulWidget {
  const _FeedAuthorFullscreenVideoPlayer({
    required this.url,
    required this.initialPosition,
    required this.autoPlay,
  });

  final String url;
  final Duration initialPosition;
  final bool autoPlay;

  @override
  State<_FeedAuthorFullscreenVideoPlayer> createState() =>
      _FeedAuthorFullscreenVideoPlayerState();
}

class _FeedAuthorFullscreenVideoPlayerState
    extends State<_FeedAuthorFullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.addListener(_onVideoTick);

    _controller.initialize().then((_) async {
      if (!mounted) return;

      final duration = _controller.value.duration;
      final start =
          widget.initialPosition > duration ? duration : widget.initialPosition;
      if (start > Duration.zero) {
        await _controller.seekTo(start);
      }

      if (widget.autoPlay) {
        await _controller.play();
        _scheduleHideControls();
      }

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_onVideoTick);
    _controller.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  void _onVideoTick() {
    if (!mounted || !_initialized) return;
    if (_showControls) {
      setState(() {});
    }
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    if (!_controller.value.isPlaying) return;

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showControls = false;
      });
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _scheduleHideControls();
    }
  }

  void _togglePlayPause() {
    if (!_initialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }

    setState(() {
      _showControls = true;
    });
    _scheduleHideControls();
  }

  Future<void> _seekTo(double ratio) async {
    if (!_initialized) return;

    final duration = _controller.value.duration;
    if (duration <= Duration.zero) return;

    final seconds = (duration.inSeconds * ratio).round();
    final target = Duration(seconds: seconds.clamp(0, duration.inSeconds));
    await _controller.seekTo(target);
  }

  String _formatDuration(Duration value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _closePlayer() {
    Navigator.of(context).pop(
      _FeedAuthorFullscreenPlaybackResult(
        position: _controller.value.position,
        wasPlaying: _controller.value.isPlaying,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = _initialized ? _controller.value.duration : Duration.zero;
    final position = _initialized ? _controller.value.position : Duration.zero;
    final safePosition = position > duration ? duration : position;
    final progressRatio = duration.inMilliseconds > 0
        ? (safePosition.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return PopScope<_FeedAuthorFullscreenPlaybackResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closePlayer();
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_initialized)
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller.value.size.width > 0
                          ? _controller.value.size.width
                          : 1,
                      height: _controller.value.size.height > 0
                          ? _controller.value.size.height
                          : 1,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              else
                Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
              if (_showControls)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.black.withValues(alpha: 0.45),
                        AppColors.transparent,
                        AppColors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _closePlayer,
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _closePlayer,
                              icon: const Icon(
                                Icons.fullscreen_exit_rounded,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _togglePlayPause,
                          iconSize: 64,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: AppColors.white,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: SliderComponentShape.noOverlay,
                                  trackHeight: 3,
                                  activeTrackColor:
                                      AppColors.redesignMediaSliderActive,
                                  inactiveTrackColor:
                                      AppColors.white.withValues(alpha: 0.35),
                                  thumbColor: AppColors.white,
                                ),
                                child: Slider(
                                  min: 0,
                                  max: 1,
                                  value: progressRatio,
                                  onChanged: _seekTo,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _formatDuration(safePosition),
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '/ ${_formatDuration(duration)}',
                                    style: TextStyle(
                                      color: AppColors.white
                                          .withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

String _relativeTime(DateTime? value) {
  if (value == null) return '';

  final now = DateTime.now();
  final diff = now.difference(value);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';

  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return '${weeks}w';

  final months = (diff.inDays / 30).floor();
  if (months < 12) return '${months}mo';

  final years = (diff.inDays / 365).floor();
  return '${years}y';
}

String _absoluteUrl(String path) {
  final value = path.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('/')) {
    return '${Api.baseUrl}${value.substring(1)}';
  }
  return '${Api.baseUrl}$value';
}

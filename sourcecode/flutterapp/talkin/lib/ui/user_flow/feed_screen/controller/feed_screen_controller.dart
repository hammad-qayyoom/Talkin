import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talk_in/ui/user_flow/feed_screen/api/feed_api.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class FeedScreenController extends GetxController {
  bool isStandalone = false;
  bool showComposer = true;
  String screenTitle = 'Community Feed';

  bool isLoading = true;
  bool isPaginationLoading = false;
  bool isCreatingPost = false;
  bool isCommentsLoading = false;

  final ScrollController scrollController = ScrollController();
  final TextEditingController postInputController = TextEditingController();
  final TextEditingController commentInputController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  final List<FeedPostItem> posts = [];
  final Map<String, List<FeedCommentItem>> commentsByPostId = {};
  final Set<String> followingExpertIds = {};

  File? selectedMediaFile;
  String selectedMediaType = 'none';

  String? openedCommentsPostId;
  String? replyingToCommentId;
  String? replyingToUserName;

  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;

  String? userIdFilter;
  String? expertIdFilter;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      isStandalone = args['standalone'] == true;
      showComposer = args['showComposer'] != false;

      final requestedTitle = (args['title'] ?? '').toString().trim();
      if (requestedTitle.isNotEmpty) {
        screenTitle = requestedTitle;
      }

      userIdFilter = (args['userId'] ?? '').toString().trim().isEmpty
          ? null
          : (args['userId'] ?? '').toString().trim();
      expertIdFilter = (args['expertId'] ?? '').toString().trim().isEmpty
          ? null
          : (args['expertId'] ?? '').toString().trim();
    }

    if (userIdFilter != null && userIdFilter != currentUserId()) {
      showComposer = false;
    }
    if (expertIdFilter != null &&
        expertIdFilter!.isNotEmpty &&
        userIdFilter == null) {
      showComposer = false;
    }

    scrollController.addListener(_onScroll);
    fetchFollowingExperts();
    fetchFeed(reset: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    postInputController.dispose();
    commentInputController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!_hasMore || isLoading || isPaginationLoading) {
      return;
    }

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 280) {
      fetchFeed();
    }
  }

  Future<void> fetchFollowingExperts() async {
    final response = await FeedApi.listFollowingExperts(start: 1, limit: 300);
    if (response['status'] == true) {
      final data = response['data'] is List<dynamic>
          ? response['data'] as List<dynamic>
          : <dynamic>[];

      followingExpertIds
        ..clear()
        ..addAll(
          data
              .whereType<Map<String, dynamic>>()
              .map((row) => (row['expert'] is Map<String, dynamic>
                      ? row['expert']['id']
                      : '')
                  .toString()
                  .trim())
              .where((id) => id.isNotEmpty),
        );

      update([Constant.idFeed]);
    }
  }

  Future<void> fetchFeed({bool reset = false}) async {
    if (isLoading || isPaginationLoading) {
      if (!reset) return;
    }

    if (reset) {
      _page = 1;
      _hasMore = true;
      posts.clear();
      isLoading = true;
      update([Constant.idFeed]);
    } else {
      if (!_hasMore) return;
      isPaginationLoading = true;
      update([Constant.idFeed]);
    }

    final response = await FeedApi.fetchFeed(
      start: _page,
      limit: _limit,
      userId: userIdFilter,
      expertId: expertIdFilter,
    );

    final status = response['status'] == true;
    if (status) {
      final fetched = response['data'] is List<dynamic>
          ? (response['data'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(FeedPostItem.fromJson)
              .toList()
          : <FeedPostItem>[];

      if (reset) {
        posts
          ..clear()
          ..addAll(fetched);
      } else {
        final existingIds = posts.map((e) => e.id).toSet();
        for (final post in fetched) {
          if (!existingIds.contains(post.id)) {
            posts.add(post);
          }
        }
      }

      final total = int.tryParse((response['total'] ?? 0).toString()) ?? 0;
      if (posts.length >= total && total > 0) {
        _hasMore = false;
      } else {
        _hasMore = fetched.length >= _limit;
      }

      if (fetched.isNotEmpty) {
        _page += 1;
      }
    } else {
      _showToast((response['message'] ?? 'Failed to load feed.').toString());
    }

    isLoading = false;
    isPaginationLoading = false;
    update([Constant.idFeed]);
  }

  Future<void> onRefresh() async {
    await fetchFeed(reset: true);
  }

  Future<void> pickImageFromGallery() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (picked == null) return;

    selectedMediaFile = File(picked.path);
    selectedMediaType = 'image';
    update([Constant.idFeed]);
  }

  Future<void> pickVideoFromGallery() async {
    final picked = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );

    if (picked == null) return;

    selectedMediaFile = File(picked.path);
    selectedMediaType = 'video';
    update([Constant.idFeed]);
  }

  void clearComposerMedia() {
    selectedMediaFile = null;
    selectedMediaType = 'none';
    update([Constant.idFeed]);
  }

  Future<void> createPost() async {
    if (!showComposer) {
      return;
    }

    final content = postInputController.text.trim();

    if (content.isEmpty && selectedMediaFile == null) {
      _showToast('Post cannot be empty.');
      return;
    }

    isCreatingPost = true;
    update([Constant.idFeed]);

    final response = await FeedApi.createPost(
      content: content,
      mediaFile: selectedMediaFile,
    );

    isCreatingPost = false;

    if (response['status'] == true &&
        response['data'] is Map<String, dynamic>) {
      final created =
          FeedPostItem.fromJson(response['data'] as Map<String, dynamic>);
      posts.insert(0, created);
      postInputController.clear();
      selectedMediaFile = null;
      selectedMediaType = 'none';
      _showToast(
          (response['message'] ?? 'Post created successfully.').toString());
    } else {
      _showToast((response['message'] ?? 'Unable to create post.').toString());
    }

    update([Constant.idFeed]);
  }

  Future<void> toggleLike(FeedPostItem post) async {
    final response = await FeedApi.likePost(postId: post.id);
    if (response['status'] != true) {
      _showToast((response['message'] ?? 'Unable to update like.').toString());
      return;
    }

    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final liked = payload['liked'] == true;
    final likeCount =
        int.tryParse((payload['likeCount'] ?? post.likeCount).toString()) ??
            post.likeCount;

    _replacePost(
      post.copyWith(
        isLikedByMe: liked,
        likeCount: likeCount,
      ),
    );
  }

  Future<void> deletePost(FeedPostItem post) async {
    if (!isMyPost(post)) {
      _showToast('You can only delete your own post.');
      return;
    }

    final response = await FeedApi.deletePost(postId: post.id);
    if (response['status'] == true) {
      posts.removeWhere((item) => item.id == post.id);
      commentsByPostId.remove(post.id);
      _showToast(
          (response['message'] ?? 'Post deleted successfully.').toString());
      update([Constant.idFeed, Constant.idFeedComments]);
      return;
    }

    _showToast((response['message'] ?? 'Unable to delete post.').toString());
  }

  Future<bool> editPost({
    required FeedPostItem post,
    required String content,
  }) async {
    if (!isMyPost(post)) {
      _showToast('You can only edit your own post.');
      return false;
    }

    final normalized = content.trim();
    if (normalized.isEmpty && post.mediaUrls.isEmpty) {
      _showToast('Post cannot be empty.');
      return false;
    }

    final response = await FeedApi.updatePost(
      postId: post.id,
      content: normalized,
    );

    if (response['status'] == true) {
      final payload = response['data'];
      if (payload is Map<String, dynamic>) {
        _replacePost(FeedPostItem.fromJson(payload));
      } else {
        _replacePost(post.copyWith(content: normalized));
      }

      _showToast(
        (response['message'] ?? 'Post updated successfully.').toString(),
      );
      return true;
    }

    _showToast((response['message'] ?? 'Unable to update post.').toString());
    return false;
  }

  Future<void> openMyPostsManager() async {
    final me = currentUserId().trim();
    if (me.isEmpty) {
      _showToast('Unable to open your posts right now.');
      return;
    }

    await Get.toNamed(
      AppRoutes.feedScreen,
      arguments: {
        'standalone': true,
        'title': 'My Posts',
        'showComposer': true,
        'userId': me,
      },
    );
  }

  Future<void> sharePost(FeedPostItem post) async {
    final response =
        await FeedApi.sharePost(postId: post.id, channel: 'external');
    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final shareUrl = (payload['shareUrl'] ?? '').toString().trim();
    final shareCount =
        int.tryParse((payload['shareCount'] ?? post.shareCount).toString()) ??
            post.shareCount;

    final textParts = <String>[];
    if (post.content.trim().isNotEmpty) {
      textParts.add(post.content.trim());
    }
    if (shareUrl.isNotEmpty) {
      textParts.add(shareUrl);
    }

    final shareText = textParts.isEmpty
        ? 'Check this post on Talkin.'
        : textParts.join('\n\n');
    await SharePlus.instance.share(
      ShareParams(text: shareText),
    );

    _replacePost(post.copyWith(shareCount: shareCount));
  }

  Future<void> toggleFollowForPost(FeedPostItem post) async {
    if (post.expertId.isEmpty) {
      return;
    }

    final currentlyFollowing = isFollowingExpert(post.expertId);
    final response = await FeedApi.followExpert(
      expertId: post.expertId,
      follow: !currentlyFollowing,
    );

    if (response['status'] != true) {
      _showToast(
          (response['message'] ?? 'Unable to update follow.').toString());
      return;
    }

    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final isFollowing = payload['isFollowing'] == true;
    if (isFollowing) {
      followingExpertIds.add(post.expertId);
    } else {
      followingExpertIds.remove(post.expertId);
    }

    update([Constant.idFeed]);
  }

  bool isFollowingExpert(String expertId) {
    return followingExpertIds.contains(expertId);
  }

  Future<void> openComments(String postId) async {
    openedCommentsPostId = postId;
    replyingToCommentId = null;
    replyingToUserName = null;
    commentInputController.clear();

    if (!commentsByPostId.containsKey(postId)) {
      await fetchComments(postId);
    }
  }

  Future<void> fetchComments(String postId) async {
    isCommentsLoading = true;
    update([Constant.idFeedComments]);

    final response = await FeedApi.fetchComments(postId: postId);
    if (response['status'] == true) {
      final data = response['data'] is List<dynamic>
          ? (response['data'] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(FeedCommentItem.fromJson)
              .toList()
          : <FeedCommentItem>[];

      commentsByPostId[postId] = data;
    } else {
      _showToast(
          (response['message'] ?? 'Unable to fetch comments.').toString());
    }

    isCommentsLoading = false;
    update([Constant.idFeedComments]);
  }

  void setReplyTarget({
    required String commentId,
    required String userName,
  }) {
    replyingToCommentId = commentId;
    replyingToUserName = userName;
    update([Constant.idFeedComments]);
  }

  void clearReplyTarget() {
    replyingToCommentId = null;
    replyingToUserName = null;
    update([Constant.idFeedComments]);
  }

  Future<void> submitComment(String postId) async {
    final text = commentInputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final response = await FeedApi.createComment(
      postId: postId,
      text: text,
      parentCommentId: replyingToCommentId,
    );

    if (response['status'] == true) {
      commentInputController.clear();
      replyingToCommentId = null;
      replyingToUserName = null;
      await fetchComments(postId);
      _updatePostCommentCount(postId, 1);
    } else {
      _showToast((response['message'] ?? 'Unable to add comment.').toString());
    }

    update([Constant.idFeedComments]);
  }

  void _updatePostCommentCount(String postId, int increment) {
    final index = posts.indexWhere((item) => item.id == postId);
    if (index == -1) {
      return;
    }

    final post = posts[index];
    final nextCount = (post.commentCount + increment).clamp(0, 999999).toInt();
    posts[index] = post.copyWith(commentCount: nextCount);
    update([Constant.idFeed]);
  }

  void _replacePost(FeedPostItem updatedPost) {
    final index = posts.indexWhere((item) => item.id == updatedPost.id);
    if (index == -1) return;

    posts[index] = updatedPost;
    update([Constant.idFeed]);
  }

  String currentUserId() {
    return (Database.fetchLoginUserProfileModel?.user?.id ??
            Database.loginUserId)
        .toString();
  }

  bool isMyPost(FeedPostItem post) {
    final me = currentUserId();
    return me.isNotEmpty && post.userId == me;
  }

  void _showToast(String message) {
    if (Get.context != null) {
      Utils.showToast(Get.context!, message);
    }
  }
}

class FeedPostItem {
  final String id;
  final String userId;
  final String expertId;
  final String content;
  final List<String> mediaUrls;
  final String mediaUrl;
  final String mediaType;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLikedByMe;
  final DateTime? createdAt;
  final String authorName;
  final String authorNickName;
  final String authorProfilePic;

  FeedPostItem({
    required this.id,
    required this.userId,
    required this.expertId,
    required this.content,
    required this.mediaUrls,
    required this.mediaUrl,
    required this.mediaType,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLikedByMe,
    required this.createdAt,
    required this.authorName,
    required this.authorNickName,
    required this.authorProfilePic,
  });

  factory FeedPostItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final expert = json['expert'] is Map<String, dynamic>
        ? json['expert'] as Map<String, dynamic>
        : <String, dynamic>{};

    final hasExpert = expert.isNotEmpty && expert['id'].toString().isNotEmpty;

    final resolvedAuthorName = hasExpert
        ? (expert['displayName'] ?? '').toString()
        : (user['fullName'] ?? '').toString();

    final resolvedAuthorNick =
        hasExpert ? '' : (user['nickName'] ?? '').toString();

    final mediaList = json['mediaUrls'] is List<dynamic>
        ? (json['mediaUrls'] as List<dynamic>)
            .map((item) => item.toString())
            .toList()
        : <String>[];

    final resolvedMediaUrl = (json['mediaUrl'] ?? '').toString();
    final combinedMedia = <String>{
      if (resolvedMediaUrl.trim().isNotEmpty) resolvedMediaUrl,
      ...mediaList,
    }.toList();

    final expertImg =
        (expert['profileImage'] ?? expert['image'] ?? '').toString().trim();
    final userImg = (user['profilePic'] ?? '').toString().trim();

    final resolvedAuthorProfile =
        hasExpert ? (expertImg.isNotEmpty ? expertImg : userImg) : userImg;
    return FeedPostItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      expertId: (json['expertId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      mediaUrls: combinedMedia,
      mediaUrl: combinedMedia.isNotEmpty ? combinedMedia.first : '',
      mediaType: (json['mediaType'] ?? 'none').toString(),
      likeCount: int.tryParse((json['likeCount'] ?? 0).toString()) ?? 0,
      commentCount: int.tryParse((json['commentCount'] ?? 0).toString()) ?? 0,
      shareCount: int.tryParse((json['shareCount'] ?? 0).toString()) ?? 0,
      isLikedByMe: json['isLikedByMe'] == true,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal(),
      authorName: resolvedAuthorName,
      authorNickName: resolvedAuthorNick,
      authorProfilePic: resolvedAuthorProfile,
    );
  }

  String get displayName {
    final nick = authorNickName.trim();
    if (nick.isNotEmpty) return nick;

    final full = authorName.trim();
    if (full.isNotEmpty) return full;

    return 'User';
  }

  FeedPostItem copyWith({
    String? content,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLikedByMe,
  }) {
    return FeedPostItem(
      id: id,
      userId: userId,
      expertId: expertId,
      content: content ?? this.content,
      mediaUrls: mediaUrls,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt,
      authorName: authorName,
      authorNickName: authorNickName,
      authorProfilePic: authorProfilePic,
    );
  }
}

class FeedCommentItem {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String text;
  final String authorName;
  final String authorProfilePic;
  final DateTime? createdAt;
  final List<FeedCommentItem> replies;

  FeedCommentItem({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.text,
    required this.authorName,
    required this.authorProfilePic,
    required this.createdAt,
    required this.replies,
  });

  factory FeedCommentItem.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : <String, dynamic>{};

    final replyRows = json['replies'] is List<dynamic>
        ? (json['replies'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(FeedCommentItem.fromJson)
            .toList()
        : <FeedCommentItem>[];

    return FeedCommentItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      postId: (json['postId'] ?? '').toString(),
      parentCommentId: (json['parentCommentId'] ?? '').toString().trim().isEmpty
          ? null
          : (json['parentCommentId']).toString(),
      text: (json['text'] ?? '').toString(),
      authorName: ((author['nickName'] ?? author['fullName'] ?? '')).toString(),
      authorProfilePic: (author['profilePic'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal(),
      replies: replyRows,
    );
  }
}

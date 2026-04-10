import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/report_bottom_sheet.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/feed_screen/controller/feed_screen_controller.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({
    super.key,
    this.controllerTag,
  });

  final String? controllerTag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedScreenController>(
      id: Constant.idFeed,
      tag: controllerTag,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xffF1F3F9),
          appBar: controller.isStandalone
              ? AppBar(
                  title: Text(
                    controller.screenTitle,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: AppColors.black,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  surfaceTintColor: AppColors.white,
                  backgroundColor: AppColors.white,
                )
              : null,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xffF8FAFE),
                          const Color(0xffECEFF6),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    if (controller.showComposer)
                      _ComposerView(
                        controller: controller,
                        controllerTag: controllerTag,
                      ).paddingOnly(
                        left: 10,
                        right: 10,
                        top: 8,
                        bottom: 8,
                      ),
                    Expanded(
                      child: _FeedListView(
                        controller: controller,
                        controllerTag: controllerTag,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeedListView extends StatelessWidget {
  const _FeedListView({
    required this.controller,
    required this.controllerTag,
  });

  final FeedScreenController controller;
  final String? controllerTag;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.posts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.appColor,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: controller.posts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: Get.height * 0.18),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.appColor.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          Icons.dynamic_feed_rounded,
                          size: 30,
                          color: AppColors.appColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No posts yet',
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 15,
                          fontColor: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Be the first to share something with your community.',
                        textAlign: TextAlign.center,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: AppColors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            )
          : ListView.builder(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 18),
              itemCount: controller.posts.length +
                  (controller.isPaginationLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.posts.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.appColor,
                      ),
                    ),
                  );
                }

                final post = controller.posts[index];
                return _FeedPostCard(
                  post: post,
                  controller: controller,
                  controllerTag: controllerTag,
                ).paddingOnly(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  top: index == 0 ? 2 : 0,
                );
              },
            ),
    );
  }
}

class _ComposerView extends StatelessWidget {
  const _ComposerView({
    required this.controller,
    required this.controllerTag,
  });

  final FeedScreenController controller;
  final String? controllerTag;

  @override
  Widget build(BuildContext context) {
    String profileImage =
        (Database.fetchLoginUserProfileModel?.user?.profilePic ?? '')
            .toString();
    final listenerProfileImage =
        (Database.fetchListenerProfileModel?.data?.image ?? '').toString();
    final isListener =
        Database.fetchLoginUserProfileModel?.user?.isListener == true ||
            Database.isListener;
    final hasExpertFilter = (controller.expertIdFilter ?? '').trim().isNotEmpty;

    if (controllerTag == 'hostFeed' || hasExpertFilter || isListener) {
      if (listenerProfileImage.trim().isNotEmpty) {
        profileImage = listenerProfileImage;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: controller.openMyPostsManager,
                borderRadius: BorderRadius.circular(26),
                child: SizedBox(
                  height: 52,
                  width: 52,
                  child: ClipOval(
                    child: CustomProfileImage(
                      image: profileImage,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller.postInputController,
                  maxLines: 1,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: AppFontStyle.fontStyleW500(
                      fontSize: 14,
                      fontColor: AppColors.grey.withValues(alpha: 0.95),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xffF1F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: AppColors.appColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (controller.selectedMediaFile != null)
            Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  controller.selectedMediaType == 'image'
                      ? Image.file(
                          controller.selectedMediaFile!,
                          width: Get.width,
                          height: 190,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: Get.width,
                          height: 132,
                          color: AppColors.black.withValues(alpha: 0.86),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_fill_rounded,
                                color: AppColors.white,
                                size: 34,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Video attached',
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 14,
                                    fontColor: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  IconButton(
                    onPressed: controller.clearComposerMedia,
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                  ).paddingOnly(top: 6, right: 6),
                ],
              ),
            ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: _ComposerActionButton(
                      onPressed: controller.isCreatingPost
                          ? null
                          : controller.pickImageFromGallery,
                      icon: Icons.image_outlined,
                      label: 'Image',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ComposerActionButton(
                      onPressed: controller.isCreatingPost
                          ? null
                          : controller.pickVideoFromGallery,
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                    ),
                  ),
                  const SizedBox(width: 10),
                  _PostPrimaryButton(
                    isLoading: controller.isCreatingPost,
                    onTap: controller.isCreatingPost
                        ? null
                        : controller.createPost,
                    isCompact: constraints.maxWidth < 370,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ComposerActionButton extends StatelessWidget {
  const _ComposerActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: const Color(0xffF6F7FA),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.7),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: AppColors.appColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 13,
                      fontColor: AppColors.appColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostPrimaryButton extends StatelessWidget {
  const _PostPrimaryButton({
    required this.isLoading,
    required this.onTap,
    required this.isCompact,
  });

  final bool isLoading;
  final VoidCallback? onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        width: isCompact ? 86 : 90,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff111329),
              Color(0xff1C2046),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Post',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 14,
                  fontColor: AppColors.white,
                ),
              ),
      ),
    );
  }
}

class _FeedPostCard extends StatelessWidget {
  const _FeedPostCard({
    required this.post,
    required this.controller,
    required this.controllerTag,
  });

  final FeedPostItem post;
  final FeedScreenController controller;
  final String? controllerTag;

  @override
  Widget build(BuildContext context) {
    final isMine = controller.isMyPost(post);
    final showFollowButton = !isMine && post.expertId.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _openAuthorProfile(post: post),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: ClipOval(
                          child:
                              CustomProfileImage(image: post.authorProfilePic),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.displayName,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 15,
                                fontColor: AppColors.black,
                              ),
                            ),
                            Text(
                              _relativeTime(post.createdAt),
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 12,
                                fontColor: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showFollowButton)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.appColor.withValues(alpha: 0.08),
                  ),
                  child: TextButton(
                    onPressed: () => controller.toggleFollowForPost(post),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(10, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      controller.isFollowingExpert(post.expertId)
                          ? 'Following'
                          : 'Follow',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 11,
                        fontColor: AppColors.appColor,
                      ),
                    ),
                  ),
                ),
              InkWell(
                onTap: () => _openPostActionSheet(
                  context: context,
                  post: post,
                  controller: controller,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          if (post.content.trim().isNotEmpty)
            Text(
              post.content,
              style: AppFontStyle.fontStyleW500(
                fontSize: 15,
                fontColor: AppColors.black,
                height: 1.45,
              ),
            ).paddingOnly(top: 10),
          if (post.mediaUrls.isNotEmpty)
            _PostMediaView(post: post).paddingOnly(top: 10),
          Row(
            children: [
              _MetaPill(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.red,
                label: '${post.likeCount}',
              ),
              const SizedBox(width: 6),
              _MetaPill(
                icon: Icons.mode_comment_outlined,
                iconColor: AppColors.darkGrey,
                label: '${post.commentCount}',
              ),
              const SizedBox(width: 6),
              _MetaPill(
                icon: Icons.share_outlined,
                iconColor: AppColors.darkGrey,
                label: '${post.shareCount}',
              ),
              const Spacer(),
              Text(
                _relativeTime(post.createdAt),
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: AppColors.grey,
                ),
              ),
            ],
          ).paddingOnly(top: 10),
          Divider(
            color: AppColors.borderColor.withValues(alpha: 0.6),
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child: _PostActionButton(
                  icon: Icons.favorite_border_rounded,
                  label: 'Like',
                  active: post.isLikedByMe,
                  onTap: () => controller.toggleLike(post),
                ),
              ),
              Expanded(
                child: _PostActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Comment',
                  onTap: () => _openCommentSheet(
                    context: context,
                    post: post,
                    controllerTag: controllerTag,
                  ),
                ),
              ),
              Expanded(
                child: _PostActionButton(
                  icon: Icons.send_rounded,
                  label: 'Share',
                  onTap: () => controller.sharePost(post),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openAuthorProfile({
    required FeedPostItem post,
  }) {
    final expertId = post.expertId.trim();
    final userId = post.userId.trim();
    final targetUserId = expertId.isNotEmpty ? '' : userId;

    if (expertId.isEmpty && userId.isEmpty) {
      final activeContext = Get.context;
      if (activeContext != null) {
        Utils.showToast(activeContext, 'Profile unavailable right now.');
      }
      return;
    }

    Get.toNamed(
      AppRoutes.feedAuthorProfileScreen,
      arguments: {
        'userId': targetUserId,
        'expertId': expertId,
        'name': post.displayName,
        'profilePic': post.authorProfilePic,
      },
    );
  }

  void _openPostActionSheet({
    required BuildContext context,
    required FeedPostItem post,
    required FeedScreenController controller,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              if (controller.isMyPost(post))
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: AppColors.appColor),
                  title: Text(
                    'Edit post',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 14,
                      fontColor: AppColors.black,
                    ),
                  ),
                  onTap: () async {
                    Get.back();

                    await Future<void>.delayed(
                      const Duration(milliseconds: 120),
                    );

                    await _openEditPostSheet(
                      post: post,
                      controller: controller,
                    );
                  },
                ),
              if (controller.isMyPost(post))
                ListTile(
                  leading: Icon(Icons.delete_outline, color: AppColors.red),
                  title: Text(
                    'Delete post',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 14,
                      fontColor: AppColors.black,
                    ),
                  ),
                  onTap: () async {
                    Get.back();
                    await controller.deletePost(post);
                  },
                ),
              ListTile(
                leading: Icon(Icons.flag_outlined, color: AppColors.darkGrey),
                title: Text(
                  'Report post',
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 14,
                    fontColor: AppColors.black,
                  ),
                ),
                onTap: () {
                  Get.back();
                  ReportBottomSheetUi.show(
                    context: context,
                    reportType: 'feed_post',
                    targetId: post.id,
                  );
                },
              ),
            ],
          ).paddingOnly(bottom: 10),
        );
      },
    );
  }

  Future<void> _openEditPostSheet({
    required FeedPostItem post,
    required FeedScreenController controller,
  }) async {
    final activeContext = Get.context;
    if (activeContext == null) return;

    final editedContent = await showModalBottomSheet<String>(
      context: activeContext,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _EditPostSheetContent(initialContent: post.content);
      },
    );

    if (editedContent == null) return;

    await controller.editPost(
      post: post,
      content: editedContent,
    );
  }

  void _openCommentSheet({
    required BuildContext context,
    required FeedPostItem post,
    required String? controllerTag,
  }) async {
    await controller.openComments(post.id);

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      FractionallySizedBox(
        heightFactor: 0.84,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                height: 4,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Comments',
                style: AppFontStyle.fontStyleW700(
                  fontSize: 17,
                  fontColor: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: GetBuilder<FeedScreenController>(
                  id: Constant.idFeedComments,
                  tag: controllerTag,
                  builder: (commentController) {
                    final comments =
                        commentController.commentsByPostId[post.id] ??
                            <FeedCommentItem>[];

                    if (commentController.isCommentsLoading &&
                        comments.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (comments.isEmpty) {
                      return Center(
                        child: Text(
                          'No comments yet.',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 13,
                            fontColor: AppColors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 10),
                      children: comments.map((item) {
                        return _CommentTile(
                          comment: item,
                          onReply: (targetComment) =>
                              commentController.setReplyTarget(
                            commentId: targetComment.id,
                            userName: targetComment.authorName,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              GetBuilder<FeedScreenController>(
                id: Constant.idFeedComments,
                tag: controllerTag,
                builder: (commentController) {
                  return Column(
                    children: [
                      if ((commentController.replyingToUserName ?? '')
                          .trim()
                          .isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.appColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Replying to ${commentController.replyingToUserName}',
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 11,
                                    fontColor: AppColors.appColor,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: commentController.clearReplyTarget,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffF6F8FC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    commentController.commentInputController,
                                minLines: 1,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 10,
                                  ),
                                  hintText: 'Write a comment...',
                                  hintStyle: AppFontStyle.fontStyleW500(
                                    fontSize: 13,
                                    fontColor: AppColors.grey,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  commentController.submitComment(post.id),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.appColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      controller.clearReplyTarget();
      controller.openedCommentsPostId = null;
    });
  }
}

class _PostMediaView extends StatelessWidget {
  const _PostMediaView({required this.post});

  final FeedPostItem post;

  @override
  Widget build(BuildContext context) {
    if (post.mediaType == 'video') {
      final rawVideoUrl = post.mediaUrl.trim().isNotEmpty
          ? post.mediaUrl
          : (post.mediaUrls.isNotEmpty ? post.mediaUrls.first : '');
      final url = _toAbsoluteUrl(rawVideoUrl);
      return _PostVideoPlayer(url: url);
    }
    if (post.mediaUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: _toAbsoluteUrl(post.mediaUrls.first),
          width: Get.width,
          height: 230,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: Get.width,
            height: 230,
            color: AppColors.lightGrey,
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => Container(
            width: Get.width,
            height: 230,
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
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: post.mediaUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: _toAbsoluteUrl(post.mediaUrls[index]),
              width: Get.width * 0.78,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: Get.width * 0.78,
                color: AppColors.lightGrey,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _toAbsoluteUrl(String path) {
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
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xffF3F4F8).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppFontStyle.fontStyleW600(
              fontSize: 12,
              fontColor: AppColors.appColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final actionColor = active ? AppColors.appColor : AppColors.darkGrey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: active
                ? AppColors.appColor.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: actionColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 13,
                  fontColor: actionColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.onReply,
  });

  final FeedCommentItem comment;
  final ValueChanged<FeedCommentItem> onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.lightGrey,
                backgroundImage: _resolveAvatar(comment.authorProfilePic),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F8FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.75),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName.trim().isEmpty
                            ? 'User'
                            : comment.authorName,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 12,
                          fontColor: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comment.text,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12.5,
                          fontColor: AppColors.black,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _relativeTime(comment.createdAt),
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 10,
                              fontColor: AppColors.grey,
                            ),
                          ),
                          const SizedBox(width: 14),
                          InkWell(
                            onTap: () => onReply(comment),
                            child: Text(
                              'Reply',
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 11,
                                fontColor: AppColors.appColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty)
            Column(
              children: comment.replies.map((reply) {
                return Container(
                  margin: const EdgeInsets.only(left: 34, top: 6),
                  child: _CommentTile(
                    comment: reply,
                    onReply: onReply,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  ImageProvider? _resolveAvatar(String value) {
    final path = value.trim();
    if (path.isEmpty) return null;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    final joined = path.startsWith('/')
        ? '${Api.baseUrl}${path.substring(1)}'
        : '${Api.baseUrl}$path';

    return NetworkImage(joined);
  }
}

String _relativeTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  final diff = DateTime.now().difference(dateTime);

  if (diff.inSeconds < 60) return '${diff.inSeconds}s';
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

class _PostVideoPlayer extends StatefulWidget {
  const _PostVideoPlayer({required this.url});
  final String url;

  @override
  State<_PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<_PostVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isInitializing = false;
  bool _controllerCreated = false;
  static const double _targetAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.url.trim();
    if (videoUrl.isEmpty) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _initialized = false;
        _isInitializing = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _hasError = false;
      _initialized = false;
      _isInitializing = true;
    });

    if (_controllerCreated) {
      _controller.dispose();
      _controllerCreated = false;
    }

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controllerCreated = true;

      await _controller.initialize().timeout(const Duration(seconds: 12));

      if (!mounted) return;
      setState(() {
        _initialized = true;
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _initialized = false;
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    if (_controllerCreated) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized || !_controllerCreated) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  Future<void> _openFullScreen() async {
    if (!_initialized || !_controllerCreated) return;

    final wasPlaying = _controller.value.isPlaying;
    final currentPosition = _controller.value.position;

    _controller.pause();
    setState(() {});

    final result =
        await Navigator.of(context).push<_FeedFullscreenPlaybackResult>(
      MaterialPageRoute(
        builder: (_) => _FeedFullscreenVideoPlayer(
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
    if (_hasError) {
      return GestureDetector(
        onTap: _initializeVideo,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _targetAspectRatio,
            child: Container(
              width: Get.width,
              color: AppColors.black.withValues(alpha: 0.88),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off_rounded,
                    color: AppColors.white.withValues(alpha: 0.9),
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to retry',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 12,
                      fontColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isInitializing || !_initialized) {
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

class _FeedFullscreenPlaybackResult {
  const _FeedFullscreenPlaybackResult({
    required this.position,
    required this.wasPlaying,
  });

  final Duration position;
  final bool wasPlaying;
}

class _FeedFullscreenVideoPlayer extends StatefulWidget {
  const _FeedFullscreenVideoPlayer({
    required this.url,
    required this.initialPosition,
    required this.autoPlay,
  });

  final String url;
  final Duration initialPosition;
  final bool autoPlay;

  @override
  State<_FeedFullscreenVideoPlayer> createState() =>
      _FeedFullscreenVideoPlayerState();
}

class _FeedFullscreenVideoPlayerState
    extends State<_FeedFullscreenVideoPlayer> {
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
      _FeedFullscreenPlaybackResult(
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

    return PopScope<_FeedFullscreenPlaybackResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closePlayer();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
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
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _closePlayer,
                              icon: const Icon(
                                Icons.fullscreen_exit_rounded,
                                color: Colors.white,
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
                            color: Colors.white,
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
                                  activeTrackColor: Colors.redAccent,
                                  inactiveTrackColor:
                                      Colors.white.withValues(alpha: 0.35),
                                  thumbColor: Colors.white,
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
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '/ ${_formatDuration(duration)}',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
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

class _EditPostSheetContent extends StatefulWidget {
  const _EditPostSheetContent({required this.initialContent});
  final String initialContent;

  @override
  State<_EditPostSheetContent> createState() => _EditPostSheetContentState();
}

class _EditPostSheetContentState extends State<_EditPostSheetContent> {
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit post',
              style: AppFontStyle.fontStyleW700(
                fontSize: 16,
                fontColor: AppColors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 6,
              minLines: 3,
              maxLength: 4000,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: AppFontStyle.fontStyleW500(
                  fontSize: 13,
                  fontColor: AppColors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.appColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: textController.text);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/user_flow/chat_screen/api/chat_list_api.dart';
import 'package:notisboard/ui/user_flow/chat_screen/model/chat_list_response_model.dart';
import 'package:notisboard/ui/user_flow/profile_detail_screen/api/listener_profile_api.dart';
import 'package:notisboard/ui/user_flow/profile_detail_screen/model/listener_profile_response_model.dart';
import 'package:notisboard/utils/constant.dart';

class ChatScreenController extends GetxController {
  ChatListResponseModel? chatListResponseModel;
  bool isLoading = false;
  List<ChatList> chatList = [];
  final Map<String, bool> _verifiedBadgeCache = {};

  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    log("Enter chat screen Controller");
    scrollController.addListener(onTopListenersPagination);
    ChatListApi.startPagination = 0;

    getChatList(); // Initial load of chat list
  }

  /// chat list user

  getChatList() async {
    isLoading = true;
    update([Constant.idChatList]);

    chatListResponseModel = await ChatListApi.callApi();
    final fetchedChats = chatListResponseModel?.chatList ?? [];
    chatList.addAll(fetchedChats);
    log("Chat List Loaded: $chatList");

    isLoading = false;
    update([Constant.idChatList]);

    await _syncVerifiedBadgesForChats(fetchedChats);
  }

  onRefresh() async {
    ChatListApi.startPagination = 0;
    _verifiedBadgeCache.clear();
    chatList.clear();
    await getChatList();
  }

  Future<void> _syncVerifiedBadgesForChats(List<ChatList> chats) async {
    final pendingChats = chats.where((chat) {
      final receiverId = (chat.receiverId ?? '').trim();
      return receiverId.isNotEmpty && chat.isVerifiedBadge != true;
    }).toList();

    if (pendingChats.isEmpty) return;

    var hasUpdatedBadge = false;

    await Future.wait(
      pendingChats.map((chat) async {
        final receiverId = (chat.receiverId ?? '').trim();
        final cachedBadge = _verifiedBadgeCache[receiverId];

        if (cachedBadge != null) {
          if (chat.isVerifiedBadge != cachedBadge) {
            chat.isVerifiedBadge = cachedBadge;
            hasUpdatedBadge = true;
          }
          return;
        }

        final isVerified = await _fetchVerifiedBadge(receiverId);
        _verifiedBadgeCache[receiverId] = isVerified;

        if (chat.isVerifiedBadge != isVerified) {
          chat.isVerifiedBadge = isVerified;
          hasUpdatedBadge = true;
        }
      }),
    );

    if (hasUpdatedBadge) {
      update([Constant.idChatList]);
    }
  }

  Future<bool> _fetchVerifiedBadge(String receiverId) async {
    try {
      var profile = await ListenerProfileApi.callApi(listenerId: receiverId);

      if (!_hasProfileData(profile)) {
        profile = await ListenerProfileApi.callApi(expertId: receiverId);
      }

      return _isProfileVerified(profile);
    } catch (e, stackTrace) {
      log(
        "Chat verified badge sync failed",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  bool _hasProfileData(ListenerProfileModel? profile) {
    return profile?.status == true && profile?.data != null;
  }

  bool _isProfileVerified(ListenerProfileModel? profile) {
    final data = profile?.data;
    final badgeType = (data?.verifiedBadgeType ?? '').trim().toLowerCase();

    return data?.isVerifiedBadge == true ||
        (badgeType.isNotEmpty && badgeType != 'none');
  }

  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);
      await getChatList();
      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }
}

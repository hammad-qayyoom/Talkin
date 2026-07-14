import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/common/blog_news/api/fetch_blog_news_api.dart';
import 'package:notisboard/ui/common/blog_news/model/blog_news_model.dart';
import 'package:notisboard/utils/constant.dart';

class BlogNewsController extends GetxController {
  List<BlogNewsItem> blogList = [];
  bool isLoading = true;
  bool isMoreLoading = false;
  int page = 1;
  bool hasMore = true;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  BlogNewsItem? currentDetailItem;
  bool isDetailLoading = false;

  @override
  void onInit() {
    super.onInit();
    fetchBlogList();
  }

  Future<void> fetchBlogList({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
      hasMore = true;
    } else if (page == 1) {
      isLoading = true;
      update([Constant.idBlogNewsList]);
    }

    final response = await FetchBlogNewsApi.callGetBlogs(
      page: page,
      limit: 15,
      search: searchQuery,
    );

    if (response != null && response.status == true && response.data != null) {
      if (page == 1) {
        blogList = response.data!;
      } else {
        blogList.addAll(response.data!);
      }
      hasMore = response.data!.length >= 15;
    } else {
      if (page == 1) {
        blogList = [];
      }
      hasMore = false;
    }

    isLoading = false;
    isMoreLoading = false;
    update([Constant.idBlogNewsList]);
  }

  Future<void> fetchMoreBlogs() async {
    if (isMoreLoading || !hasMore || isLoading) return;
    isMoreLoading = true;
    page++;
    update([Constant.idBlogNewsList]);
    await fetchBlogList();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    page = 1;
    hasMore = true;
    isLoading = true;
    update([Constant.idBlogNewsList]);
    fetchBlogList();
  }

  Future<void> fetchBlogDetail({
    required String slugOrId,
    BlogNewsItem? initialItem,
  }) async {
    if (initialItem != null) {
      currentDetailItem = initialItem;
      isDetailLoading = false;
      update([Constant.idBlogNewsDetail]);
    } else {
      isDetailLoading = true;
      update([Constant.idBlogNewsDetail]);
    }

    final response = await FetchBlogNewsApi.callGetBlogDetail(slugOrId: slugOrId);
    if (response != null && response.status == true && response.data != null) {
      currentDetailItem = response.data;
      // update item in list if exists
      final index = blogList.indexWhere((element) =>
          element.slug == currentDetailItem?.slug ||
          element.id == currentDetailItem?.id);
      if (index != -1 && currentDetailItem != null) {
        blogList[index] = currentDetailItem!;
        update([Constant.idBlogNewsList]);
      }
    }
    isDetailLoading = false;
    update([Constant.idBlogNewsDetail]);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

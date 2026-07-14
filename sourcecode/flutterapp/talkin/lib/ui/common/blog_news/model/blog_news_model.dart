class BlogNewsListModel {
  bool? status;
  String? message;
  int? total;
  List<BlogNewsItem>? data;

  BlogNewsListModel({
    this.status,
    this.message,
    this.total,
    this.data,
  });

  BlogNewsListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message']?.toString();
    total = json['total'] != null ? int.tryParse(json['total'].toString()) : null;
    if (json['data'] != null) {
      data = <BlogNewsItem>[];
      json['data'].forEach((v) {
        data!.add(BlogNewsItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BlogNewsDetailModel {
  bool? status;
  String? message;
  BlogNewsItem? data;

  BlogNewsDetailModel({
    this.status,
    this.message,
    this.data,
  });

  BlogNewsDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message']?.toString();
    data = json['data'] != null ? BlogNewsItem.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BlogNewsItem {
  String? id;
  String? title;
  String? slug;
  String? summary;
  String? content;
  String? coverImage;
  String? author;
  String? publishedAt;
  String? createdAt;
  int? views;

  BlogNewsItem({
    this.id,
    this.title,
    this.slug,
    this.summary,
    this.content,
    this.coverImage,
    this.author,
    this.publishedAt,
    this.createdAt,
    this.views,
  });

  BlogNewsItem.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString() ?? json['id']?.toString();
    title = json['title']?.toString();
    slug = json['slug']?.toString();
    summary = json['summary']?.toString();
    content = json['content']?.toString();
    coverImage = json['coverImage']?.toString();
    author = json['author']?.toString();
    publishedAt = json['publishedAt']?.toString();
    createdAt = json['createdAt']?.toString();
    views = json['views'] != null ? int.tryParse(json['views'].toString()) ?? 0 : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['summary'] = summary;
    data['content'] = content;
    data['coverImage'] = coverImage;
    data['author'] = author;
    data['publishedAt'] = publishedAt;
    data['createdAt'] = createdAt;
    data['views'] = views;
    return data;
  }
}

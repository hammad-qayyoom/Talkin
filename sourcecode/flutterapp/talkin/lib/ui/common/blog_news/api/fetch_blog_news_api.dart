import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:notisboard/ui/common/blog_news/model/blog_news_model.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/utils.dart';

class FetchBlogNewsApi {
  static Future<BlogNewsListModel?> callGetBlogs({
    int page = 1,
    int limit = 20,
    String search = "",
  }) async {
    Utils.showLog("Get Blog News List Api Calling... page: \$page");

    final Map<String, dynamic> queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };

    String query = Uri(queryParameters: queryParameters).query;
    final uri = Uri.parse(Api.getPublicBlogs + (query.isNotEmpty ? query : ''));

    final headers = {
      "key": Api.secretKey,
      "Content-Type": "application/json",
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        log("Get Blog News List Response => \${response.body}");
        return BlogNewsListModel.fromJson(json.decode(response.body));
      } else {
        Utils.showLog("Get Blog News List StatusCode Error: \${response.statusCode}");
      }
    } catch (error) {
      Utils.showLog("Get Blog News List Api Error => \$error");
    }
    return null;
  }

  static Future<BlogNewsDetailModel?> callGetBlogDetail({
    required String slugOrId,
  }) async {
    Utils.showLog("Get Blog News Detail Api Calling... slugOrId: \$slugOrId");

    final uri = Uri.parse("\${Api.getPublicBlogBySlug}\$slugOrId");

    final headers = {
      "key": Api.secretKey,
      "Content-Type": "application/json",
    };

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        log("Get Blog News Detail Response => \${response.body}");
        return BlogNewsDetailModel.fromJson(json.decode(response.body));
      } else {
        Utils.showLog("Get Blog News Detail StatusCode Error: \${response.statusCode}");
      }
    } catch (error) {
      Utils.showLog("Get Blog News Detail Api Error => \$error");
    }
    return null;
  }
}

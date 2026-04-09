import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';

class FeedApi {
  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAccessToken.onGet();

    return {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: 'Bearer $token',
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: 'application/json',
    };
  }

  static Future<Map<String, dynamic>> fetchFeed({
    int start = 1,
    int limit = 10,
    String? userId,
    String? expertId,
  }) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(Api.feedPostsFeed).replace(
        queryParameters: {
          'start': '$start',
          'limit': '$limit',
          if ((userId ?? '').trim().isNotEmpty) 'userId': userId,
          if ((expertId ?? '').trim().isNotEmpty) 'expertId': expertId,
        },
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid feed response format.',
      };
    } catch (e) {
      debugPrint('Feed fetch error: $e');
      return {
        'status': false,
        'message': 'Failed to fetch feed posts. $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required String content,
    File? mediaFile,
  }) async {
    try {
      final token = await FirebaseAccessToken.onGet();
      final request =
          http.MultipartRequest('POST', Uri.parse(Api.feedPostsCreate));

      request.headers.addAll({
        ApiParams.key: Api.secretKey,
        ApiParams.authToken: 'Bearer $token',
        ApiParams.authUid: Database.loginUserFirebaseId,
      });

      if (content.trim().isNotEmpty) {
        request.fields['content'] = content.trim();
      }

      if (mediaFile != null && await mediaFile.exists()) {
        final path = mediaFile.path.toLowerCase();
        final isVideo = path.endsWith('.mp4') ||
            path.endsWith('.mov') ||
            path.endsWith('.mkv') ||
            path.endsWith('.webm') ||
            path.endsWith('.avi');
        final isPng = path.endsWith('.png');
        final isGif = path.endsWith('.gif');

        request.files.add(await http.MultipartFile.fromPath(
          'media',
          mediaFile.path,
          contentType: MediaType(
            isVideo ? 'video' : 'image',
            isVideo ? 'mp4' : (isPng ? 'png' : (isGif ? 'gif' : 'jpeg')),
          ),
        ));
      }

      final streamed = await request.send();
      final responseText = await streamed.stream.bytesToString();
      final decoded = json.decode(responseText);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid create post response format.',
      };
    } catch (e) {
      debugPrint('Feed create post error: $e');
      return {
        'status': false,
        'message': 'Failed to create post. $e',
      };
    }
  }

  static Future<Map<String, dynamic>> likePost({
    required String postId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.feedPostsLike),
        headers: headers,
        body: json.encode({
          'postId': postId,
        }),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid like response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to like post.',
      };
    }
  }

  static Future<Map<String, dynamic>> sharePost({
    required String postId,
    String channel = 'external',
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.feedPostsShare),
        headers: headers,
        body: json.encode({
          'postId': postId,
          'channel': channel,
        }),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid share response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to share post.',
      };
    }
  }

  static Future<Map<String, dynamic>> deletePost({
    required String postId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.delete(
        Uri.parse('${Api.feedPostsDeletePrefix}$postId'),
        headers: headers,
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid delete response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to delete post.',
      };
    }
  }

  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String content,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.patch(
        Uri.parse('${Api.feedPostsDeletePrefix}$postId'),
        headers: headers,
        body: json.encode({
          'content': content,
        }),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid update response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to update post.',
      };
    }
  }

  static Future<Map<String, dynamic>> reportPost({
    required String postId,
    required String reasonCode,
    String? reasonText,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.moderationReportFeedPost),
        headers: headers,
        body: json.encode({
          'reportType': 'feed_post',
          'targetId': postId,
          'reasonCode': reasonCode,
          if ((reasonText ?? '').trim().isNotEmpty) 'reasonText': reasonText,
        }),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid report response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to report post.',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchComments({
    required String postId,
  }) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(Api.feedCommentsList).replace(
        queryParameters: {
          'postId': postId,
          'start': '1',
          'limit': '100',
          'includeReplies': 'true',
        },
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid comments response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch comments.',
      };
    }
  }

  static Future<Map<String, dynamic>> createComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.feedCommentsCreate),
        headers: headers,
        body: json.encode({
          'postId': postId,
          'text': text,
          if ((parentCommentId ?? '').trim().isNotEmpty)
            'parentCommentId': parentCommentId,
        }),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid create comment response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to add comment.',
      };
    }
  }

  static Future<Map<String, dynamic>> followExpert({
    required String expertId,
    bool? follow,
  }) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse(Api.feedExpertsFollow),
        headers: headers,
        body: json.encode({
          'expertId': expertId,
          if (follow != null) 'follow': follow,
        }),
      );
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid follow response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to update follow.',
      };
    }
  }

  static Future<Map<String, dynamic>> listFollowingExperts({
    int start = 1,
    int limit = 100,
  }) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse(Api.feedExpertsFollowing).replace(
        queryParameters: {
          'start': '$start',
          'limit': '$limit',
        },
      );

      final response = await http.get(uri, headers: headers);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'status': false,
        'message': 'Invalid following response format.',
      };
    } catch (_) {
      return {
        'status': false,
        'message': 'Failed to fetch following experts.',
      };
    }
  }
}

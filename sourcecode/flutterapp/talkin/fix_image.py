import re
with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/controller/feed_screen_controller.dart', 'r') as f:
    text = f.read()

replacement = """
      final expert = (json['authorExpertId'] != null)
          ? json['authorExpertId'] as Map<String, dynamic>
          : (json['expert'] != null && json['expert'] is Map ? json['expert'] as Map<String, dynamic> : <String, dynamic>{});
          
      final hasExpert = expert.isNotEmpty && (expert['id']?.toString().isNotEmpty == true || expert['_id']?.toString().isNotEmpty == true);

      final resolvedAuthorName = hasExpert
          ? (expert['displayName'] ?? '').toString()
          : (user['fullName'] ?? '').toString();

      final resolvedAuthorNick =
          hasExpert ? '' : (user['nickName'] ?? '').toString();

      final resolvedAuthorProfile = hasExpert
          ? (expert['profileImage'] ?? expert['image'] ?? user['profilePic'] ?? '').toString()
          : (user['profilePic'] ?? '').toString();
"""

old_code = """      final expert = json['expert'] is Map<String, dynamic>
          ? json['expert'] as Map<String, dynamic>
          : <String, dynamic>{};

      final hasExpert = expert.isNotEmpty && expert['id'].toString().isNotEmpty;

      final resolvedAuthorName = hasExpert
          ? (expert['displayName'] ?? '').toString()
          : (user['fullName'] ?? '').toString();

      final resolvedAuthorNick =
          hasExpert ? '' : (user['nickName'] ?? '').toString();

      final resolvedAuthorProfile = hasExpert
          ? (expert['profileImage'] ?? expert['image'] ?? '').toString()
          : (user['profilePic'] ?? '').toString();"""

text = text.replace(old_code, replacement)

with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/controller/feed_screen_controller.dart', 'w') as f:
    f.write(text)

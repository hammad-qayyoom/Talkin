import re
with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/controller/feed_screen_controller.dart', 'r') as f:
    text = f.read()

replacement = """      final expert = json['expert'] is Map<String, dynamic>
          ? json['expert'] as Map<String, dynamic>
          : <String, dynamic>{};

      final hasExpert = expert.isNotEmpty && expert['id'].toString().isNotEmpty;

      final resolvedAuthorName = hasExpert
          ? (expert['displayName'] ?? '').toString()
          : (user['fullName'] ?? '').toString();

      final resolvedAuthorNick = hasExpert
          ? ''
          : (user['nickName'] ?? '').toString();

      final resolvedAuthorProfile = hasExpert
          ? (expert['profileImage'] ?? expert['image'] ?? '').toString()
          : (user['profilePic'] ?? '').toString();

      final mediaList = json['mediaUrls'] is List<dynamic>"""

text = re.sub(r'(\s+)final mediaList = json\[\'mediaUrls\'\] is List<dynamic>', replacement, text)

text = re.sub(r'authorName: \(user\[\'fullName\'\] \?\? \'\'\)\.toString\(\),', r"authorName: resolvedAuthorName,", text)
text = re.sub(r'authorNickName: \(user\[\'nickName\'\] \?\? \'\'\)\.toString\(\),', r"authorNickName: resolvedAuthorNick,", text)
text = re.sub(r'authorProfilePic: \(user\[\'profilePic\'\] \?\? \'\'\)\.toString\(\),', r"authorProfilePic: resolvedAuthorProfile,", text)

with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/controller/feed_screen_controller.dart', 'w') as f:
    f.write(text)

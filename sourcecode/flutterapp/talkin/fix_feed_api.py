import re
with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/api/feed_api.dart', 'r') as f:
    text = f.read()

# Fix headers
text = re.sub(r'(\s+)ApiParams\.key: Api\.secretKey,', r'\1return {\n\1ApiParams.key: Api.secretKey,', text)

# Fix returns
text = re.sub(r'(\s+)\'status\': false,', r'\1return {\n\1\'status\': false,', text)

# Fix catch blocks
text = re.sub(r'catch \(e\) \{ print\("API CREATE ERROR: \$e"\);  "status": false, "message": "Failed to create post. \$e" \};', r'catch (e) {\n        print("API CREATE ERROR: $e");\n        return {\n          "status": false,\n          "message": "Failed to create post. $e",\n        };\n      }', text)

with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/api/feed_api.dart', 'w') as f:
    f.write(text)

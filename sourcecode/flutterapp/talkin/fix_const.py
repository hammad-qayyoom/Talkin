import re
with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/view/feed_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("const Center(\n          child: CircularProgressIndicator(color: AppColors.white),", "Center(\n          child: CircularProgressIndicator(color: AppColors.white),")
text = text.replace("const Center(\n                    child: Icon(\n                      Icons.play_circle_fill_rounded,\n                      color: AppColors.white,", "Center(\n                    child: Icon(\n                      Icons.play_circle_fill_rounded,\n                      color: AppColors.white,")

with open('/Users/hammadqayyoom/Projects/Talkin/sourcecode/flutterapp/talkin/lib/ui/user_flow/feed_screen/view/feed_screen.dart', 'w') as f:
    f.write(text)

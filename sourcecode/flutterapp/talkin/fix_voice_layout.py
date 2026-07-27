import re

file_path = "/Users/hammadqayyoom/Projects/Notisboard/sourcecode/flutterapp/talkin/lib/ui/user_flow/voice_call_screen/widget/voice_call_widget.dart"
with open(file_path, "r") as f:
    content = f.read()

old_row = """                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0;
                                      i < actionItems.length;
                                      i++) ...[
                                    actionItems[i],
                                    if (i != actionItems.length - 1)
                                      SizedBox(width: controlGap),
                                  ],
                                ],
                              ),"""

new_row = """                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (var i = 0; i < actionItems.length - 1; i++) ...[
                                            actionItems[i],
                                            SizedBox(width: controlGap),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  actionItems.last,
                                ],
                              ),"""

if old_row in content:
    content = content.replace(old_row, new_row)
    with open(file_path, "w") as f:
        f.write(content)
    print("Success")
else:
    print("Could not find row pattern in voice_call_widget.dart")

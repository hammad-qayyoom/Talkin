import re

file_path = "/Users/hammadqayyoom/Projects/Notisboard/sourcecode/flutterapp/talkin/lib/ui/user_flow/video_call_screen/widget/video_call_widget.dart"
with open(file_path, "r") as f:
    content = f.read()

old_row = """                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: ["""

new_row = """                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: ["""

content = content.replace(old_row, new_row)

old_end_call = """                            SizedBox(width: controlGap),
                            ControlButton(
                              iconData: Icons.call_end_rounded,
                              isDanger: true,
                              size: dangerControlSize,
                              onTap: logic.endCurrentCall,
                            ),
                          ],
                        ),"""

new_end_call = """                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: controlGap),
                            ControlButton(
                              iconData: Icons.call_end_rounded,
                              isDanger: true,
                              size: dangerControlSize,
                              onTap: logic.endCurrentCall,
                            ),
                          ],
                        ),"""

content = content.replace(old_end_call, new_end_call)

with open(file_path, "w") as f:
    f.write(content)

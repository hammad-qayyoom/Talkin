import re

file_path = "/Users/hammadqayyoom/Projects/Notisboard/sourcecode/flutterapp/talkin/lib/ui/user_flow/video_call_screen/view/video_call_screen.dart"
with open(file_path, "r") as f:
    content = f.read()

# Replace Controller definition
content = content.replace("late final VideoCallController controller;", "late final VideoCallController controller;\n  bool wasCameraOnBeforeBackground = false;")

# Replace didChangeAppLifecycleState
old_lifecycle = """  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log("App went to background");
      // App went to background
      controller.endCallDueToBackground();
    }
  }"""

new_lifecycle = """  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("🔄 App Lifecycle State: $state");

    switch (state) {
      case AppLifecycleState.paused:
        log("📱 App went to BACKGROUND");
        if (!controller.isScreenSharing) {
          wasCameraOnBeforeBackground = !controller.isCameraOff;
          if (!controller.isCameraOff) {
            controller.onCameraOff();
            log("📷 Camera turned OFF (background)");
          }
        }
        break;

      case AppLifecycleState.resumed:
        log("📱 App came to FOREGROUND");
        if (!controller.isScreenSharing && wasCameraOnBeforeBackground && controller.isCameraOff) {
          controller.onCameraOff();
          log("📷 Camera restored to ON (foreground)");
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }"""

content = content.replace(old_lifecycle, new_lifecycle)

with open(file_path, "w") as f:
    f.write(content)

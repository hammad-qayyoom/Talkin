import re

file_path = "/Users/hammadqayyoom/Projects/Notisboard/sourcecode/flutterapp/talkin/lib/ui/user_flow/voice_call_screen/view/voice_call_screen.dart"
with open(file_path, "r") as f:
    content = f.read()

# Replace Controller definition to add wasCameraOnBeforeBackground
# VoiceCall doesn't have camera in the same way, but it might have screen sharing now.
# We will just remove the endCallDueToBackground completely or conditionally.
old_lifecycle = """  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log("App went to background");
      // App went to background
      ///call not cut in background app comment this
      controller.endCallDueToBackground();
    }
  }"""

new_lifecycle = """  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("🔄 App Lifecycle State: $state");
    // Voice call should not cut in background, especially if screen sharing
  }"""

content = content.replace(old_lifecycle, new_lifecycle)

with open(file_path, "w") as f:
    f.write(content)

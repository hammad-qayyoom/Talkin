import re

file_path = "/Users/hammadqayyoom/Projects/Notisboard/sourcecode/flutterapp/talkin/lib/ui/user_flow/voice_call_screen/widget/voice_call_widget.dart"
with open(file_path, "r") as f:
    content = f.read()

# 1. Add screen share toggle button in actionItems
button_code = """                GetBuilder<TranslationService>(
                  id: Constant.idTranslation,
                  builder: (service) {
                    return buildControlButton(
                      iconData: Icons.translate,
                      isActive: service.isActive,
                      onTap: () {
                        if (!service.isEnabled) {
                          Utils.showToast(context, "Translation is not enabled. Please check settings.");
                          return;
                        }
                        controller.toggleTranslation();
                      },
                      size: controlSize,
                    );
                  },
                ),
                GetBuilder<VoiceCallController>(
                  id: Constant.idVideoCall,
                  builder: (logic) {
                    if (!logic.canScreenShare) return const SizedBox.shrink();
                    return buildControlButton(
                      iconData: logic.isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                      isActive: logic.isScreenSharing,
                      onTap: () {
                        logic.toggleScreenShare();
                      },
                      size: controlSize,
                    );
                  },
                ),"""

content = content.replace("""                GetBuilder<TranslationService>(
                  id: Constant.idTranslation,
                  builder: (service) {
                    return buildControlButton(
                      iconData: Icons.translate,
                      isActive: service.isActive,
                      onTap: () {
                        if (!service.isEnabled) {
                          Utils.showToast(context, "Translation is not enabled. Please check settings.");
                          return;
                        }
                        controller.toggleTranslation();
                      },
                      size: controlSize,
                    );
                  },
                ),""", button_code)

# 2. Add remote view
old_background = """                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.redesignScreenBackground,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.white,
                            AppColors.redesignScreenBackground,
                            AppColors.redesignScreenBackground,
                          ],
                        ),
                      ),
                    ),
                  ),"""

new_background = """                  Positioned.fill(
                    child: GetBuilder<VoiceCallController>(
                      id: Constant.idVideoCall,
                      builder: (logic) {
                        if (logic.remoteIsScreenSharing && logic.remoteView != null) {
                          return Container(
                            color: Colors.black,
                            child: logic.remoteView,
                          );
                        }
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.redesignScreenBackground,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.white,
                                AppColors.redesignScreenBackground,
                                AppColors.redesignScreenBackground,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),"""

content = content.replace(old_background, new_background)

# 3. Replace the Expanded( child: SingleChildScrollView( to use GetBuilder
lines = content.split('\n')
for i in range(len(lines)):
    if "child: SingleChildScrollView(" in lines[i] and "Expanded(" in lines[i-1]:
        lines[i] = """                        child: GetBuilder<VoiceCallController>(
                          id: Constant.idVideoCall,
                          builder: (logic) {
                            if (logic.remoteIsScreenSharing && logic.remoteView != null) {
                              return const SizedBox.shrink(); // Hide the card during screen share
                            }
                            return SingleChildScrollView("""
        break

# Now find where SingleChildScrollView closes, which is the line just before `Container(` and `margin: EdgeInsets.fromLTRB(` for the bottom tray.
# Actually we can search for:
#                           ),
#                         ),
#                       ),
#                       Container(
#                         margin: EdgeInsets.fromLTRB(

for i in range(len(lines)):
    if "Container(" in lines[i] and "margin: EdgeInsets.fromLTRB(" in lines[i+1]:
        # We found the bottom tray. The previous lines should be the closing brackets for SingleChildScrollView and Expanded.
        # lines[i-1] should be `),` # Expanded
        # lines[i-2] should be `),` # SingleChildScrollView
        if ")," in lines[i-2] and ")," in lines[i-1]:
            lines[i-2] = "                          );" # end SingleChildScrollView
            lines.insert(i-1, "                          },")
            lines.insert(i, "                        ),")
            break

with open(file_path, "w") as f:
    f.write('\n'.join(lines))

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

# 2. Add remote view and hide the big card when screen sharing
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

old_card = """                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: cardWidth),"""

new_card = """                      Expanded(
                        child: GetBuilder<VoiceCallController>(
                          id: Constant.idVideoCall,
                          builder: (logic) {
                            if (logic.remoteIsScreenSharing && logic.remoteView != null) {
                              return const SizedBox.shrink(); // Hide the card during screen share
                            }
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: cardWidth),"""

content = content.replace(old_card, new_card)

# Close the new GetBuilder
old_card_end = """                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),"""

new_card_end = """                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                          },
                        ),
                      ),"""

content = content.replace(old_card_end, new_card_end)

with open(file_path, "w") as f:
    f.write(content)

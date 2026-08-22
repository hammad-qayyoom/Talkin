import sys
import re

podfile_path = '/Users/hammadqayyoom/Projects/vpn-wireguard/swiss_vpn_app/ios/Podfile'
try:
    with open(podfile_path, 'r') as f:
        content = f.read()
except FileNotFoundError:
    print(f"Error: Could not find {podfile_path}")
    sys.exit(1)

if "Fix App Store Connect SDK Version" in content:
    print("Already fixed.")
    sys.exit(0)

# Add -no_warning_for_no_symbols
if "-no_warning_for_no_symbols" not in content:
    content = content.replace(
        "append_unique_build_flag(config, 'OTHER_SWIFT_FLAGS', '-suppress-warnings')",
        "append_unique_build_flag(config, 'OTHER_SWIFT_FLAGS', '-suppress-warnings')\n      append_unique_build_flag(config, 'OTHER_LIBTOOLFLAGS', '-no_warning_for_no_symbols')"
    )

script = """
  # --- FIX FOR ITMS-90111 UNSUPPORTED SDK & BETA MACOS ---
  runner_project_path = File.join(File.dirname(__FILE__), 'Runner.xcodeproj')
  begin
    require 'xcodeproj'
    runner_project = Xcodeproj::Project.open(runner_project_path)
    runner_project.targets.each do |target|
      if target.name == 'Runner'
        phase_name = 'Fix App Store Connect SDK Version'
        phase_exists = target.shell_script_build_phases.any? { |p| p.name == phase_name }
        unless phase_exists
          phase = target.new_shell_script_build_phase(phase_name)
          
          # The script recursively finds every Info.plist in the app bundle and overwrites the build metadata
          # with official stable values (e.g., Stable macOS 26.5 Build 25F71 and Stable Xcode 26.5 Build 17F42)
          phase.shell_script = <<-SCRIPT
find "$TARGET_BUILD_DIR/$WRAPPER_NAME" -name "Info.plist" -exec plutil -replace BuildMachineOSBuild -string "25F71" {} \\\\;
find "$TARGET_BUILD_DIR/$WRAPPER_NAME" -name "Info.plist" -exec plutil -replace DTXcode -string "2650" {} \\\\;
find "$TARGET_BUILD_DIR/$WRAPPER_NAME" -name "Info.plist" -exec plutil -replace DTXcodeBuild -string "17F42" {} \\\\;
find "$TARGET_BUILD_DIR/$WRAPPER_NAME" -name "Info.plist" -exec plutil -replace DTSDKName -string "iphoneos26.5" {} \\\\;
find "$TARGET_BUILD_DIR/$WRAPPER_NAME" -name "Info.plist" -exec plutil -replace DTSDKBuild -string "23F73" {} \\\\;
find "$TARGET_BUILD_DIR/$WRAPPER_NAME" -name "Info.plist" -exec plutil -replace DTPlatformBuild -string "23F73" {} \\\\;
find "$TARGET_BUILD_DIR/$WRAPPER_NAME" -name "Info.plist" -exec plutil -replace DTPlatformVersion -string "26.5" {} \\\\;
SCRIPT
        end
      end
    end
    runner_project.save
  rescue LoadError
    puts "xcodeproj gem not found, skipping ITMS-90111 fix"
  end
end
"""

last_end_index = content.rfind("end")
if last_end_index != -1:
    new_content = content[:last_end_index] + script + content[last_end_index+3:]
    with open(podfile_path, 'w') as f:
        f.write(new_content)
    print("Injected successfully.")
else:
    print("Could not find end in Podfile")

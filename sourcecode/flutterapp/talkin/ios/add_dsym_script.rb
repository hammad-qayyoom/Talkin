require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

runner_target = project.targets.find { |t| t.name == 'Runner' }

if runner_target
  phase_name = 'Fix Missing dSYMs'
  phase = runner_target.shell_script_build_phases.find { |p| p.name == phase_name }
  unless phase
    phase = runner_target.new_shell_script_build_phase(phase_name)
    puts "Added 'Fix Missing dSYMs' phase."
  end
  
  phase.shell_script = <<-SCRIPT
if [ -z "$DWARF_DSYM_FOLDER_PATH" ]; then
  echo "DWARF_DSYM_FOLDER_PATH is empty, skipping."
  exit 0
fi

echo "Generating missing dSYMs in DWARF_DSYM_FOLDER_PATH..."
find "$TARGET_BUILD_DIR" -name '*.framework' -print0 | while IFS= read -r -d '' fm; do
    name=$(basename "$fm" .framework)
    binary="$fm/$name"
    if [ -f "$binary" ]; then
        dwarfdump -u "$binary" | awk '{print $2}' | while read -r uuid; do
            dsym_path="$DWARF_DSYM_FOLDER_PATH/$name.framework.dSYM"
            if [ ! -d "$dsym_path" ]; then
                echo "Generating dummy dSYM for $name with UUID $uuid at $dsym_path"
                mkdir -p "$dsym_path/Contents/Resources/DWARF"
                
                cat <<EOF > "$dsym_path/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleIdentifier</key>
    <string>com.apple.xcode.dsym.$name</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>dSYM</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF
                cp "$binary" "$dsym_path/Contents/Resources/DWARF/$name"
                dsymutil "$binary" -o "$dsym_path" 2>/dev/null || true
            fi
        done
    fi
done
SCRIPT
  
  # Ensure it runs for every build so Xcode doesn't complain about missing outputs
  phase.always_out_of_date = "1"
  
  project.save
  puts "Successfully saved Fix Missing dSYMs script."
else
  puts "Runner target not found."
end

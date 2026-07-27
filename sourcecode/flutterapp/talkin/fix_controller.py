file_path = "/Users/hammadqayyoom/Projects/Notisboard/sourcecode/flutterapp/talkin/lib/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart"
with open(file_path, "r") as f:
    lines = f.read().split('\n')

# Find start of screen sharing methods (outside controller)
start_idx = -1
for i, line in enumerate(lines):
    if "  // ==========================================" in line and "Screen Sharing Methods" in lines[i+1]:
        start_idx = i
        break

# Find class GroupLiveChatMessage
end_idx = -1
for i, line in enumerate(lines):
    if "class GroupLiveChatMessage {" in line:
        end_idx = i
        break

if start_idx != -1 and end_idx != -1 and start_idx < end_idx:
    methods_lines = lines[start_idx:end_idx]
    
    # We remove these lines
    del lines[start_idx:end_idx]
    
    # Now find the actual end of VoiceCallController.
    # It should be the last '}' before start_idx (which is now shifted).
    # Since we know `_reportRecordingComplete` is the last method, we can find it.
    report_idx = -1
    for i, line in enumerate(lines):
        if "Future<void> _reportRecordingComplete" in line:
            report_idx = i
            break
            
    # Find the closing brace of `VoiceCallController` which is the first `}` at indentation 0 after `_reportRecordingComplete`
    insert_idx = -1
    if report_idx != -1:
        for i in range(report_idx, len(lines)):
            if lines[i] == "}":
                insert_idx = i
                break
                
    if insert_idx != -1:
        lines = lines[:insert_idx] + methods_lines + lines[insert_idx:]
        
        with open(file_path, "w") as f:
            f.write('\n'.join(lines))
        print("Successfully moved methods.")
    else:
        print("Could not find closing brace.")
else:
    print("Could not find start/end indices.")

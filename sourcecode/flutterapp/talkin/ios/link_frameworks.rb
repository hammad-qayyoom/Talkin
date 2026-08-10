require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

extension_name = 'ScreenShareExtension'
extension_target = project.targets.find { |t| t.name == extension_name }

if extension_target.nil?
  puts "Target #{extension_name} not found."
  exit 1
end

framework_path = '.symlinks/plugins/zego_express_engine/ios/libs/ZegoExpressEngine.xcframework'
framework_ref = project.frameworks_group.files.find { |f| f.path == framework_path }
if framework_ref.nil?
  framework_ref = project.frameworks_group.new_file(framework_path)
end

# Add to Frameworks Build Phase
frameworks_phase = extension_target.frameworks_build_phase
unless frameworks_phase.files.any? { |f| f.file_ref == framework_ref }
  build_file = frameworks_phase.add_file_reference(framework_ref)
  # Do not embed in the extension since the main app embeds it
  # Wait, for extensions, we usually don't embed frameworks if the main app does, OR we just let CocoaPods handle it. 
  # Xcodeproj defaults to not embedding (just linking).
end

# Also add ReplayKit framework
replaykit_ref = project.frameworks_group.files.find { |f| f.path == 'System/Library/Frameworks/ReplayKit.framework' }
if replaykit_ref.nil?
  replaykit_ref = project.frameworks_group.new_reference('System/Library/Frameworks/ReplayKit.framework')
  replaykit_ref.source_tree = 'SDKROOT'
end
unless frameworks_phase.files.any? { |f| f.file_ref == replaykit_ref }
  frameworks_phase.add_file_reference(replaykit_ref)
end

# Add framework search paths so it finds ZegoExpressEngine.xcframework
extension_target.build_configurations.each do |config|
  search_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS'] || ['$(inherited)']
  search_paths << '"${SRCROOT}/.symlinks/plugins/zego_express_engine/ios/libs"'
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] = search_paths.uniq
end

project.save
puts "Successfully linked frameworks to #{extension_name}."

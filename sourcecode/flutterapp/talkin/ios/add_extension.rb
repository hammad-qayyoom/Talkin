require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

extension_name = 'ScreenShareExtension'
bundle_id = 'com.notisboard.mobile.ScreenShareExtension'

# Check if target already exists
if project.targets.any? { |t| t.name == extension_name }
  puts "Target #{extension_name} already exists."
  exit 0
end

# Create the extension target
extension_target = project.new_target(
  :app_extension,
  extension_name,
  :ios,
  '12.0'
)

# Create a group for the extension files
extension_group = project.main_group.find_subpath(extension_name, true)

# Add files to the group
info_plist = extension_group.new_reference('Info.plist')
sample_handler = extension_group.new_reference('SampleHandler.swift')
entitlements = extension_group.new_reference('ScreenShareExtension.entitlements')

# Add swift file to compile sources build phase
extension_target.source_build_phase.add_file_reference(sample_handler)

# Configure build settings
extension_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = "#{extension_name}/Info.plist"
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = "#{extension_name}/ScreenShareExtension.entitlements"
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
end

# Add the extension target as a dependency to the main Runner target
runner_target = project.targets.find { |t| t.name == 'Runner' }

if runner_target
  runner_target.add_dependency(extension_target)
  
  # Embed the extension appx
  embed_phase = runner_target.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.dst_subfolder_spec = '13' # Plugins
  embed_phase.add_file_reference(extension_target.product_reference)
end

project.save
puts "Successfully added #{extension_name} target to Xcode project."

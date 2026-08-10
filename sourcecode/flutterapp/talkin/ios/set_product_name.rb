require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

extension_target = project.targets.find { |t| t.name == 'ScreenShareExtension' }

if extension_target
  extension_target.build_configurations.each do |config|
    config.build_settings['PRODUCT_NAME'] = 'ScreenShareExtension'
  end
  project.save
  puts "Successfully set PRODUCT_NAME for ScreenShareExtension."
else
  puts "Target not found."
end

require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

runner_target = project.targets.find { |t| t.name == 'Runner' }
extension_target = project.targets.find { |t| t.name == 'ScreenShareExtension' }

if runner_target && extension_target
  # Get development team from Runner target
  dev_team = runner_target.build_configurations.first.build_settings['DEVELOPMENT_TEAM']
  
  if dev_team
    extension_target.build_configurations.each do |config|
      config.build_settings['DEVELOPMENT_TEAM'] = dev_team
    end
    
    # Also set the target attribute
    attributes = project.root_object.attributes['TargetAttributes'] || {}
    extension_target_attr = attributes[extension_target.uuid] || {}
    extension_target_attr['DevelopmentTeam'] = dev_team
    attributes[extension_target.uuid] = extension_target_attr
    project.root_object.attributes['TargetAttributes'] = attributes
    
    project.save
    puts "Successfully set Development Team #{dev_team} for ScreenShareExtension."
  else
    puts "Could not find Development Team in Runner target."
  end
else
  puts "Targets not found."
end

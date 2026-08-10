require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

extension_group = project.main_group.find_subpath('ScreenShareExtension', false)
if extension_group
  extension_group.set_path('ScreenShareExtension')
  project.save
  puts "Updated group path"
else
  puts "Group not found"
end

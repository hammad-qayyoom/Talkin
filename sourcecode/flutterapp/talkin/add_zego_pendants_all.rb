require 'xcodeproj'
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# recursively find all .bundle files in ios/Runner/Pendants
pendants_group = project.main_group.find_subpath(File.join('Runner', 'Pendants'), true)
Dir.glob('ios/Runner/Pendants/**/*.bundle').each do |file|
  if File.directory?(file) && file.end_with?('.bundle')
    rel_path = file.sub('ios/Runner/Pendants/', '')
    parts = rel_path.split('/')
    filename = parts.pop
    current_group = pendants_group
    parts.each do |part|
      current_group = current_group.groups.find { |g| g.name == part || g.path == part } || current_group.new_group(part, part)
    end
    file_ref = current_group.files.find { |f| f.path == filename } || current_group.new_file(filename)
    target.add_resources([file_ref])
  end
end
project.save
puts "Added all Pendant bundles to Xcode project."

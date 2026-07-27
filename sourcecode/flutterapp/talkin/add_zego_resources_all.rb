require 'xcodeproj'
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# recursively find all .bundle files in ios/Runner/Resources
resources_group = project.main_group.find_subpath(File.join('Runner', 'Resources'), true)
Dir.glob('ios/Runner/Resources/**/*.bundle').each do |file|
  # We should only add the .bundle directory itself, not its contents!
  # Dir.glob with **/*.bundle might match nested things if a .bundle contains another .bundle, but usually it doesn't.
  # Let's ensure it's a directory ending in .bundle
  if File.directory?(file) && file.end_with?('.bundle')
    # find the relative path from Resources
    rel_path = file.sub('ios/Runner/Resources/', '')
    # create group structure if needed, or just add file reference
    parts = rel_path.split('/')
    filename = parts.pop
    current_group = resources_group
    parts.each do |part|
      current_group = current_group.groups.find { |g| g.name == part || g.path == part } || current_group.new_group(part, part)
    end
    file_ref = current_group.files.find { |f| f.path == filename } || current_group.new_file(filename)
    target.add_resources([file_ref])
  end
end
project.save
puts "Added all bundle resources to Xcode project."

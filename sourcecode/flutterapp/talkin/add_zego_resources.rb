require 'xcodeproj'
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

models_group = project.main_group.find_subpath(File.join('Runner', 'Models'), true)
models_group.set_source_tree('<group>')
resources_group = project.main_group.find_subpath(File.join('Runner', 'Resources'), true)
resources_group.set_source_tree('<group>')

# Add Models
Dir.glob('ios/Runner/Models/*.model').each do |file|
  filename = File.basename(file)
  file_ref = models_group.files.find { |f| f.path == filename } || models_group.new_file(filename)
  target.add_resources([file_ref])
end

# Add Resources
Dir.glob('ios/Runner/Resources/*.bundle').each do |file|
  filename = File.basename(file)
  file_ref = resources_group.files.find { |f| f.path == filename } || resources_group.new_file(filename)
  target.add_resources([file_ref])
end

# Also add ColorfulStyleResources
colorful_dir = 'ios/Runner/Resources/ColorfulStyleResources'
if Dir.exist?(colorful_dir)
  colorful_group = resources_group.find_subpath('ColorfulStyleResources', true)
  Dir.glob("#{colorful_dir}/*.bundle").each do |file|
    filename = File.basename(file)
    file_ref = colorful_group.files.find { |f| f.path == filename } || colorful_group.new_file(filename)
    target.add_resources([file_ref])
  end
end

# Also add PendantResources
pendant_dir = 'ios/Runner/Resources/PendantResources.bundle'
# Wait, PendantResources.bundle is already a bundle, so it gets added as a bundle.

# Also MakeupResources
makeup_dir = 'ios/Runner/Resources/MakeupResources'
if Dir.exist?(makeup_dir)
  makeup_group = resources_group.find_subpath('MakeupResources', true)
  # Actually MakeupResources has subdirectories like eyelinerdir, etc.
  # Let's add them all recursively if they are bundles
  Dir.glob("#{makeup_dir}/**/*.bundle").each do |file|
    # It's better to add the top-level bundle or directory?
    # Actually, iOS expects them in the main bundle, so let's just add the specific bundles
    # Or Zego plugin expects them at a specific path?
    # iOS plugin:
    # NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    # If bundleName is "Creamy", it will look for "Creamy.bundle" at root of mainBundle.
    # When we add .bundle to target, it puts the .bundle directly at the root of the app bundle!
    # So we should just add all .bundle files anywhere in Resources/ to the target.
  end
end

project.save
puts "Added resources to Xcode project."

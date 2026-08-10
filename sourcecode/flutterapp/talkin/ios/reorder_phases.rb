require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

runner_target = project.targets.find { |t| t.name == 'Runner' }

if runner_target
  # Find the Embed App Extensions phase
  embed_app_ext_phase = runner_target.copy_files_build_phases.find { |p| p.respond_to?(:name) && p.name == 'Embed App Extensions' }
  
  if embed_app_ext_phase
    # Remove it from the current position
    runner_target.build_phases.delete(embed_app_ext_phase)
    
    # Find the Thin Binary phase index
    thin_binary_index = runner_target.build_phases.index { |p| (p.respond_to?(:name) && p.name == 'Thin Binary') || (p.respond_to?(:display_name) && p.display_name == 'Thin Binary') } || runner_target.build_phases.size
    
    # Insert Embed App Extensions right BEFORE Thin Binary
    runner_target.build_phases.insert(thin_binary_index, embed_app_ext_phase)
    
    project.save
    puts "Successfully moved 'Embed App Extensions' before 'Thin Binary'."
  else
    puts "Could not find 'Embed App Extensions' phase."
  end
else
  puts "Could not find Runner target."
end

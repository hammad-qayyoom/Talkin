require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

runner_target = project.targets.find { |t| t.name == 'Runner' }

if runner_target
  phase_to_remove = runner_target.shell_script_build_phases.find { |phase| phase.name == 'Fix Missing dSYMs' }
  if phase_to_remove
    phase_to_remove.remove_from_project
    project.save
    puts "Removed 'Fix Missing dSYMs' build phase."
  else
    puts "Phase not found."
  end
end

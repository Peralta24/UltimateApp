require 'xcodeproj'
begin
  project = Xcodeproj::Project.open('UltimateApp.xcodeproj')
  puts "Opened successfully"
  puts "Targets: #{project.targets.map(&:name).join(', ')}"
  
  target = project.targets.first
  puts "Target: #{target.name}"
  
  # Try to find the group
  main_group = project.main_group
  puts "Main group children: #{main_group.children.map(&:path).join(', ')}"
  
rescue => e
  puts "Error: #{e.message}"
end

require 'Xcodeproj'

project = Xcodeproj::Project.open("Pods/Pods.xcodeproj")
project.build_configurations.each { |config|
	project.build_settings(config.name)["EXCLUDED_ARCHS"] = "arm64"
}
project.save()
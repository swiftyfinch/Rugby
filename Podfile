platform :ios, '11.0.1'
project 'TestProject/TestProject.xcodeproj'

install! 'cocoapods', :warn_for_unused_master_specs_repo => false

target 'TestProject' do
  use_frameworks!
  
  pod 'SnapKit'
  pod 'Keyboard+LayoutGuide'
  pod 'R.swift'
  pod 'LocalPod', :path => '.', :testspecs => ['Tests']
  pod 'Moya/Core'
  pod 'Kingfisher'

  target 'TestProjectTests' do
    inherit! :search_paths
    pod 'Moya/ReactiveSwift'
    pod 'AutoMate'
  end

  target 'TestProjectUITests' do
    pod 'Moya/RxSwift'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name.include? 'LocalPod'
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_TREAT_WARNINGS_AS_ERRORS'] = 'YES'
        config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'YES'
      end
    end
  end
  
  installer.pods_project.root_object.build_configuration_list.build_configurations.each { |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  }
end

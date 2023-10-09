Pod::Spec.new do |s|
  s.name     = 'LocalPod'
  s.version  = '1.0.0'
  s.summary  = 'LocalPod'
  s.homepage = "none"
  s.author   = "Khorkov Vyacheslav"
  s.source   = { :path => "*" }

  s.ios.deployment_target = '16.0'
  s.static_framework = true
  s.prefix_header_file = false
  s.source_files = "#{s.name}/Sources/**/*.swift"
  s.resource_bundles = {
    "#{s.name}Resources" => [
      "#{s.name}/{Sources,Resources}/**/*.{json,strings}"
    ]
  }
  s.dependency 'Moya/Core'

  s.test_spec 'Tests' do |ts|
    ts.source_files = "#{s.name}/Tests/**/*.swift"
    ts.resources = "#{s.name}/Tests/**/*.{json,xcassets}"
  end

  s.test_spec 'ResourceBundleTests' do |ts|
    ts.source_files = "#{s.name}/ResourceBundleTests/**/*.swift"
    ts.resource_bundle = {
      "#{s.name}ResourceBundleTestsResources" => "#{s.name}/ResourceBundleTests/**/*.{json,xcassets}"
    }
  end
end

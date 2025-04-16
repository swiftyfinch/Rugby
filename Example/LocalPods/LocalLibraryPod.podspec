Pod::Spec.new do |s|
    s.name     = 'LocalLibraryPod'
    s.version  = '1.0.0'
    s.summary  = 'LocalLibraryPod'
    s.homepage = "none"
    s.author   = "Khorkov Vyacheslav"
    s.source   = { :path => "*" }

    s.ios.deployment_target = '16.0'
    s.static_framework = true
    s.prefix_header_file = false
    s.source_files = "#{s.name}/Sources/**/*.swift"
end

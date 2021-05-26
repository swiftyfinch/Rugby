Pod::Spec.new do |s|
  s.name     = 'LocalPod'
  s.version  = '1.0.0'
  s.summary  = 'LocalPod'
  s.homepage = "none"
  s.author   = "Khorkov Vyacheslav"
  s.source   = { :path => "*" }

  s.ios.deployment_target = '11.0.1'
  s.swift_version = '5.2'
  s.static_framework = true
  s.prefix_header_file = false
  s.source_files = "#{s.name}/Sources/**/*.swift"

  s.dependency 'R.swift'
  s.dependency 'Moya/Core'

  s.test_spec 'Tests' do |ts|
    ts.source_files = "#{s.name}/Tests/**/*.swift"
    ts.resources = "#{s.name}/Tests/**/*.{json,xcassets}"
  end

  # ================================ Resources ========================================
  r_swift_prepare_script = <<-SCRIPT
    require "fileutils"
    FileUtils.touch "#{s.name}/Sources/R.generated.swift"
  SCRIPT

  s.prepare_command = <<-SCRIPT
    ruby -e '#{r_swift_prepare_script}'
  SCRIPT

  r_swift_resources = ["#{s.name}/{Sources,Resources}/**/*.{strings}"]
  resources_bundle_name = "#{s.name}Resources"
  s.resource_bundles = {
    resources_bundle_name => r_swift_resources
  }

  r_swift_output = "${PODS_TARGET_SRCROOT}/#{s.name}/Sources/R.generated.swift"
  r_swift_script = <<~SCRIPT
    export TARGET_NAME='#{s.name}-#{resources_bundle_name}'
    result=`"$PODS_ROOT/R.swift/rswift" generate "#{r_swift_output}" --disable-input-output-files-validation`

    if [[ $result =~ "warning" ]]; then
      echo "${result}" | sed "s/warning:/error:/" >&2
      exit 1
    fi
  SCRIPT

  s.script_phases = [{
    :name => 'R.swift',
    :output_files => [r_swift_output],
    :script => r_swift_script,
    :execution_position => :before_compile,
    :show_env_vars_in_log => '0'
  }]
end

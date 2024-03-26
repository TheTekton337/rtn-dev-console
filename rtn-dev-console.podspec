require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "rtn-dev-console"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/TheTekton337/rtn-dev-console.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.pod_target_xcconfig = {
    "DEFINES_MODULE" => "YES",
    "OTHER_CPLUSPLUSFLAGS" => "-DRCT_NEW_ARCH_ENABLED=1"
  }

  s.static_framework = true

  install_modules_dependencies(s)

  s.dependency 'CSSH'
  s.dependency "CSwiftSH"
  s.dependency "SwiftSH"
  s.dependency "SwiftTerm"
end

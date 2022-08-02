Pod::Spec.new do |s|
  s.name         = 'HowtankWidgetSwift'
  s.version      = '2.2.5'
  s.summary      = 'Howtank Widget library for howtank chat on iOS.'

  s.description      = <<-DESC
Howtank Widget library is intended to be included in apps after creating an account. Please visit our website for more information.
                       DESC

  s.homepage         = "http://www.howtank.com"
  s.license          = { :type => 'Commercial', :text => 'See https://www.howtank.com/mentions-legales' }
  s.author           = "Howtank"
  s.source           = { :git => "https://github.com/howtank/widget-ios-sdk.git", :tag => s.version.to_s }
  s.platform     = :ios
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  s.ios.deployment_target = '10.0'

  s.ios.preserve_paths = 'HowtankWidgetSwift.xcframework'
  s.ios.vendored_frameworks = 'HowtankWidgetSwift.xcframework'
end

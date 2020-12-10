Pod::Spec.new do |s|
  s.name             = 'HowtankWidgetSwift'
  s.version          = '2.2.3'
  s.summary          = "Howtank Widget library for Click to Community® chat on iOS."

  s.description      = <<-DESC
Howtank Widget library is intended to be included in apps after creating an account. Please visit our website for more information.
                       DESC

  s.homepage         = "http://www.howtank.com"
  s.license          = { :type => 'Commercial', :text => 'See https://www.howtank.com/mentions-legales' }
  s.author           = "Howtank"
  s.source           = { :git => "https://github.com/howtank/widget-ios-sdk.git", :tag => s.version.to_s }
  s.platform     = :ios

  s.ios.deployment_target = '10.0'

  s.ios.preserve_paths = 'iOS/HowtankWidgetSwift.xcframework'
  s.ios.vendored_frameworks = 'iOS/HowtankWidgetSwift.xcframework'
end
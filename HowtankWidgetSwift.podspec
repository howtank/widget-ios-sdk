require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "HowtankWidgetSwift"
  s.version      = package["version"]
  s.summary      = package["description"]

  s.description  = <<-DESC
  Howtank Widget library is intended to be included in apps after creating an account. Please visit our website for more information.
                   DESC

  s.homepage     = package["homepage"]
  s.license      = { :type => 'Commercial', :text => 'See https://www.howtank.com/mentions-legales' }
  s.author     = package["author"]
  s.source     = { :git => "git@github.com:howtank/widget-ios-sdk.git", :tag => s.version.to_s }
  s.platform     = :ios
  s.ios.deployment_target = '10.0'

  s.ios.preserve_paths = 'iOS/HowtankWidgetSwift.xcframework'
  s.ios.vendored_frameworks = 'iOS/HowtankWidgetSwift.xcframework'
end

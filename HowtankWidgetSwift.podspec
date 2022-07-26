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

  s.source = { :path => '.' }

  s.platform     = :ios, '13.0'
  s.swift_version = '5'

  #s.source       = { :git => "http://EXAMPLE/HowtankWidget-Swift.git", :tag => "#{s.version}" }
  
  s.source_files  = "HowtankWidgetSwift/**/*.swift"
  s.resource_bundles = {
     'HowtankWidgetSwift' => ['HowtankWidgetSwift/**/*.xib','HowtankWidgetSwift/**/*.xcassets']
  }
  #s.vendored_frameworks = "Output/HowtankWidgetSwift-Release-iphoneuniversal/HowtankWidgetSwift.framework"
  s.ios.deployment_target = '10.0'

end

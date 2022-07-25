Pod::Spec.new do |s|
  s.name         = "HowtankWidgetSwift"
  s.version      = "2.2.5"
  s.summary      = "Howtank Widget library for howtank chat on iOS."

  s.description  = <<-DESC
  Howtank Widget library is intended to be included in apps after creating an account. Please visit our website for more information.
                   DESC

  s.homepage     = "http://www.howtank.com"
  s.license      = { :type => 'Commercial', :text => 'See https://www.howtank.com/mentions-legales' }
  s.author       = "Howtank"

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

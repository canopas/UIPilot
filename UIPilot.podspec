Pod::Spec.new do |s|
  s.name             = "UIPilot"
  s.version          = "1.1.4"
  s.summary          = "The missing type-safe, SwiftUI navigation library."

  s.description      = <<-DESC
    UIPilot is a wrapper around NavigationView of SwiftUI.
                       DESC

  s.homepage         = "https://github.com/canopas/UIPilot"
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { "Jimmy" => "jimmy@canopas.com" }
  s.source           = { :git => "https://github.com/canopas/UIPilot", :tag => "#{s.version}" }
  s.source_files     = "Sources/UIPilot/**/*"
  s.social_media_url = 'https://twitter.com/canopassoftware'

  s.module_name      = 'UIPilot'
  s.default_subspec  = 'standard'
  s.requires_arc     = true
  s.swift_versions   = '5.5'

  s.ios.deployment_target     = '14.0'
  s.tvos.deployment_target    = '14.0'
  s.osx.deployment_target     = '11.0'
  s.watchos.deployment_target = '7.0'
end

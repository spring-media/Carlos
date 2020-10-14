#
# Be sure to run `pod lib lint Carlos.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#

Pod::Spec.new do |s|
  s.name             = "Carlos"
  s.version          = "1.0.0"
  s.summary          = "A simple but flexible cache."
  s.description      = <<-DESC
			Carlos is a small set of classes convenience operators to realize custom, flexible and powerful cache layers in your iOS, watchOS, tvOS and Mac OS X applications.
                       DESC
  s.homepage         = "https://github.com/spring-media/Carlos"
  s.license          = 'MIT'
  s.author           = { "Vittorio Monaco" => "vittorio.monaco1@gmail.com" }
  s.source           = { :git => "https://github.com/spring-media/Carlos.git", :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target     = '13.0'
  s.watchos.deployment_target = '6.0'

  s.source_files          = 'Sources/Carlos/*.swift'
  s.watchos.exclude_files = 'Sources/Carlos/MemoryWarning.swift'

  s.requires_arc = true
end

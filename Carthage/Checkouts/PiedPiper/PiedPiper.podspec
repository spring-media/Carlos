#
# Be sure to run `pod lib lint CarlosFutures.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PiedPiper"
  s.version          = "0.8"
  s.summary          = "Asynchronous code made easy."
  s.description      = <<-DESC
			Pied Piper is a small set of functions to write easy asynchronous code through Futures, Promises and some GCD love for your iOS, watchOS 2, tvOS and Mac OS X applications.
                       DESC
  s.homepage         = "https://github.com/WeltN24/PiedPiper"
  s.license          = 'MIT'
  s.author           = { "Vittorio Monaco" => "vittorio.monaco1@gmail.com" }
  s.source           = { :git => "https://github.com/WeltN24/PiedPiper.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.requires_arc = true

  s.source_files = 'PiedPiper/*.swift'
end

#
# Be sure to run `pod lib lint Carlos.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Carlos"
  s.version          = "0.8"
  s.summary          = "A simple but flexible cache."
  s.description      = <<-DESC
			Carlos is a small set of classes convenience operators to realize custom, flexible and powerful cache layers in your iOS, watchOS 2, tvOS and Mac OS X applications.
                       DESC
  s.homepage         = "https://github.com/WeltN24/Carlos"
  s.license          = 'MIT'
  s.author           = { "Vittorio Monaco" => "vittorio.monaco1@gmail.com" }
  s.source           = { :git => "https://github.com/WeltN24/Carlos.git", :tag => s.version.to_s }

  s.ios.platform = :ios, "9.0"
  s.osx.platform = :osx, "10.10"
  s.watchos.platform = :watchos, "2.0"
  s.tvos.platform = :tvos, "9.0"

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0' 
  s.tvos.deployment_target = '9.0'
  
  s.requires_arc = true

  s.dependency 'PiedPiper', '~> 0.8'

  s.ios.source_files = 'Carlos/*.swift', 'Carlos/NSKeyedUnarchiver+SwiftUtilities.{h,m}'
  s.watchos.source_files = 'Carlos/*.swift', 'Carlos/NSKeyedUnarchiver+SwiftUtilities.{h,m}'
  s.watchos.exclude_files = 'Carlos/MemoryWarning.swift'
  s.osx.source_files = 'Carlos/*.swift', 'CarlosMac/*.swift', 'Carlos/NSKeyedUnarchiver+SwiftUtilities.{h,m}'
  s.osx.exclude_files = 'Carlos/MemoryWarning.swift', 'Carlos/*+iOS.swift'
  s.tvos.source_files = 'Carlos/*.swift', 'Carlos/NSKeyedUnarchiver+SwiftUtilities.{h,m}'
  s.tvos.exclude_files = 'Carlos/Transformers.swift'
end

#
# Be sure to run `pod lib lint Carlos.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Carlos"
  s.version          = "0.2"
  s.summary          = "A simple but flexible cache."
  s.description      = <<-DESC
			Carlos is a small set of classes, global functions (that will be replaced by protocol extensions with Swift 2.0) and convenience operators to realize custom, flexible and powerful cache layers in your application.
                       DESC
  s.homepage         = "https://github.com/WeltN24/Carlos"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Vittorio Monaco" => "vittorio.monaco1@gmail.com" }
  s.source           = { :git => "https://github.com/WeltN24/Carlos.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Carlos/**/*.swift'
  # s.resource_bundles = {
  #  'Carlos' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
end

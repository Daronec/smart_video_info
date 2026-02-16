#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint smart_video_info.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'smart_video_info'
  s.version          = '1.0.0'
  s.summary          = 'Ultra-fast video metadata extraction for Flutter.'
  s.description      = <<-DESC
Ultra-fast video metadata extraction powered by native AVFoundation on macOS.
No CLI, no process spawning - direct native API access.
                       DESC
  s.homepage         = 'https://github.com/Daronec/smart_video_info'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Daronec' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end

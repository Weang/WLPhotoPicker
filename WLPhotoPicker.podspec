#
# Be sure to run `pod lib lint WLPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WLPhotoPicker'
  s.version          = '0.1.0'
  s.summary          = 'Photo plcker.'
  s.homepage         = 'https://github.com/Weang/WLPhotoPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Weang' => 'w704444178@qq.com' }
  s.source           = { :git => 'https://github.com/Weang/WLPhotoPicker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.dependency 'SnapKit', "~> 5.0.0"
  s.source_files = "WLPhotoPicker/Classes/**/*"
  s.resources = 'WLPhotoPicker/Resources/*'
end

#
# Be sure to run `pod lib lint PanModal.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PanModal'
  s.version          = '1.2.11'
  s.summary          = 'PanModal is an elegant and highly customizable presentation API for constructing bottom sheet modals on iOS.'
  s.description      = 'PanModal is an elegant and highly customizable presentation API for constructing bottom sheet modals on iOS.'
  s.homepage         = 'https://github.com/galandezzz/PanModal'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'slack' => 'opensource@slack.com', 'Egor Snitsar' => 'fearum@icloud.com' }
  s.source           = { :git => 'https://github.com/galandezzzz/PanModal.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files = 'PanModal/**/*.{swift,h,m}'
end

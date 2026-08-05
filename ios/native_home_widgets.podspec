#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_home_widgets.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_home_widgets'
  s.version          = '0.0.1'
  s.summary          = 'Home screen widgets for Flutter'
  s.description      = <<-DESC
A Flutter plugin that lets developers create, configure, and manage Home Screen Widgets entirely from Flutter.
                       DESC
  s.homepage         = 'https://github.com/nativehome/native_home_widgets'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Native Home Widgets' => 'team@nativehome.dev' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'

  # WidgetKit and AppIntents are system frameworks — no pod dependency needed.
  # They are linked automatically by Xcode when the deployment target is iOS 16+.
  s.frameworks = 'WidgetKit', 'SwiftUI', 'AppIntents'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'native_home_widgets_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end

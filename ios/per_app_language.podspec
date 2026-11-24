#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint per_app_language.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'per_app_language'
  s.version          = '0.0.1'
  s.summary          = 'Let users pick your app's language in Android 13+ and iOS system settings, and keep Flutter in sync. Includes a setup command for the native config.'
  s.description      = <<-DESC
Let users pick your app's language in Android 13+ and iOS system settings, and keep Flutter in sync. Includes a setup command for the native config.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'per_app_language_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end

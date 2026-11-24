Pod::Spec.new do |s|
  s.name             = 'per_app_language'
  s.version          = '0.1.0'
  s.summary          = 'Per-app language that syncs with iOS Settings.'
  s.description      = <<-DESC
Read and set the app's language through iOS per-app language settings, so the
choice shows up in Settings and stays in sync with Flutter.
                       DESC
  s.homepage         = 'https://github.com/ManukumarSB/per_app_language'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Manukumar S B' => 'manukumar.cs.geck@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'per_app_language/Sources/per_app_language/**/*.swift'
  s.resource_bundles = { 'per_app_language_privacy' => ['per_app_language/Sources/per_app_language/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
end

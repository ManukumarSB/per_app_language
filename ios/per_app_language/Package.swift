// swift-tools-version: 5.9
// Swift Package Manager manifest, used by Flutter when SwiftPM is enabled.
// CocoaPods users get the same sources through ../per_app_language.podspec.

import PackageDescription

let package = Package(
  name: "per_app_language",
  platforms: [
    .iOS("13.0")
  ],
  products: [
    .library(name: "per-app-language", targets: ["per_app_language"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "per_app_language",
      dependencies: [],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ]
)

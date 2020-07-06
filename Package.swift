// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Carlos",
  platforms: [
    .iOS(.v10),
    .macOS(.v10_12),
    .tvOS(.v10),
    .watchOS(.v3)
  ],
  products: [
    .library(
      name: "Carlos",
      targets: ["Carlos"]),
  ],
  dependencies: [
    .package(url:  "https://github.com/spring-media/PiedPiper.git", .upToNextMajor(from: "0.11.0")),
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.1"))
  ],
  targets: [
    .target(
      name: "Carlos",
      dependencies: [
        "PiedPiper"
      ]
    ),
    .testTarget(
      name: "CarlosTests",
      dependencies: [
        "Carlos",
        "Quick",
        "Nimble",
        "PiedPiper"
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

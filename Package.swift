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
    .package(url: "https://github.com/spring-media/PiedPiper", .branch("feature/update-quick-and-nimble")),
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "3.0.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.1.0")),
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

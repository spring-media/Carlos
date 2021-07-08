// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "Carlos",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(
      name: "Carlos",
      targets: ["Carlos"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0"))
  ],
  targets: [
    .target(
      name: "Carlos",
      dependencies: []
    ),
    .testTarget(
      name: "CarlosTests",
      dependencies: [
        "Carlos",
        "Quick",
        "Nimble"
      ]
    )
  ],
  swiftLanguageVersions: [.v5]
)

// swift-tools-version:5.2

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
    .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.10.0"),
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "3.0.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.1.0")),
  ],
  targets: [
    .target(
      name: "Carlos",
      dependencies: [
        "OpenCombine",
        .product(name: "OpenCombineDispatch", package: "OpenCombine"),
        .product(name: "OpenCombineFoundation", package: "OpenCombine")
      ]
    ),
    .testTarget(
      name: "CarlosTests",
      dependencies: [
        "Carlos",
        "Quick",
        "Nimble",
      ]
    ),
  ],
  swiftLanguageVersions: [.v5]
)

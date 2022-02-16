// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "UIPilot",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "UIPilot",
            targets: ["UIPilot"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "UIPilot",
            dependencies: []),
        .testTarget(
            name: "UIPilotTests",
            dependencies: ["UIPilot"]),
    ]
)

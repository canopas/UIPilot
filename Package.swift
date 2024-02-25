// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "UIPilot",
    platforms: [
        .iOS(.v16),
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

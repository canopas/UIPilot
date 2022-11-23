// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "UIPilot",
    platforms: [
        .iOS(.v14),
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

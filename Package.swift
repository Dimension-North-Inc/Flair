// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flair",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Flair",
            targets: ["Flair"])
    ],
    dependencies: [
        .package(url: "git@github.com:Dimension-North-Inc/Silo.git", from: "1.3.0"),
        .package(url: "git@github.com:Dimension-North-Inc/Geometry.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Flair",
            dependencies: [
                "Silo", "Geometry"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FlairTests",
            dependencies: ["Flair"]
        ),
    ]
)

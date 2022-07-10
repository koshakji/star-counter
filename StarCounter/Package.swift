// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StarCounter",
    platforms: [.macOS("12.0")],
    products: [
        .executable(name: "StarCounter", targets: ["StarCounter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SketchMaster2001/Swiftcord", branch: "master")
    ],
    targets: [
        .target(
            name: "StarCounter",
            dependencies: ["Swiftcord"]
        ),
        .testTarget(
            name: "StarCounterTests",
            dependencies: ["StarCounter"]),
    ]
)

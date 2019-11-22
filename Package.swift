// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "macdb",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .executable(name: "macdb", targets: ["macdb"]),
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.7")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: []),
        .target(
            name: "macdb",
            dependencies: ["Core", "GRPC"]),
        .testTarget(
            name: "macdbTests",
            dependencies: ["macdb"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

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
        .executable(name: "macdb", targets: ["macdb"])
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.7"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.7.1"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: []
        ),
        .target(
            name: "MacDBModel",
            dependencies: [
                "GRPC",
                "NIO",
                "NIOHTTP1",
                "SwiftProtobuf"
            ],
            path: "Sources/macdb/Model"
        ),
        .target(
            name: "macdb",
            dependencies: [
                "Core",
                "GRPC",
                "Logging",
                "MacDBModel",
                "NIO"
            ],
            path: "Sources/macdb/Server"
        ),
        .testTarget(
            name: "macdbTests",
            dependencies: ["macdb"])
    ],
    swiftLanguageVersions: [
        .v5
    ]
)

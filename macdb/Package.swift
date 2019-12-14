// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "macdb",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .executable(name: "macdb", targets: ["macdb"]),
        .library(name: "Mocked", targets: ["Mocked"]),
        .library(name: "Providers", targets: ["Providers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.7"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.7.1"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: []
        ),
        .target(
            name: "Mocked",
            dependencies: []
        ),
        .target(
            name: "Model",
            dependencies: [
                "GRPC",
                "NIO",
                "NIOHTTP1",
                "SwiftProtobuf",
            ]
        ),
        .target(
            name: "Providers",
            dependencies: ["Core", "Model",]
        ),
        .target(
            name: "macdb",
            dependencies: [
                "GRPC",
                "Logging",
                "NIO",
                "Providers",
            ]
        ),
        .testTarget(
            name: "ProvidersTests",
            dependencies: [
                "Model",
                "Mocked",
                "Providers",
            ]
        ),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)

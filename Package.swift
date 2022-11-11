// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Mnemonize",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.4"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "Mnemonize",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: "MnemonizeTests",
            dependencies: ["Mnemonize"]
        ),

        .executableTarget(
            name: "New",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Mnemonize",
            ]
        ),

        .executableTarget(
            name: "Swedish",
            dependencies: [
                "New",
            ]
        ),
    ]
)

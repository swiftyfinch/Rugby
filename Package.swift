// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Rugby",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "rugby", targets: ["Rugby"]),
        .library(name: "RugbyFoundation", targets: ["RugbyFoundation"])
    ],
    dependencies: [
        // rugby
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),

        // RugbyFoundation
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
        .package(url: "https://github.com/tuist/XcodeProj", from: "8.12.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/tuist/xcbeautify", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.6"),
        .package(url: "https://github.com/marmelroy/Zip", from: "2.1.2"),
        .package(url: "https://github.com/swiftyfinch/Fish", from: "0.1.0")
    ],
    targets: [
        // rugby
        .executableTarget(name: "Rugby", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "RugbyFoundation"
        ]),
        .testTarget(name: "RugbyTests", dependencies: ["Rugby"]),

        // RugbyFoundation
        .target(name: "RugbyFoundation", dependencies: [
            "Rainbow",
            "XcodeProj",
            "SwiftShell",
            .product(name: "XcbeautifyLib", package: "xcbeautify"),
            "Yams",
            "Zip",
            "Fish"
        ]),
        .testTarget(name: "FoundationTests", dependencies: ["RugbyFoundation"])
    ]
)

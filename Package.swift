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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),

        // RugbyFoundation
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
        .package(url: "https://github.com/tuist/XcodeProj", from: "8.20.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/tuist/xcbeautify", from: "1.6.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.6"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.18"),
        .package(url: "https://github.com/swiftyfinch/Fish", from: "0.1.1")
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
            "ZIPFoundation",
            "Fish"
        ]),
        .testTarget(name: "FoundationTests", dependencies: ["RugbyFoundation"])
    ]
)

// swift-tools-version:5.7

import PackageDescription

// It's a temporary package description only for support https://swiftpackageindex.com/swiftyfinch/Rugby
// I'm going to open source of Rugby this summer.
let package = Package(
    name: "Rugby",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "rugby", targets: ["Rugby"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
        .package(url: "https://github.com/tuist/XcodeProj", from: "8.9.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/tuist/xcbeautify", from: "0.17.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.5"),
        .package(url: "https://github.com/marmelroy/Zip.git", from: "2.1.2")
    ],
    targets: [
        .executableTarget(name: "Rugby", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "Rainbow",
            "XcodeProj",
            "SwiftShell",
            .product(name: "XcbeautifyLib", package: "xcbeautify"),
            "Yams",
            "Zip"
        ])
    ]
)

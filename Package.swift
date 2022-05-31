// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rugby",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "rugby", targets: ["Rugby"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj", from: "8.7.1"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
        .package(url: "https://github.com/tuist/xcbeautify", from: "0.13.0")
    ],
    targets: [
        .target(name: "Rugby", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "Rainbow",
            "Files",
            "XcodeProj",
            "SwiftShell",
            "Yams",
            .product(name: "XcbeautifyLib", package: "xcbeautify")
        ])
    ]
)

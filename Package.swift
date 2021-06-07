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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.3"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj", from: "7.22.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),

        // Need await the new version
        .package(url: "https://github.com/thii/xcbeautify.git", .revision("7305183edac003dae3dc56ce35d039df7bccc3b4"))
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

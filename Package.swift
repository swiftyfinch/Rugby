// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "rugby",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "rugby", targets: ["rugby"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj", from: "7.18.0"),
        .package(url: "https://github.com/eneko/RegEx.git", from: "0.1.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "rugby", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "Rainbow",
            "Files",
            "XcodeProj",
            "RegEx",
            "ShellOut"
        ])
    ]
)

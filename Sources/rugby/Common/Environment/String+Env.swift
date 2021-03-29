//
//  String+Env.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import ArgumentParser

enum SDK: String, Codable, ExpressibleByArgument {
    case sim, ios

    var xcodebuild: String {
        switch self {
        case .sim: return "iphonesimulator"
        case .ios: return "iphoneos"
        }
    }
}

extension String {
    static let podfileLock = "Podfile.lock"
    static let podsProject = "Pods/Pods.xcodeproj"
    static let podsTargetSupportFiles = "Pods/Target Support Files"

    static let supportFolder = ".rugby"
    static let buildFolder = supportFolder + "/build"
    static let log = supportFolder + "/rugby.log"
    static let buildLog = supportFolder + "/build.log"
    static let cachedChecksums = supportFolder + "/Checksums"
    static let cacheFile = supportFolder + "/cache.yml"

    static let podsGroup = "Pods"

    static let defaultXcodeCLTPath = "/Library/Developer/CommandLineTools"

    static func cacheFolder(sdk: SDK) -> String {
        "${PODS_ROOT}/../" + supportFolder + "/build/Debug-\(sdk.xcodebuild)"
    }
}

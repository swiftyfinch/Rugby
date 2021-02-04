//
//  String+Env.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Foundation

extension String {
    static let podfileLock = "Podfile.lock"
    static let podsProject = "Pods/Pods.xcodeproj"
    static let podsTargetSupportFiles = "Pods/Target Support Files"

    static let supportFolder = ".rugby"
    static let buildFolder = supportFolder + "/build"
    static let log = supportFolder + "/rugby.log"
    static let buildLog = supportFolder + "/build.log"
    static let cachedChecksums = supportFolder + "/Checksums"
    static let cacheFolder = "${PODS_ROOT}/../" + supportFolder + "/build/Debug-iphonesimulator"
}

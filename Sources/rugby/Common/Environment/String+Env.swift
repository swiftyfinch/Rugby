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
    static let log = supportFolder + "/rugby.log"
    static let cachedChecksums = supportFolder + "/Checksums"
    static let buildFolder = "${PODS_ROOT}/../" + supportFolder + "/build/Debug-iphonesimulator"
}

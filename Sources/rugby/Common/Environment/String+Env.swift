//
//  String+Env.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

extension String {

    // MARK: - Output
    static let finalMessage = "Let's roll 🏈".green
    static let separator = "---------------------------------".yellow

    // MARK: - Common

    static let podsGroup = "Pods"
    static let developmentPodsGroup = "Development Pods"
    static let supportFolder = ".rugby"
    static let log = supportFolder + "/rugby.log"
    static let plans = supportFolder + "/plans.yml"
    static let lockfile = "Podfile.lock"
    static let podsProject = "Pods/Pods.xcodeproj"
    static let podsTargetSupportFiles = "Pods/Target Support Files"

    // MARK: - History

    static let history = supportFolder + "/history"

    // MARK: - Cache command

    static let defaultXcodeCLTPath = "/Library/Developer/CommandLineTools"

    static let buildTarget = "RugbyPods"
    static let buildLog = supportFolder + "/build.log"
    static let buildFolder = supportFolder + "/build"
    static let cacheFile = supportFolder + "/cache.yml"
    static func cacheFolder(sdk: SDK) -> String {
        "${PODS_ROOT}/../" + supportFolder + "/build/Debug-\(sdk.xcodebuild)"
    }
}

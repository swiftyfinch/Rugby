//
//  String+Env.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

extension String {

    // MARK: - Output

    static let finalMessage = "Let's roll 🏈".green
    static let separator = "---------------------------------".yellow

    // MARK: - Common

    static let podsFolder = "Pods"
    static let podsGroup = "Pods"
    static let developmentPodsGroup = "Development Pods"
    static let supportFolder = ".rugby"
    static let log = supportFolder + "/rugby.log"
    static let plans = supportFolder + "/plans.yml"
    static let lockfile = "Podfile.lock"

    static let podsProjectName = "Pods.xcodeproj"
    static let podsProject = podsFolder + "/" + podsProjectName
    static let podsTargetSupportFilesName = "Target Support Files"
    static let podsTargetSupportFiles = podsFolder + "/" + podsTargetSupportFilesName

    // MARK: - History

    static let history = supportFolder + "/history"

    // MARK: - Backup

    static let backupFolder = supportFolder + "/backup"
    static let backupPodsProject = backupFolder + "/" + podsProjectName
    static let backupPodsTargetSupportFiles = backupFolder + "/" + podsTargetSupportFilesName

    // MARK: - Xcode Project Variables

    static let rugbyPatched = "RUGBY_PATCHED"
    static let rugbyHasBackup = "RUGBY_HAS_BACKUP"
    static let yes: Any = "YES"

    // MARK: - Cache command

    static let defaultXcodeCLTPath = "/Library/Developer/CommandLineTools"

    static let buildTarget = "RugbyPods"
    static let rawBuildLog = supportFolder + "/rawBuild.log"
    static let buildLog = supportFolder + "/build.log"
    static let buildFolder = supportFolder + "/build"
    static let cacheFile = supportFolder + "/cache.yml"

    private static let cacheFolderName = "${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}"
    static func cacheFolder(currentPath: String) -> String {
        "\(currentPath)\(buildFolder)/\(cacheFolderName)"
    }
}

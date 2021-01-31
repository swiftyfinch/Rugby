//
//  Cache.swift
//  
//
//  Created by v.khorkov on 29.01.2021.
//

import Foundation
import ArgumentParser
import Files
import ShellOut
import Rainbow

extension String {
    static let podfileLock = "Podfile.lock"
    static let podsProject = "Pods/Pods.xcodeproj"
    static let podsTargetSupportFiles = "Pods/Target Support Files"

    static let cachedChecksums = supportFolder + "/Checksums"
    static let buildFolder = "${PODS_ROOT}/../" + supportFolder + "/build/Debug-iphonesimulator"
}

private extension String {
    static let supportFolder = ".rugby"
    static let log = supportFolder + "/rugby.log"
    static let buildTarget = "RemotePods"
}

struct Cache: ParsableCommand {
    @Flag(name: .long)
    var verbose = false

    @Flag(name: .long)
    var rebuild = false

    func run() throws {
        let logFile = try Folder.current.createFile(at: .log)
        let buildTarget: String = .buildTarget

        let totalTime = try measure {
            let prepareStep = PrepareStep(logFile: logFile, verbose: verbose)
            let input = try prepareStep.run(buildTarget: buildTarget, needRebuild: rebuild)

            let buildStep = BuildStep(logFile: logFile, verbose: verbose)
            try buildStep.run(scheme: input.buildPods.isEmpty ? nil : buildTarget, checksums: input.checksums)

            let integrateStep = IntegrateStep(logFile: logFile, verbose: verbose)
            try integrateStep.run(remotePods: input.remotePods)

            let cleanupStep = CleanupStep(logFile: logFile, verbose: verbose)
            try cleanupStep.run(buildPods: input.buildPods, buildTarget: buildTarget, remotePods: input.remotePods)
        }
        print("[\(totalTime.formatTime())] ".yellow + "Let's roll 🏈 ".green)
        try shellOut(to: "tput bel")
    }
}

//
//  CacheBuildStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import XcodeProj

struct CacheBuildStep: Step {
    struct Input {
        let scheme: String?
        let checksums: [String]
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Cache

    init(command: Cache, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Build", logFile: logFile, verbose: verbose)
    }

    func run(_ input: Input) throws {
        guard let scheme = input.scheme else {
            progress.print("Skip".yellow)
            return done()
        }

        progress.print("Building ⏱".yellow)
        do {
            try XcodeBuild(project: .podsProject,
                           scheme: scheme,
                           sdk: command.sdk,
                           arch: command.arch).build()
        } catch {
            let podsProject = try XcodeProj(pathString: .podsProject)
            podsProject.removeTarget(name: scheme)
            try podsProject.write(pathString: .podsProject, override: true)
            progress.print("Full build log: ".yellow + .buildLog)
            throw error
        }

        progress.print("Update checksums".yellow)
        try CacheManager().save(CacheFile(checksums: input.checksums,
                                          sdk: command.sdk,
                                          arch: command.arch))
        done()
    }
}

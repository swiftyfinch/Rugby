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
        let checksums: [Checksum]
        let swiftVersion: String?
    }

    let verbose: Bool
    let isLast: Bool
    let progress: Printer

    private let command: Cache
    private let xcargs = ["COMPILER_INDEX_STORE_ENABLE=NO",
                          "SWIFT_COMPILATION_MODE=wholemodule"]
    private let cacheManager = CacheManager()

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
            try XcodeBuild(
                project: .podsProject,
                scheme: scheme,
                sdk: command.sdk,
                arch: command.arch,
                xcargs: xcargs
            ).build()
        } catch {
            let podsProject = try XcodeProj(pathString: .podsProject)
            podsProject.removeTarget(name: scheme)
            try podsProject.write(pathString: .podsProject, override: true)
            throw CacheError.buildFailed
        }

        progress.print("Update checksums".yellow)
        let newChecksums = Set(input.checksums)
        let cachedChecksums = cacheManager.checksumsSet()
        let updatedChecksums = newChecksums.inserts(cachedChecksums).map(\.string).sorted()
        try cacheManager.save(CacheFile(checksums: updatedChecksums,
                                        sdk: command.sdk,
                                        arch: command.arch,
                                        swift: input.swiftVersion,
                                        xcargs: xcargs))
        done()
    }
}

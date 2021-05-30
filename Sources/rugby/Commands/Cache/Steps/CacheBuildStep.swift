//
//  CacheBuildStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

struct CacheBuildStep: Step {
    struct Input {
        let scheme: String?
        let checksums: [Checksum]
        let swift: String?
    }

    let verbose: Int
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

        try progress.spinner("Building".yellow) {
            do {
                try XcodeBuild(
                    project: .podsProject,
                    scheme: scheme,
                    sdk: command.sdk,
                    arch: command.arch,
                    xcargs: xcargs
                ).build()
            } catch {
                let podsProject = try ProjectProvider.shared.readProject(.podsProject)
                podsProject.removeTarget(name: scheme)
                try podsProject.write(pathString: .podsProject, override: true)
                throw CacheError.buildFailed
            }
        }

        progress.print("Update checksums".yellow, level: .vv)
        let cachedChecksums = cacheManager.checksumsMap(sdk: command.sdk)
        let updatedChecksums = input.checksums.reduce(into: cachedChecksums) { checksums, new in
            checksums[new.name] = new
        }
        let checksums = updatedChecksums.map(\.value.string).sorted()
        let newCache = SDKCache(arch: command.arch, swift: input.swift, xcargs: xcargs, checksums: checksums)
        try cacheManager.update(sdk: command.sdk, newCache)
        done()
    }
}

//
//  CacheBuildStep.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct BuildInfo {
    let pods: Set<String>
    let sdk: [SDK]
    let arch: [String]
}

struct CacheBuildStep: Step {
    struct Input {
        let scheme: String?
        let buildInfo: BuildInfo
        let swift: String?
    }

    let verbose: Int
    let isLast: Bool
    let progress: Printer

    private let command: Cache
    private let checksumsProvider: ChecksumsProvider
    private let cacheManager = CacheManager()
    private let xcargsProvider = XCARGSProvider()

    init(command: Cache, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.flags.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Build",
                                     logFile: logFile,
                                     verbose: verbose,
                                     quiet: command.quiet,
                                     nonInteractive: command.nonInteractive)
        self.checksumsProvider = ChecksumsProvider(shouldChecksumContent: command.experimentalChecksumContent)
    }

    func run(_ input: Input) throws {
        guard let scheme = input.scheme else {
            progress.print("Skip".yellow)
            return done()
        }

        let xcargs = xcargsProvider.xcargs(bitcode: command.bitcode, withoutDebugSymbols: command.offDebugSymbols)
        for (sdk, arch) in zip(input.buildInfo.sdk, input.buildInfo.arch) {
            try progress.spinner("Building \("\(sdk)-\(arch)".yellow)") {
                do {
                    try XcodeBuild(
                        project: .podsProject,
                        scheme: scheme,
                        sdk: sdk,
                        arch: arch,
                        config: command.config,
                        xcargs: xcargs
                    ).build()
                } catch {
                    let podsProject = try ProjectProvider.shared.readProject(.podsProject)
                    podsProject.removeTarget(name: scheme)
                    try podsProject.write(pathString: .podsProject, override: true)
                    throw error
                }
            }
        }

        try progress.spinner("Update checksums") {
            for (sdk, arch) in zip(input.buildInfo.sdk, input.buildInfo.arch) {
                let newChecksums = try checksumsProvider.getChecksums(forPods: input.buildInfo.pods)
                let cachedChecksums = cacheManager.checksumsMap(sdk: sdk, config: command.config)
                let updatedChecksums = newChecksums.reduce(into: cachedChecksums) { checksums, new in
                    checksums[new.name] = new
                }
                let checksums = updatedChecksums.map(\.value.string).sorted()
                let newCache = BuildCache(sdk: sdk,
                                          arch: arch,
                                          config: command.config,
                                          swift: input.swift,
                                          xcargs: xcargs,
                                          checksums: checksums)
                try cacheManager.update(cache: newCache)
            }
        }
        done()
    }
}

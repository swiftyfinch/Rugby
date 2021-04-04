//
//  CacheIntegrateStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

final class CacheIntegrateStep: NewStep {
    let name = "Integration"
    let verbose: Bool
    let isLast: Bool
    let progress: RugbyProgressBar

    private let command: Cache

    init(command: Cache, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyProgressBar(title: name, logFile: logFile, verbose: verbose)
    }

    func run(_ input: CachePrepareStep.Output) throws -> CachePrepareStep.Output {
        progress.update(info: "Update paths to builded pods".yellow)
        try CacheIntegration(cacheFolder: .cacheFolder(sdk: command.sdk),
                             buildedProducts: input.remotePods).replacePathsToCache()
        done()
        return input
    }
}

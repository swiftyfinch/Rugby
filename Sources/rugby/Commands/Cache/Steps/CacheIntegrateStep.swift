//
//  CacheIntegrateStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

struct CacheIntegrateStep: Step {
    let verbose: Int
    let isLast: Bool
    let progress: Printer

    private let command: Cache

    init(command: Cache, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Integration", logFile: logFile, verbose: verbose)
    }

    func run(_ targets: Set<String>) throws {
        progress.print("Update paths to builded pods ⏱".yellow, level: .vv)
        try CacheIntegration(cacheFolder: .cacheFolder(sdk: command.sdk),
                             buildedTargets: targets).replacePathsToCache()
        done()
    }
}

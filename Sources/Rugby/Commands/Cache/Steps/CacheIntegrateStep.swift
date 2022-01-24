//
//  CacheIntegrateStep.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct CacheIntegrateStep: Step {
    let verbose: Int
    let isLast: Bool
    let progress: Printer

    private let command: Cache

    init(command: Cache, logFile: File, isLast: Bool = false) {
        self.command = command
        self.verbose = command.flags.verbose
        self.isLast = isLast
        self.progress = RugbyPrinter(title: "Integration", logFile: logFile, verbose: verbose)
    }

    func run(_ targets: Set<String>) throws {
        try progress.spinner("Update paths to built pods") {
            try CacheIntegration(cacheFolder: .cacheFolder,
                                 builtTargets: targets).replacePathsToCache()
        }
        done()
    }
}

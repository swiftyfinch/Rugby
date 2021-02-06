//
//  IntegrateStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

final class IntegrateStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Integration", logFile: logFile, verbose: verbose)
    }

    func run(buildPods: Set<String>) throws {
        try CacheIntegration(cacheFolder: .cacheFolder,
                             buildedProducts: buildPods).replacePathsToCache()
        progress.update(info: "Update paths to builded pods".yellow)
        done()
    }
}

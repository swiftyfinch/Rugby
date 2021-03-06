//
//  CacheIntegrateStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files

final class CacheIntegrateStep: Step {
    init(logFile: File, verbose: Bool) {
        super.init(name: "Integration", logFile: logFile, verbose: verbose)
    }

    func run(remotePods: Set<String>, cacheFolder: String) throws {
        try CacheIntegration(cacheFolder: cacheFolder,
                             buildedProducts: remotePods).replacePathsToCache()
        progress.update(info: "Update paths to builded pods".yellow)
        done()
    }
}

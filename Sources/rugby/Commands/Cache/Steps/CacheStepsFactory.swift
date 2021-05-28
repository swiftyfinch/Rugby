//
//  CacheStepsFactory.swift
//  
//
//  Created by Vyacheslav Khorkov on 12.04.2021.
//

import Files

struct CacheStepsFactory {
    let command: Cache
    let metrics: Metrics
    let logFile: File

    var prepare: CachePrepareStep.Run {
        CachePrepareStep(command: command, metrics: metrics, logFile: logFile).run
    }

    var build: CacheBuildStep.Run {
        CacheBuildStep(command: command, logFile: logFile).run
    }

    var integrate: CacheIntegrateStep.Run {
        CacheIntegrateStep(command: command, logFile: logFile).run
    }

    var cleanup: CacheCleanupStep.Run {
        CacheCleanupStep(command: command, metrics: metrics, logFile: logFile, isLast: true).run
    }
}

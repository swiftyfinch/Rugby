//
//  CacheRun.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

import Files

extension Cache {
    func wrappedRun() throws {
        let logFile = try Folder.current.createFile(at: .log)
        let metrics = Metrics()
        let time = try measure {
            let prepare = CachePrepareStep(command: self, metrics: metrics, logFile: logFile)
            let build = CacheBuildStep(command: self, logFile: logFile)
            let integrate = CacheIntegrateStep(command: self, logFile: logFile)
            let cleanup = CacheCleanupStep(command: self, logFile: logFile)
            try (prepare.run | build.run | integrate.run | cleanup.run)(.buildTarget)
        }
        print(time.output() + metrics.output() + .finalMessage)
    }
}

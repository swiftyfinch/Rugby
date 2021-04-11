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

            let info = try prepare.run(.buildTarget)
            try build.run(.init(scheme: info.scheme, checksums: info.checksums))
            try integrate.run(info.remotePods)
            try cleanup.run(.init(scheme: info.scheme, pods: info.remotePods, products: info.products))
        }
        print(time.output() + metrics.output() + .finalMessage)
    }
}

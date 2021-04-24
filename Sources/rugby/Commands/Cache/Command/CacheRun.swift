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
            let factory = CacheStepsFactory(command: self, metrics: metrics, logFile: logFile)
            let info = try factory.prepare(.buildTarget)
            try factory.build(.init(scheme: info.scheme, checksums: info.checksums))
            try factory.integrate(info.remotePods)
            try factory.cleanup(.init(scheme: info.scheme, pods: info.remotePods, products: info.products))
        }
        printFinalMessage(logFile: logFile, time: time, metrics: metrics, more: !hideMetrics)
    }
}

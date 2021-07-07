//
//  CacheRun.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

extension Cache: Command {
    mutating func run(logFile: File) throws -> Metrics? {
        // For simulators use arch x86_64 by default.
        if sdk == .sim && arch == nil { arch = ARCH.x86_64 }

        let metrics = CacheMetrics(project: String.podsProject.basename())
        let factory = CacheStepsFactory(command: self, metrics: metrics, logFile: logFile)
        let info = try factory.prepare(.buildTarget)
        try factory.build(.init(scheme: info.scheme, buildPods: info.buildPods, swift: info.swiftVersion))
        try factory.integrate(info.targets)
        try factory.cleanup(.init(scheme: info.scheme, targets: info.targets, products: info.products))
        return metrics
    }
}

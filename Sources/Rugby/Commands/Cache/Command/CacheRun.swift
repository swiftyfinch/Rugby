//
//  CacheRun.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

extension Cache: Command {
    var quiet: Bool { flags.quiet }

    mutating func run(logFile: File) throws -> Metrics? {
        if !arch.isEmpty, sdk.count != arch.count { throw CacheError.incorrectArchCount }
        if arch.isEmpty { arch = sdk.map(\.defaultARCH) /* Set default arch for each sdk */ }

        let metrics = CacheMetrics(project: String.podsProject.basename())
        let factory = CacheStepsFactory(command: self, metrics: metrics, logFile: logFile)
        let info = try factory.prepare(.buildTarget)
        try factory.build(.init(scheme: info.scheme, buildInfo: info.buildInfo, swift: info.swiftVersion))
        try factory.integrate(info.targets)
        try factory.cleanup(.init(scheme: info.scheme, targets: info.targets, products: info.products))
        return metrics
    }
}

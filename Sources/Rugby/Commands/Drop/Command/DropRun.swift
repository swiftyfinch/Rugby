//
//  DropRun.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

extension Drop: Command {
    var quiet: Bool { flags.quiet }

    mutating func run(logFile: File) throws -> Metrics? {
        if testFlight, flags.verbose == 0 { flags.verbose = 1 }
        let metrics = DropMetrics(project: project.basename())
        let factory = DropStepFactory(command: self, metrics: metrics, logFile: logFile)
        let (targets, products) = try factory.prepare(none)
        try factory.remove(.init(targets: targets,
                                 products: products,
                                 testFlight: testFlight,
                                 project: project,
                                 keepSources: keepSources))
        return metrics
    }
}

/// Shortcut for Void()
let none: Void = ()

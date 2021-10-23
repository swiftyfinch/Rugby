//
//  Focus.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

extension Focus: Command {
    mutating func run(logFile: File) throws -> Metrics? {
        if testFlight, flags.verbose == 0 { flags.verbose = 1 }
        let metrics = DropMetrics(project: project.basename())
        let focusFactory = FocusStepFactory(command: self, metrics: metrics, logFile: logFile)
        let (targets, products) = try focusFactory.prepare(none)
        let drop = DropRemoveStep(verbose: flags.verbose, metrics: metrics, logFile: logFile, isLast: true).run
        try drop(.init(targets: targets,
                       products: products,
                       testFlight: testFlight,
                       project: project,
                       keepSources: keepSources))
        return metrics
    }
}

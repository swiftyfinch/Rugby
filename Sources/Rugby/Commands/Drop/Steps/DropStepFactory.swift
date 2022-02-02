//
//  DropStepFactory.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 12.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct DropStepFactory {
    let command: Drop
    let metrics: Metrics
    let logFile: File

    var prepare: DropPrepareStep.Run {
        DropPrepareStep(command: command, metrics: metrics, logFile: logFile).run
    }

    var remove: DropRemoveStep.Run {
        DropRemoveStep(command: command,
                       verbose: command.flags.verbose,
                       metrics: metrics,
                       logFile: logFile,
                       isLast: true).run
    }
}

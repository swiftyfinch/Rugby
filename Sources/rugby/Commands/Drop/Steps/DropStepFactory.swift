//
//  DropStepFactory.swift
//  
//
//  Created by Vyacheslav Khorkov on 12.04.2021.
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
        DropRemoveStep(command: command, metrics: metrics, logFile: logFile, isLast: true).run
    }
}

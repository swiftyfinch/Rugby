//
//  FocusStepFactory.swift
//  
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//

import Files

struct FocusStepFactory {
    let command: Focus
    let metrics: Metrics
    let logFile: File

    var prepare: FocusPrepareStep.Run {
        FocusPrepareStep(command: command, metrics: metrics, logFile: logFile).run
    }
}

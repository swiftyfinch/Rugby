//
//  FocusStepFactory.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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

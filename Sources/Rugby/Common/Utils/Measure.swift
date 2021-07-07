//
//  Measure.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

func measure(_ job: () throws -> Void) rethrows -> Double {
    let begin = ProcessInfo.processInfo.systemUptime
    try job()
    return ProcessInfo.processInfo.systemUptime - begin
}

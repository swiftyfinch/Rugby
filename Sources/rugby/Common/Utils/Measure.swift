//
//  Measure.swift
//  
//
//  Created by v.khorkov on 04.01.2021.
//

import Foundation

func measure(_ job: () throws -> Void) rethrows -> Double {
    let begin = ProcessInfo.processInfo.systemUptime
    try job()
    return ProcessInfo.processInfo.systemUptime - begin
}

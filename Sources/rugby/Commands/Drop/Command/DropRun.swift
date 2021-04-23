//
//  DropRun.swift
//  
//
//  Created by Vyacheslav Khorkov on 05.04.2021.
//

import Files

extension Drop {
    func wrappedRun() throws {
        let logFile = try Folder.current.createFile(at: .log)
        let metrics = Metrics()
        let time = try measure {
            let factory = DropStepFactory(command: self, metrics: metrics, logFile: logFile)
            let (targets, products) = try factory.prepare(none)
            try factory.remove(.init(targets: targets, products: products))
        }
        printFinalMessage(logFile: logFile, time: time, metrics: metrics)
    }
}

/// Shortcut for Void()
let none: Void = ()

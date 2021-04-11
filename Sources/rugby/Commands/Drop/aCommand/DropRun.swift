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
            let prepare = DropPrepareStep(command: self, metrics: metrics, logFile: logFile)
            let remove = DropRemoveStep(command: self, logFile: logFile, isLast: true)

            let (targets, products) = try prepare.run(none)
            try remove.run(.init(targets: targets, products: products))
        }
        print(time.output() + metrics.output() + .finalMessage)
    }
}

/// Shortcut for Void()
let none: Void = ()

//
//  File.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import ArgumentParser
import Files

struct Log: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "Print last command log."
    )

    func run() throws {
        let logFile = try Folder.current.createFile(at: .log)
        let step = LogStep(logFile: logFile, verbose: false, isLast: true)
        try step.run()
    }
}

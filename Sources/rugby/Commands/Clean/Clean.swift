//
//  Clean.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import ArgumentParser
import Files

struct Clean: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "Remove .rugby folder."
    )

    func run() throws {
        let logFile = try Folder.current.createFile(at: .log)
        let step = CleanStep(logFile: logFile, verbose: false, isLast: true)
        try step.run()
    }
}

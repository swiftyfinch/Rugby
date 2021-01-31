//
//  LogStep.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import Files
import ShellOut

final class LogStep: Step {
    init(logFile: File, verbose: Bool, isLast: Bool) {
        super.init(name: "Clean", logFile: logFile, verbose: verbose, isLast: isLast)
    }

    func run() throws {
        if Folder.current.containsFile(at: .log) {
            try shellOut(to: "cat " + .log)
        } else {
            progress.update(info: "Can't find log.".red)
        }
        done()
    }
}

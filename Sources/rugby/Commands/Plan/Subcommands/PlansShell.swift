//
//  Shell.swift
//  
//
//  Created by Vyacheslav Khorkov on 07.05.2021.
//

import Files

struct Shell: Command {
    let run: String
    let verbose: Bool

    func run(logFile: File) throws -> Metrics? {
        let progress = RugbyPrinter(title: "Shell 🐚", logFile: logFile, verbose: true)
        progress.print(run.yellow)
        if verbose {
            try printShell(run)
        } else {
            try shell(run)
        }
        progress.done()
        return nil
    }
}

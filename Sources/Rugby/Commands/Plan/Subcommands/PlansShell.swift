//
//  Shell.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 07.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import Files

struct Shell: Command {
    let run: String
    let verbose: Int

    func run(logFile: File) throws -> Metrics? {
        let progress = RugbyPrinter(title: "Shell 🐚", logFile: logFile, verbose: .verbose)
        progress.print(run.yellow)
        if verbose.bool {
            try printShell(run)
        } else {
            try progress.spinner("Running") {
                try shell(run)
            }
        }
        progress.done()
        resetProjectsCache()
        return nil
    }

    // Shell command can modify projects
    func resetProjectsCache() {
        ProjectProvider.shared.reset()
    }
}

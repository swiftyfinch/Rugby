//
//  Shell.swift
//  
//
//  Created by Vyacheslav Khorkov on 07.05.2021.
//

import Files

struct Shell: Command {
    let run: String

    func run(logFile: File) throws -> Metrics? {
        let progress = RugbyPrinter(title: "Shell 🐚")
        progress.print(run.yellow)
        try printShell(run)
        return nil
    }
}

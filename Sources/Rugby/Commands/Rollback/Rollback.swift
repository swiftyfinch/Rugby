//
//  Rollback.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 16.06.2022.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import Files

struct Rollback: ParsableCommand, Command {
    @Flag(name: .shortAndLong, help: "Print more information.") var verbose: Int
    @Flag(name: .shortAndLong, help: "Print nothing.") var quiet = false
    @Flag(help: "Format output for non-interactive terminal sessions (reduce loading spinner output).")
    var nonInteractive = false

    static var configuration = CommandConfiguration(
        abstract: "• Deintegrate Rugby from your project."
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: false) {
            try wrappedRun()
        }
    }
}

extension Rollback {
    mutating func run(logFile: File) throws -> Metrics? {
        let progress = RugbyPrinter(title: "Rollback",
                                    logFile: logFile,
                                    verbose: verbose,
                                    quiet: quiet,
                                    nonInteractive: nonInteractive)
        let backupManager = BackupManager(progress: progress)
        if verbose.bool {
            try backupManager.rollback()
        } else {
            try progress.spinner("Rollback") {
                try backupManager.rollback()
            }
        }
        progress.done()
        return nil
    }
}

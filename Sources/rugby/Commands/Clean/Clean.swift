//
//  Clean.swift
//  
//
//  Created by v.khorkov on 31.01.2021.
//

import ArgumentParser
import Files

struct Clean: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Remove .rugby cache folder.",
        shouldDisplay: false
    )

    func run() throws {
        try WrappedError.wrap(playBell: false) {
            try CleanStep().run()
        }
    }
}

// MARK: - CleanStep

struct CleanStep: Step {
    let isLast = true
    let progress: Printer

    init() {
        self.progress = RugbyPrinter(title: "Clean", verbose: true)
    }

    func run(_ input: Void) {
        try? Folder.current.subfolder(at: .buildFolder).delete()
        progress.print("Removed \(String.buildFolder)".yellow)

        try? Folder.current.file(at: .buildLog).delete()
        progress.print("Removed \(String.buildLog)".yellow)

        try? Folder.current.file(at: .log).delete()
        progress.print("Removed \(String.log)".yellow)

        try? Folder.current.file(at: .cacheFile).delete()
        progress.print("Removed \(String.cacheFile)".yellow)

        done()
    }
}

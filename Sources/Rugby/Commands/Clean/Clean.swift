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
        abstract: "• Remove cache except \("plans.yml".yellow) and logs."
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
        self.progress = RugbyPrinter(title: "Clean", verbose: .verbose)
    }

    func run(_ input: Void) {
        if (try? Folder.current.subfolder(at: .buildFolder).delete()) != nil {
            progress.print("Removed \(String.buildFolder)".yellow)
        }

        let filesForDelete: [String] = [.cacheFile]
        filesForDelete.forEach {
            if (try? Folder.current.file(at: $0).delete()) != nil {
                progress.print("Removed \($0)".yellow)
            }
        }

        done()
    }
}

//
//  Clean.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 31.01.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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
        self.progress = RugbyPrinter(title: "Clean", verbose: .verbose, quiet: false, nonInteractive: false)
    }

    func run(_ input: Void) {
        if Folder.current.deleteSubfolderIfExists(at: .backupFolder) {
            progress.print("Removed \(String.buildFolder)".yellow)
        }

        let filesForDelete: [String] = [.cacheFile]
        filesForDelete.forEach {
            if Folder.current.deleteFileIfExists(at: $0) {
                progress.print("Removed \($0)".yellow)
            }
        }

        done()
    }
}

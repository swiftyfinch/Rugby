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
        abstract: "Remove .rugby cache folder."
    )

    func run() throws {
        try WrappedError.wrap {
            try CleanStep().run()
        }
    }
}

// MARK: - CleanStep

struct CleanStep: Step {
    let name = "Clean"
    let isLast = true
    let progress: RugbyProgressBar

    init() {
        self.progress = RugbyProgressBar(title: name)
    }

    func run(_ input: Void) {
        try? Folder.current.subfolder(at: .supportFolder).delete()
        done()
    }
}

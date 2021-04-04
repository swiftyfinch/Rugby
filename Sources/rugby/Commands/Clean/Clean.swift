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
        abstract: "Remove .rugby cache folder."
    )

    func run() throws {
        let logger = RugbyProgressBar(title: "Clean")
        CleanStep(progress: logger).run()
    }
}

struct CleanStep: NewStep {
    let name = "Clean"
    let isLast = true
    let progress: RugbyProgressBar

    func run(_ input: Void) {
        try? Folder.current.subfolder(at: .supportFolder).delete()
        done()
    }
}

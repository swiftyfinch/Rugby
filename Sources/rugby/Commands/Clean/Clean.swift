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
        let step = CleanStep(verbose: false, isLast: true)
        try step.run()
    }
}

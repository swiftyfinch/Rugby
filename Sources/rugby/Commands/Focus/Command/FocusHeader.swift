//
//  FocusHeader.swift
//  
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//

import ArgumentParser

struct Focus: ParsableCommand {
    @Argument(parsing: .remaining) var targets: [String]
    @Flag(name: .shortAndLong, help: "Show output without any changes.") var testFlight = false
    @Option(name: .shortAndLong, help: "Project location.") var project: String = .podsProject
    @Flag(name: .shortAndLong, help: "Keep sources & resources in project.\n") var keepSources = false

    @Flag(name: .long, inversion: .prefixedNo, help: "Play bell sound on finish.") var bell = true
    @Flag(help: "Hide metrics.") var hideMetrics = false
    @Flag(name: .shortAndLong, help: "Print more information.") var verbose = false

    static var configuration = CommandConfiguration(
        abstract: "• Keep selected targets and all their dependencies.",
        discussion: """
        Checkout documentation for more info:
        📖 \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Focus.md".cyan)
        """,
        shouldDisplay: false
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: bell) {
            try wrappedRun()
        }
    }
}

//
//  FocusHeader.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 09.05.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser

private extension ArgumentHelp {
    static let targetsHelp: ArgumentHelp = """
    RegEx targets for focusing.
    \("- Use backward slashes \\ for escaping special characters; ".yellow)
    \("- Add \"\" for safer use (without shell's interpretation).".yellow)
    """
}

struct Focus: ParsableCommand {
    @Argument(parsing: .remaining, help: .targetsHelp) var targets: [String]
    @Flag(name: .shortAndLong, help: "Show output without any changes.") var testFlight = false
    @Option(name: .shortAndLong, help: "Project location.") var project: String = .podsProject
    @Flag(name: .shortAndLong, help: "Keep sources & resources in project.\n") var keepSources = false

    @Flag(name: .long, inversion: .prefixedNo, help: "Play bell sound on finish.") var bell = true
    @Flag(help: "Hide metrics.") var hideMetrics = false
    @Flag(name: .shortAndLong, help: "Print more information.") var verbose: Int

    static var configuration = CommandConfiguration(
        abstract: "• Keep only selected targets and all their dependencies.",
        discussion: """
        Checkout documentation for more info:
        📖 \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Focus.md".cyan)
        """
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: bell) {
            try wrappedRun()
        }
    }
}

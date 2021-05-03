//
//  DropHeader.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import ArgumentParser
import Files

private extension ArgumentHelp {
    static let targetsHelp: ArgumentHelp = """
    RegEx targets for removing.
    \("- Use backward slashes \\ for escaping special characters; ".yellow)
    \("- Add \"\" for safer use (without shell's interpretation).".yellow)
    """
}

struct Drop: ParsableCommand {
    @Argument(parsing: .remaining, help: .targetsHelp) var targets: [String]
    @Flag(name: .shortAndLong, help: "Invert regEx.") var invert = false
    @Option(name: .shortAndLong, help: "Project location.") var project: String = .podsProject
    @Flag(name: .shortAndLong, help: "Show output without any changes.") var testFlight = false
    @Flag(name: .shortAndLong, help: "Keep sources & resources in project.") var keepSources = false
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Exclude targets.") var exclude: [String] = []
    @Flag(help: "Hide metrics.\n") var hideMetrics = false

    @Flag(name: .long, inversion: .prefixedNo, help: "Play bell sound on finish.") var bell = true
    @Flag(name: .shortAndLong, help: "Print more information.") var verbose = false

    static var configuration = CommandConfiguration(
        abstract: "Remove any targets by RegEx."
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: bell) {
            try wrappedRun()
        }
    }
}

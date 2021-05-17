//
//  DropHeader.swift
//  
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//

import ArgumentParser

private extension ArgumentHelp {
    static let targetsHelp: ArgumentHelp = """
    RegEx targets for removing.
    \("- Use backward slashes \\ for escaping special characters; ".yellow)
    \("- Add \"\" for safer use (without shell's interpretation).".yellow)
    """
}

struct Drop: ParsableCommand {
    @Argument(parsing: .remaining, help: .targetsHelp) var targets: [String]
    @Flag(name: .shortAndLong, help: "Invert RegEx.") var invert = false
    @Option(name: .shortAndLong,
            parsing: .upToNextOption,
            help: "Exclude targets. (not RegEx)") var exclude: [String] = []
    @Flag(name: .shortAndLong, help: "Show output without any changes.") var testFlight = false
    @Option(name: .shortAndLong, help: "Project location.") var project: String = .podsProject
    @Flag(name: .shortAndLong, help: "Keep sources & resources in project.\n") var keepSources = false

    @Flag(name: .long, inversion: .prefixedNo, help: "Play bell sound on finish.") var bell = true
    @Flag(help: "Hide metrics.") var hideMetrics = false
    @Flag(name: .shortAndLong, help: "Print more information.") var verbose = false

    static var configuration = CommandConfiguration(
        abstract: "• Remove any targets by RegEx.",
        discussion: """
        Checkout documentation for more info:
        📖 \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Drop.md".cyan)
        """
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: bell) {
            try wrappedRun()
        }
    }
}

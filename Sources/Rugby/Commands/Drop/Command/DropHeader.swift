//
//  DropHeader.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 28.02.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
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

    @OptionGroup var flags: CommonFlags

    static var configuration = CommandConfiguration(
        abstract: "• Remove any targets by RegEx.",
        discussion: """
        Checkout documentation for more info:
        📖 \("https://github.com/swiftyfinch/Rugby/blob/main/Docs/Drop.md".cyan)
        """
    )

    mutating func run() throws {
        try WrappedError.wrap(playBell: flags.bell) {
            try wrappedRun()
        }
    }
}

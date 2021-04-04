//
//  Drop.swift
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
    @Option(name: .shortAndLong,
            parsing: .upToNextOption,
            help: "Exclude targets.\n") var exclude: [String] = []

    @Flag(name: .shortAndLong, help: "Print more information.") var verbose = false

    static var configuration: CommandConfiguration = .init(
        abstract: "Remove any targets by RegEx."
    )

    func run() throws {
        try WrappedError.wrap(privateRun)
    }

    private func privateRun() throws {
        var outputMessage = ""
        let totalTime = try measure {
            let logFile = try Folder.current.createFile(at: .log)

            let prepare = DropPrepareStep(command: self, logFile: logFile, isLast: testFlight)
            let remove = DropRemoveStep(command: self, logFile: logFile, isLast: true)
            let info = try (prepare.run | remove.run)(none)

            outputMessage = "Removed \(info.foundTargets.count)/\(info.targetsCount) targets. ".green
            outputMessage += "Let's roll 🏈".green
        }
        print("[\(totalTime.formatTime())] ".yellow + outputMessage)
    }
}

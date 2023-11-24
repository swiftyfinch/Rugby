import ArgumentParser
import Fish
import Foundation
import RugbyFoundation

struct Analyse: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "analyse",
        abstract: "For analysis and debugging hash",
        discussion: """
            # TODO if needed
            \(Links.commandsHelp("analyse.md"))
            \(Links.docs("analyse.md"))
        """
    )

    @Flag(help: "filter only not found binaries")
    var onlyNotFound = false

    @Option(name: .long, help: "output directory for hashes")
    var hashOutputDir: String?

    @OptionGroup
    var buildOptions: BuildOptions

    @OptionGroup
    var commonOptions: CommonOptions

    func run() async throws {
        try await run(body,
                      outputType: commonOptions.output,
                      logLevel: commonOptions.logLevel)
    }
}

// MARK: - Body

extension Analyse: RunnableCommand {
    func body() async throws {
        let hashOutputDir = hashOutputDir ?? {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
            let dataString = formatter.string(from: date)
            return "/tmp/rugby_\(dataString)_\(arc4random_uniform(100))"
        }()

        try await dependencies.analyseManager()
            .analyse(onlyNotFound: onlyNotFound,
                     hashDir: hashOutputDir,
                     targetsRegex: regex(
                         patterns: buildOptions.targetsOptions.targetsAsRegex,
                         exactMatches: buildOptions.targetsOptions.targets
                     ), exceptTargetsRegex: regex(
                         patterns: buildOptions.targetsOptions.exceptAsRegex,
                         exactMatches: buildOptions.targetsOptions.exceptTargets
                     ), options: buildOptions.xcodeBuildOptions())
    }
}

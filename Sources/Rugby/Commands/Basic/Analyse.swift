import ArgumentParser
import Fish
import Foundation
import RugbyFoundation

struct Analyse: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "analyse",
        abstract: "Tools for auxiliary analysis.",
        subcommands: [Analyse.Hasher.self]
    )
}

// MARK: - Hasher Subcommand

extension Analyse {
    struct Hasher: AsyncParsableCommand, RunnableCommand {
        static var configuration = CommandConfiguration(
            commandName: "hasher",
            abstract: "Analyse target hasher."
        )

        @Flag(help: "analyse only targets with missing binaries")
        var missingBinaryOnly = false

        @Option(name: .long, help: "output directory for hash yamls, '/tmp' as default")
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

        func body() async throws {
            let hashOutputDir = hashOutputDir ?? {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss_SSSS"
                let dataString = formatter.string(from: date)
                return "/tmp/rugby_\(dataString))"
            }()

            try await dependencies.analyseHasherManager()
                .analyse(missingBinariesOnly: missingBinaryOnly,
                         outputDir: hashOutputDir,
                         targetsRegex: regex(
                             patterns: buildOptions.targetsOptions.targetsAsRegex,
                             exactMatches: buildOptions.targetsOptions.targets
                         ), exceptTargetsRegex: regex(
                             patterns: buildOptions.targetsOptions.exceptAsRegex,
                             exactMatches: buildOptions.targetsOptions.exceptTargets
                         ), options: buildOptions.xcodeBuildOptions())
        }
    }
}

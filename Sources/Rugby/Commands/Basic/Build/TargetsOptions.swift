import ArgumentParser
import RugbyFoundation

struct TargetsOptions: ParsableCommand {
    @Option(name: .shortAndLong,
            parsing: .upToNextOption,
            help: "Target names to select. Empty means all targets.")
    var targets: [String] = []

    @Option(name: [.long, .customShort("g")],
            parsing: .upToNextOption,
            help: "Regular expression patterns to select targets. ")
    var targetsAsRegex: [String] = []

    @Option(name: [.customLong("except"), .short],
            parsing: .upToNextOption,
            help: "Target names to exclude.")
    var exceptTargets: [String] = []

    @Option(name: [.long, .customShort("x")],
            parsing: .upToNextOption,
            help: "Regular expression patterns to exclude targets.")
    var exceptAsRegex: [String] = []

    @Flag(name: .customLong("try"),
          help: "Run command in mode, with only the selected targets are printed.")
    var tryMode = false
}

extension TargetsOptions {
    func foundation() throws -> RugbyFoundation.TargetsOptions {
        try .init(
            tryMode: tryMode,
            targetsRegex: regex(patterns: targetsAsRegex, exactMatches: targets),
            exceptTargetsRegex: regex(patterns: exceptAsRegex, exactMatches: exceptTargets)
        )
    }
}

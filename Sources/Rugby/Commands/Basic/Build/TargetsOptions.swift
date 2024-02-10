import ArgumentParser

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
}

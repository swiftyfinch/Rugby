import ArgumentParser

struct TargetsOptions: ParsableCommand {
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Targets for building. Empty means all targets.")
    var targets: [String] = []

    @Option(name: [.long, .customShort("g")],
            parsing: .upToNextOption,
            help: "Targets for building as a RegEx pattern.")
    var targetsAsRegex: [String] = []

    @Option(name: [.customLong("except"), .short], parsing: .upToNextOption, help: "Exclude targets from building.")
    var exceptTargets: [String] = []

    @Option(name: [.long, .customShort("x")],
            parsing: .upToNextOption,
            help: "Exclude targets from building as a RegEx pattern.")
    var exceptAsRegex: [String] = []
}

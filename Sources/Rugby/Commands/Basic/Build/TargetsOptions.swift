import ArgumentParser

/// Namespace for providing correct help information based on type
enum TargetsOptionsNameSpace {
    enum Deleting {}
    enum Building {}
    enum Using {}
}

struct TargetsOptions<T>: ParsableCommand {
    @Option(name: .shortAndLong, parsing: .upToNextOption, help: Self.targetsHelp)
    var targets: [String] = []

    @Option(name: [.long, .customShort("g")],
            parsing: .upToNextOption,
            help: Self.targetsAsRegexHelp)
    var targetsAsRegex: [String] = []

    @Option(name: [.customLong("except"), .short], parsing: .upToNextOption, help: Self.exceptTargetsHelp)
    var exceptTargets: [String] = []

    @Option(name: [.long, .customShort("x")],
            parsing: .upToNextOption,
            help: Self.exceptAsRegexHelp)
    var exceptAsRegex: [String] = []
}

extension TargetsOptions {
    static var command: String {
        switch T.self {
        case is TargetsOptionsNameSpace.Deleting.Type:
            return "deleting"
        case is TargetsOptionsNameSpace.Using.Type:
            return "using"
        default:
            return "building"
        }
    }

    func mapTo<U>(type _: U.Type) -> TargetsOptions<U> {
        TargetsOptions<U>(
            targets: targets,
            targetsAsRegex: targetsAsRegex,
            exceptTargets: exceptTargets,
            exceptAsRegex: exceptAsRegex
        )
    }
}

extension TargetsOptions {
    static var targetsHelp: ArgumentHelp {
        "Targets for building. Empty means all targets."
    }

    static var targetsAsRegexHelp: ArgumentHelp {
        "Targets for \(command) as a RegEx pattern."
    }

    static var exceptTargetsHelp: ArgumentHelp {
        "Exclude targets from \(command)."
    }

    static var exceptAsRegexHelp: ArgumentHelp {
        "Exclude targets from \(command) as a RegEx pattern."
    }
}

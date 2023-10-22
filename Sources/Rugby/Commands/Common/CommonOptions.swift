import ArgumentParser
import RugbyFoundation

struct CommonOptions: ParsableCommand {
    @Option(name: .shortAndLong,
            help: "Output mode: fold, multiline, quiet.")
    var output: OutputType = .fold

    @Flag(name: .shortAndLong, help: "Increase verbosity level.")
    var verbose: Int

    @Flag(name: .shortAndLong, help: "Decrease verbosity level.")
    var quiet: Int
}

enum OutputType: String, ExpressibleByArgument {
    case fold
    case multiline
    case raw
    case silence

    init?(rawValue: String) {
        switch rawValue {
        case "fold", "f":
            self = .fold
        case "multiline", "m":
            self = .multiline
        case "raw", "r":
            self = .raw
        case "silence", "s", "quiet", "q":
            self = .silence
        default:
            return nil
        }
    }
}

extension CommonOptions {
    var logLevel: LogLevel {
        let value = verbose - quiet
        if let logLevel = LogLevel(rawValue: value) {
            return logLevel
        }
        if value < LogLevel.allCases[0].rawValue {
            return LogLevel.allCases[0]
        } else {
            let logLevelsLastIndex = LogLevel.allCases.count - 1
            return LogLevel.allCases[logLevelsLastIndex]
        }
    }
}

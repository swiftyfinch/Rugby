import ArgumentParser
import RugbyFoundation

struct CommonOptions: ParsableCommand {
    @Option(name: .shortAndLong,
            help: "Output mode: fold, multiline, quiet.")
    var output: OutputType = .fold

    @Flag(name: .shortAndLong, help: "Log level.")
    var verbose: Int
}

enum OutputType: String, ExpressibleByArgument {
    case fold
    case multiline
    case quiet

    init?(rawValue: String) {
        switch rawValue {
        case "fold", "f":
            self = .fold
        case "multiline", "m":
            self = .multiline
        case "quiet", "q":
            self = .quiet
        default:
            return nil
        }
    }
}

extension LogLevel: EnumerableFlag {}

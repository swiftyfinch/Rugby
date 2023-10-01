import ArgumentParser
import ArgumentParserToolInfo
import Foundation

// MARK: - Interface

enum HelpDumperError: LocalizedError {
    case failedDataEncoding

    var errorDescription: String? {
        switch self {
        case .failedDataEncoding:
            return "Failed to parse commands help."
        }
    }
}

// MARK: - Implementation

final class HelpDumper {
    private typealias Error = HelpDumperError
    private let decoder = JSONDecoder()

    func dump(command: ParsableCommand.Type) throws -> CommandInfoV0 {
        let arguments = Array(CommandLine.arguments.dropFirst())
        let commandType = command.parseCommandType(arguments: arguments,
                                                   lastNotDefaultTransition: true).type
        guard let data = commandType._dumpHelp().data(using: .utf8) else {
            throw Error.failedDataEncoding
        }
        return try decoder.decode(ToolInfoV0.self, from: data).command
    }
}

import Fish
import XcbeautifyLib

protocol IBuildLogFormatter {
    func format(
        line: String,
        output: @escaping (String, OutputType) throws -> Void
    ) throws

    func finish(output: @escaping (String, OutputType) throws -> Void) throws
}

// MARK: - Implementation

final class BuildLogFormatter {
    private let workingDirectory: IFolder
    private let colored: Bool
    private var buffer: [String] = []
    private let minBufferSize = 3
    private(set) lazy var parser: Parser =
        Parser(colored: colored, renderer: .terminal) { [weak self] in
            guard let self, self.buffer.isNotEmpty else { return nil }
            return self.buffer.removeFirst()
        }

    init(workingDirectory: IFolder, colored: Bool) {
        self.workingDirectory = workingDirectory
        self.colored = colored
    }

    // MARK: - Private

    private func parse(completion: @escaping (String, OutputType) throws -> Void) throws {
        guard var formatted = parser.parse(line: buffer.removeFirst()) else { return }
        if parser.outputType == .error {
            formatted = formatError(formatted)
        }
        try completion(formatted, parser.outputType)
    }

    private func formatError(_ error: String) -> String {
        let formattedError = error
            .replacingOccurrences(of: "error: ", with: "")
            .replacingOccurrences(of: "❌", with: "")
            .replacingOccurrences(of: "[x]", with: "")
            .replacingOccurrences(of: "\(workingDirectory.path)/", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let lines = formattedError.components(separatedBy: .newlines)
        if lines.count == 3 {
            let firstLineComponents = lines[0].components(separatedBy: ": ")
            guard firstLineComponents.count == 2 else { return formattedError }

            let path = firstLineComponents[0]
            let formattedTail = "\(firstLineComponents[1].raw.uppercasedFirstLetter)"
            let prefixCount = lines[1].raw.prefixCount()
            let formattedLines = [
                "\(formattedTail.trimmingCharacters(in: .whitespaces)).".red,
                "\(path):".yellow,
                lines[1].raw.removing(prefixCount).white,
                lines[2].raw.removing(prefixCount).cyan
            ]
            return formattedLines.joined(separator: "\n")
        }

        return formattedError
    }
}

// MARK: - IBuildLogFormatter

extension BuildLogFormatter: IBuildLogFormatter {
    func format(
        line: String,
        output: @escaping (String, OutputType) throws -> Void
    ) throws {
        buffer.append(line)
        if buffer.count >= minBufferSize {
            try parse(completion: output)
        }
    }

    func finish(output: @escaping (String, OutputType) throws -> Void) throws {
        while buffer.isNotEmpty {
            try parse(completion: output)
        }
    }
}

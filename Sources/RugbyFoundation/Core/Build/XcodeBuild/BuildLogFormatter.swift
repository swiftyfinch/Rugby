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
        guard let parsed = parser.parse(line: buffer.removeFirst()) else { return }
        var formatted: String? = parsed
        if parser.outputType == .error {
            formatted = formatError(parsed)
        } else if [.test, .testCase].contains(parser.outputType) {
            formatted = formatTest(line: parsed, type: parser.outputType)
        }
        if let formatted {
            try completion(formatted, parser.outputType)
        }
    }

    private func formatTest(line: String, type: OutputType) -> String? {
        var line = line.removingStyle(.bold)
        switch type {
        case .test:
            guard line.raw != "All tests" else { return nil }
            if line.hasSuffix(".xctest") {
                line = String(line.dropLast(".xctest".count))
                line = "\("⚑".yellow) \(line.green)"
            } else {
                line = "  \(line):".green
            }
            return line
        case .testCase:
            line = line.replacingOccurrences(of: "✔", with: "✓")
            line = String(line.dropFirst(2))
            return line
        default:
            return nil
        }
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

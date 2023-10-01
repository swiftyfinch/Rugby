import XcbeautifyLib

final class BuildLogFormatter {
    private let colored: Bool
    private var buffer: [String] = []
    private let minBufferSize = 3
    private(set) lazy var parser: Parser =
        Parser(colored: colored, renderer: .terminal) { [weak self] in
            guard let self, self.buffer.isNotEmpty else { return nil }
            return self.buffer.removeFirst()
        }

    init(colored: Bool) {
        self.colored = colored
    }

    func format(line: String,
                output: @escaping (String, OutputType) throws -> Void) throws {
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

    // MARK: - Private

    private func parse(completion: @escaping (String, OutputType) throws -> Void) throws {
        guard let formatted = parser.parse(line: buffer.removeFirst()) else { return }
        try completion(formatted, parser.outputType)
    }
}

import Fish
import Foundation
import SwiftShell
import XcbeautifyLib

// MARK: - Interface

protocol IXcodeBuildExecutor {
    func run(
        _ command: String,
        rawLogPath: String,
        logPath: String,
        args: Any...
    ) async throws
}

// MARK: - Implementation

final class XcodeBuildExecutor: IXcodeBuildExecutor, Loggable {
    let logger: ILogger
    private let shellExecutor: IShellExecutor
    private let logFormatter: IBuildLogFormatter

    init(logger: ILogger,
         shellExecutor: IShellExecutor,
         logFormatter: IBuildLogFormatter) {
        self.logger = logger
        self.shellExecutor = shellExecutor
        self.logFormatter = logFormatter
    }

    func run(_ command: String, rawLogPath: String, logPath: String, args: Any...) async throws {
        try Folder.create(at: URL(fileURLWithPath: rawLogPath).deletingLastPathComponent().path)
        try shellExecutor.throwingShell(command, args: args, "| tee '\(rawLogPath)'")
        if let errors = try? await beautifyLog(rawLogPath: rawLogPath, logPath: logPath), errors.isNotEmpty {
            throw BuildError.buildFailed(errors: errors, buildLogPath: logPath, rawBuildLogPath: rawLogPath)
        }
    }

    // MARK: - Private

    private func beautifyLog(rawLogPath: String, logPath: String) async throws -> [String] {
        var tests: [String] = []
        var errors: [String] = []
        let log = try File.create(at: logPath)
        let output: (String, OutputType) throws -> Void = { formattedLine, type in
            switch type {
            case .error:
                errors.append(formattedLine)
            case .test, .testCase:
                tests.append(formattedLine)
            case .undefined, .task, .nonContextualError, .warning, .result:
                break
            }
            try log.append("\(formattedLine)\n")
        }

        let rawLog = try shellExecutor.open(rawLogPath)
        for line in rawLog.lines() where !line.isEmpty {
            try logFormatter.format(line: line, output: output)
        }
        try logFormatter.finish(output: output)
        for line in tests {
            await logPlain(line)
        }
        return errors
    }
}

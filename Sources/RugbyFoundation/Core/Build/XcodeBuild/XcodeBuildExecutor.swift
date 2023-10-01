import Fish
import Foundation
import SwiftShell
import XcbeautifyLib

final class XcodeBuildExecutor {
    private let shellExecutor: IShellExecutor
    private let logFormatter: BuildLogFormatter
    private let workingDirectory: IFolder

    init(shellExecutor: IShellExecutor,
         logFormatter: BuildLogFormatter,
         workingDirectory: IFolder) {
        self.shellExecutor = shellExecutor
        self.logFormatter = logFormatter
        self.workingDirectory = workingDirectory
    }

    func run(_ command: String, rawLogPath: String, logPath: String, args: Any ...) throws {
        try shellExecutor.throwingShell(command, args: args, "| tee '\(rawLogPath)'")
        if let errors = try? beautifyLog(rawLogPath: rawLogPath, logPath: logPath), errors.isNotEmpty {
            throw BuildError.buildFailed(errors: errors, buildLogPath: logPath, rawBuildLogPath: rawLogPath)
        }
    }

    // MARK: - Private

    private func beautifyLog(rawLogPath: String, logPath: String) throws -> [String] {
        var errors: [String] = []
        let log = try File.create(at: logPath)
        let output: (String, OutputType) throws -> Void = { [weak self] formattedLine, type in
            guard let self else { return }
            if type == .error { errors.append(self.formatError(formattedLine)) }
            guard (type == .task && formattedLine.contains("Touching")) || type == .error else { return }
            try log.append("\(formattedLine)\n")
        }

        let rawLog = try open(rawLogPath)
        for line in rawLog.lines() {
            try logFormatter.format(line: line, output: output)
        }
        try logFormatter.finish(output: output)
        return errors
    }

    private func formatError(_ error: String) -> String {
        var formattedError = error
        var lines = error.lines()
        guard lines.isNotEmpty else { return formattedError }

        var newLines: [String] = []
        let firstLine = lines.removeFirst()
        let firstLineParts = firstLine.components(separatedBy: ": ")
        guard firstLineParts.count == 2 else {
            /*
             ❌ error: Build input file cannot be found:
             '/Users/swiftyfinch/Developer/Repos/SwiftyFinch/Rugby/TestProject/.rugby/build/Debug-iphonesimulator/
             SnapKit/SnapKit.framework/SnapKit'. Did you forget to declare this file as an output of a script phase or
             custom build rule which produces it? (in target 'SnapKit' from project 'Pods')
             */
            return formattedError
                .replacingOccurrences(of: "error: ", with: "")
                .replacingOccurrences(of: "❌", with: " 💥")
                .replacingOccurrences(of: "[x]", with: " 💥")
        }

        var (path, errorDescription) = (firstLineParts[0], firstLineParts[1])
        if errorDescription.isNotEmpty {
            errorDescription = errorDescription.raw
            let firstSymbol = errorDescription.removeFirst()
            errorDescription = "\(firstSymbol.uppercased())\(errorDescription)"
        }
        newLines.append("💥 \(errorDescription).".red)

        if path.hasPrefix("[x] ") {
            path.removeFirst("[x] ".count)
        } else if path.hasPrefix("❌ ") {
            path.removeFirst("❌ ".count)
        }
        path = path.relativePath(to: workingDirectory.path)
        newLines.append("\(path):".yellow)

        newLines.append(contentsOf: lines)
        newLines = newLines.map { " \($0)" }
        formattedError = newLines.joined(separator: "\n")

        return formattedError
    }
}

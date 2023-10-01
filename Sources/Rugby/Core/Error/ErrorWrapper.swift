import ArgumentParser
import Foundation
import Rainbow
import RugbyFoundation

// MARK: - Interface

extension RunnableCommand {
    /// Common way to handle all errors from commands
    func handle(_ block: () async throws -> Void) async rethrows {
        try await ErrorWrapper(logger: logger).wrap(block)
    }
}

// MARK: - Workaround for colorizing default error prefix from ArgumentParser

extension ParsableCommand {
    // swiftlint:disable:next identifier_name
    static var _errorLabel: String { errorPrefix() }
}

private func errorPrefix() -> String {
    "⛔️ \(Rainbow.enabled ? "\u{1B}[31m" : "")Error"
}

// MARK: - Error for presenting in logs

private enum PresentableError: LocalizedError {
    case common(String)

    var errorDescription: String? {
        switch self {
        case let .common(description):
            return "\(errorSuffix())\(description)"
        }
    }

    private func errorSuffix() -> String {
        // Need to clear color because in _errorLabel we can't do that
        Rainbow.enabled ? "\u{1B}[0m" : ""
    }
}

// MARK: - Error wrapper

private final class ErrorWrapper: Loggable {
    fileprivate let logger: ILogger

    init(logger: ILogger) {
        self.logger = logger
    }

    func wrap(_ block: () async throws -> Void) async rethrows {
        do {
            try await block()
        } catch {
            await log("\(errorPrefix())\(error.beautifulDescription)", output: .file)
            throw PresentableError.common(error.beautifulDescription.red)
        }
    }
}

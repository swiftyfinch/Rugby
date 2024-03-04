// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IXcodeBuildExecutorMock: IXcodeBuildExecutor {

    // MARK: - run

    var runRawLogPathLogPathArgsThrowableError: Error?
    var runRawLogPathLogPathArgsCallsCount = 0
    var runRawLogPathLogPathArgsCalled: Bool { runRawLogPathLogPathArgsCallsCount > 0 }
    var runRawLogPathLogPathArgsReceivedArguments: (command: String, rawLogPath: String, logPath: String, args: Any)?
    var runRawLogPathLogPathArgsReceivedInvocations: [(command: String, rawLogPath: String, logPath: String, args: Any)] = []
    private let runRawLogPathLogPathArgsReceivedInvocationsLock = NSRecursiveLock()
    var runRawLogPathLogPathArgsClosure: ((String, String, String, Any) async throws -> Void)?

    func run(_ command: String, rawLogPath: String, logPath: String, args: Any...) async throws {
        runRawLogPathLogPathArgsCallsCount += 1
        runRawLogPathLogPathArgsReceivedArguments = (command: command, rawLogPath: rawLogPath, logPath: logPath, args: args)
        runRawLogPathLogPathArgsReceivedInvocationsLock.withLock {
            runRawLogPathLogPathArgsReceivedInvocations.append((command: command, rawLogPath: rawLogPath, logPath: logPath, args: args))
        }
        if let error = runRawLogPathLogPathArgsThrowableError {
            throw error
        }
        try await runRawLogPathLogPathArgsClosure?(command, rawLogPath, logPath, args)
    }
}

// swiftlint:enable all

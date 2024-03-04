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
    var runRawLogPathLogPathArgsClosure: ((String, String, String, Any) throws -> Void)?

    func run(_ command: String, rawLogPath: String, logPath: String, args: Any...) throws {
        runRawLogPathLogPathArgsCallsCount += 1
        if let error = runRawLogPathLogPathArgsThrowableError {
            throw error
        }
        runRawLogPathLogPathArgsReceivedArguments = (command: command, rawLogPath: rawLogPath, logPath: logPath, args: args)
        runRawLogPathLogPathArgsReceivedInvocations.append((command: command, rawLogPath: rawLogPath, logPath: logPath, args: args))
        try runRawLogPathLogPathArgsClosure?(command, rawLogPath, logPath, args)
    }
}

// swiftlint:enable all

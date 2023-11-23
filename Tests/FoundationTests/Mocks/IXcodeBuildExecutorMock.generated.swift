// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

@testable import RugbyFoundation
import Foundation

final class IXcodeBuildExecutorMock: IXcodeBuildExecutor {

    // MARK: - run

    var runRawLogPathLogPathArgsThrowableError: Error?
    var runRawLogPathLogPathArgsCallsCount = 0
    var runRawLogPathLogPathArgsCalled: Bool { runRawLogPathLogPathArgsCallsCount > 0 }
    var runRawLogPathLogPathArgsReceivedArguments: (command: String, rawLogPath: String, logPath: String, args: Any)?
    var runRawLogPathLogPathArgsReceivedInvocations: [(command: String, rawLogPath: String, logPath: String, args: Any)] = []
    var runRawLogPathLogPathArgsClosure: ((String, String, String, Any) throws -> Void)?

    func run(_ command: String, rawLogPath: String, logPath: String, args: Any...) throws {
        if let error = runRawLogPathLogPathArgsThrowableError {
            throw error
        }
        runRawLogPathLogPathArgsCallsCount += 1
        runRawLogPathLogPathArgsReceivedArguments = (command: command, rawLogPath: rawLogPath, logPath: logPath, args: args)
        runRawLogPathLogPathArgsReceivedInvocations.append((command: command, rawLogPath: rawLogPath, logPath: logPath, args: args))
        try runRawLogPathLogPathArgsClosure?(command, rawLogPath, logPath, args)
    }
}

// swiftlint:enable all

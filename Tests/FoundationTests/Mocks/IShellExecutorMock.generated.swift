// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final class IShellExecutorMock: IShellExecutor {

    public init() {}

    // MARK: - shell

    public var shellArgsCallsCount = 0
    public var shellArgsCalled: Bool { shellArgsCallsCount > 0 }
    public var shellArgsReceivedArguments: (command: String, args: Any)?
    public var shellArgsReceivedInvocations: [(command: String, args: Any)] = []
    public var shellArgsReturnValue: (String?, Error?)!
    public var shellArgsClosure: ((String, Any) -> (String?, Error?))?

    @discardableResult
    public func shell(_ command: String, args: Any...) -> (String?, Error?) {
        shellArgsCallsCount += 1
        shellArgsReceivedArguments = (command: command, args: args)
        shellArgsReceivedInvocations.append((command: command, args: args))
        if let shellArgsClosure = shellArgsClosure {
            return shellArgsClosure(command, args)
        } else {
            return shellArgsReturnValue
        }
    }

    // MARK: - throwingShell

    public var throwingShellArgsThrowableError: Error?
    public var throwingShellArgsCallsCount = 0
    public var throwingShellArgsCalled: Bool { throwingShellArgsCallsCount > 0 }
    public var throwingShellArgsReceivedArguments: (command: String, args: Any)?
    public var throwingShellArgsReceivedInvocations: [(command: String, args: Any)] = []
    public var throwingShellArgsReturnValue: String?
    public var throwingShellArgsClosure: ((String, Any) throws -> String?)?

    @discardableResult
    public func throwingShell(_ command: String, args: Any...) throws -> String? {
        if let error = throwingShellArgsThrowableError {
            throw error
        }
        throwingShellArgsCallsCount += 1
        throwingShellArgsReceivedArguments = (command: command, args: args)
        throwingShellArgsReceivedInvocations.append((command: command, args: args))
        if let throwingShellArgsClosure = throwingShellArgsClosure {
            return try throwingShellArgsClosure(command, args)
        } else {
            return throwingShellArgsReturnValue
        }
    }

    // MARK: - printShell

    public var printShellArgsThrowableError: Error?
    public var printShellArgsCallsCount = 0
    public var printShellArgsCalled: Bool { printShellArgsCallsCount > 0 }
    public var printShellArgsReceivedArguments: (command: String, args: Any)?
    public var printShellArgsReceivedInvocations: [(command: String, args: Any)] = []
    public var printShellArgsClosure: ((String, Any) throws -> Void)?

    public func printShell(_ command: String, args: Any...) throws {
        if let error = printShellArgsThrowableError {
            throw error
        }
        printShellArgsCallsCount += 1
        printShellArgsReceivedArguments = (command: command, args: args)
        printShellArgsReceivedInvocations.append((command: command, args: args))
        try printShellArgsClosure?(command, args)
    }
}

// swiftlint:enable all

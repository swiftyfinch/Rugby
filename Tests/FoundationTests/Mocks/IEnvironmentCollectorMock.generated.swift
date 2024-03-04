// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final class IEnvironmentCollectorMock: IEnvironmentCollector {

    public init() {}

    // MARK: - env

    public var envRugbyVersionRugbyEnvironmentThrowableError: Error?
    public var envRugbyVersionRugbyEnvironmentCallsCount = 0
    public var envRugbyVersionRugbyEnvironmentCalled: Bool { envRugbyVersionRugbyEnvironmentCallsCount > 0 }
    public var envRugbyVersionRugbyEnvironmentReceivedArguments: (rugbyVersion: String, rugbyEnvironment: [String: String])?
    public var envRugbyVersionRugbyEnvironmentReceivedInvocations: [(rugbyVersion: String, rugbyEnvironment: [String: String])] = []
    public var envRugbyVersionRugbyEnvironmentReturnValue: [String]!
    public var envRugbyVersionRugbyEnvironmentClosure: ((String, [String: String]) async throws -> [String])?

    public func env(rugbyVersion: String, rugbyEnvironment: [String: String]) async throws -> [String] {
        envRugbyVersionRugbyEnvironmentCallsCount += 1
        envRugbyVersionRugbyEnvironmentReceivedArguments = (rugbyVersion: rugbyVersion, rugbyEnvironment: rugbyEnvironment)
        envRugbyVersionRugbyEnvironmentReceivedInvocations.append((rugbyVersion: rugbyVersion, rugbyEnvironment: rugbyEnvironment))
        if let error = envRugbyVersionRugbyEnvironmentThrowableError {
            throw error
        }
        if let envRugbyVersionRugbyEnvironmentClosure = envRugbyVersionRugbyEnvironmentClosure {
            return try await envRugbyVersionRugbyEnvironmentClosure(rugbyVersion, rugbyEnvironment)
        } else {
            return envRugbyVersionRugbyEnvironmentReturnValue
        }
    }

    // MARK: - write<Command>

    public var writeRugbyVersionCommandRugbyEnvironmentThrowableError: Error?
    public var writeRugbyVersionCommandRugbyEnvironmentCallsCount = 0
    public var writeRugbyVersionCommandRugbyEnvironmentCalled: Bool { writeRugbyVersionCommandRugbyEnvironmentCallsCount > 0 }
    public var writeRugbyVersionCommandRugbyEnvironmentReceivedArguments: (rugbyVersion: String, command: Any, rugbyEnvironment: [String: String])?
    public var writeRugbyVersionCommandRugbyEnvironmentReceivedInvocations: [(rugbyVersion: String, command: Any, rugbyEnvironment: [String: String])] = []
    public var writeRugbyVersionCommandRugbyEnvironmentClosure: ((String, Any, [String: String]) async throws -> Void)?

    public func write<Command>(rugbyVersion: String, command: Command, rugbyEnvironment: [String: String]) async throws {
        writeRugbyVersionCommandRugbyEnvironmentCallsCount += 1
        writeRugbyVersionCommandRugbyEnvironmentReceivedArguments = (rugbyVersion: rugbyVersion, command: command, rugbyEnvironment: rugbyEnvironment)
        writeRugbyVersionCommandRugbyEnvironmentReceivedInvocations.append((rugbyVersion: rugbyVersion, command: command, rugbyEnvironment: rugbyEnvironment))
        if let error = writeRugbyVersionCommandRugbyEnvironmentThrowableError {
            throw error
        }
        try await writeRugbyVersionCommandRugbyEnvironmentClosure?(rugbyVersion, command, rugbyEnvironment)
    }

    // MARK: - logXcodeVersion

    public var logXcodeVersionThrowableError: Error?
    public var logXcodeVersionCallsCount = 0
    public var logXcodeVersionCalled: Bool { logXcodeVersionCallsCount > 0 }
    public var logXcodeVersionClosure: (() async throws -> Void)?

    public func logXcodeVersion() async throws {
        logXcodeVersionCallsCount += 1
        if let error = logXcodeVersionThrowableError {
            throw error
        }
        try await logXcodeVersionClosure?()
    }

    // MARK: - logCommandDump<Command>

    public var logCommandDumpCommandCallsCount = 0
    public var logCommandDumpCommandCalled: Bool { logCommandDumpCommandCallsCount > 0 }
    public var logCommandDumpCommandReceivedCommand: Any?
    public var logCommandDumpCommandReceivedInvocations: [Any] = []
    public var logCommandDumpCommandClosure: ((Any) async -> Void)?

    public func logCommandDump<Command>(command: Command) async {
        logCommandDumpCommandCallsCount += 1
        logCommandDumpCommandReceivedCommand = command
        logCommandDumpCommandReceivedInvocations.append(command)
        await logCommandDumpCommandClosure?(command)
    }
}

// swiftlint:enable all

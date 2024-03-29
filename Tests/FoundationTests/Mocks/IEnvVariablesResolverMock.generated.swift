// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IEnvVariablesResolverMock: IEnvVariablesResolver {

    // MARK: - resolve

    var resolveInThrowableError: Error?
    var resolveInCallsCount = 0
    var resolveInCalled: Bool { resolveInCallsCount > 0 }
    var resolveInReceivedString: String?
    var resolveInReceivedInvocations: [String] = []
    private let resolveInReceivedInvocationsLock = NSRecursiveLock()
    var resolveInReturnValue: String!
    var resolveInClosure: ((String) async throws -> String)?

    func resolve(in string: String) async throws -> String {
        resolveInCallsCount += 1
        resolveInReceivedString = string
        resolveInReceivedInvocationsLock.withLock {
            resolveInReceivedInvocations.append(string)
        }
        if let error = resolveInThrowableError {
            throw error
        }
        if let resolveInClosure = resolveInClosure {
            return try await resolveInClosure(string)
        } else {
            return resolveInReturnValue
        }
    }

    // MARK: - resolveXcodeVariables

    var resolveXcodeVariablesInAdditionalEnvThrowableError: Error?
    var resolveXcodeVariablesInAdditionalEnvCallsCount = 0
    var resolveXcodeVariablesInAdditionalEnvCalled: Bool { resolveXcodeVariablesInAdditionalEnvCallsCount > 0 }
    var resolveXcodeVariablesInAdditionalEnvReceivedArguments: (string: String, additionalEnv: [String: String])?
    var resolveXcodeVariablesInAdditionalEnvReceivedInvocations: [(string: String, additionalEnv: [String: String])] = []
    private let resolveXcodeVariablesInAdditionalEnvReceivedInvocationsLock = NSRecursiveLock()
    var resolveXcodeVariablesInAdditionalEnvReturnValue: String!
    var resolveXcodeVariablesInAdditionalEnvClosure: ((String, [String: String]) async throws -> String)?

    func resolveXcodeVariables(in string: String, additionalEnv: [String: String]) async throws -> String {
        resolveXcodeVariablesInAdditionalEnvCallsCount += 1
        resolveXcodeVariablesInAdditionalEnvReceivedArguments = (string: string, additionalEnv: additionalEnv)
        resolveXcodeVariablesInAdditionalEnvReceivedInvocationsLock.withLock {
            resolveXcodeVariablesInAdditionalEnvReceivedInvocations.append((string: string, additionalEnv: additionalEnv))
        }
        if let error = resolveXcodeVariablesInAdditionalEnvThrowableError {
            throw error
        }
        if let resolveXcodeVariablesInAdditionalEnvClosure = resolveXcodeVariablesInAdditionalEnvClosure {
            return try await resolveXcodeVariablesInAdditionalEnvClosure(string, additionalEnv)
        } else {
            return resolveXcodeVariablesInAdditionalEnvReturnValue
        }
    }
}

// swiftlint:enable all

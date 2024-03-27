// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IEnvVariablesResolverMock: IEnvVariablesResolver {

    // MARK: - resolve

    var resolveAdditionalEnvThrowableError: Error?
    var resolveAdditionalEnvCallsCount = 0
    var resolveAdditionalEnvCalled: Bool { resolveAdditionalEnvCallsCount > 0 }
    var resolveAdditionalEnvReceivedArguments: (string: String, additionalEnv: [String: String])?
    var resolveAdditionalEnvReceivedInvocations: [(string: String, additionalEnv: [String: String])] = []
    private let resolveAdditionalEnvReceivedInvocationsLock = NSRecursiveLock()
    var resolveAdditionalEnvReturnValue: String!
    var resolveAdditionalEnvClosure: ((String, [String: String]) async throws -> String)?

    func resolve(_ string: String, additionalEnv: [String: String]) async throws -> String {
        resolveAdditionalEnvCallsCount += 1
        resolveAdditionalEnvReceivedArguments = (string: string, additionalEnv: additionalEnv)
        resolveAdditionalEnvReceivedInvocationsLock.withLock {
            resolveAdditionalEnvReceivedInvocations.append((string: string, additionalEnv: additionalEnv))
        }
        if let error = resolveAdditionalEnvThrowableError {
            throw error
        }
        if let resolveAdditionalEnvClosure = resolveAdditionalEnvClosure {
            return try await resolveAdditionalEnvClosure(string, additionalEnv)
        } else {
            return resolveAdditionalEnvReturnValue
        }
    }
}

// swiftlint:enable all

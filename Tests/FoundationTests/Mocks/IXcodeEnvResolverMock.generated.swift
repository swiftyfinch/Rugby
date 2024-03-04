// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IXcodeEnvResolverMock: IXcodeEnvResolver {

    // MARK: - resolve

    var resolvePathAdditionalEnvThrowableError: Error?
    var resolvePathAdditionalEnvCallsCount = 0
    var resolvePathAdditionalEnvCalled: Bool { resolvePathAdditionalEnvCallsCount > 0 }
    var resolvePathAdditionalEnvReceivedArguments: (path: String, additionalEnv: [String: String])?
    var resolvePathAdditionalEnvReceivedInvocations: [(path: String, additionalEnv: [String: String])] = []
    private let resolvePathAdditionalEnvReceivedInvocationsLock = NSRecursiveLock()
    var resolvePathAdditionalEnvReturnValue: String!
    var resolvePathAdditionalEnvClosure: ((String, [String: String]) async throws -> String)?

    func resolve(path: String, additionalEnv: [String: String]) async throws -> String {
        resolvePathAdditionalEnvCallsCount += 1
        resolvePathAdditionalEnvReceivedArguments = (path: path, additionalEnv: additionalEnv)
        resolvePathAdditionalEnvReceivedInvocationsLock.withLock {
            resolvePathAdditionalEnvReceivedInvocations.append((path: path, additionalEnv: additionalEnv))
        }
        if let error = resolvePathAdditionalEnvThrowableError {
            throw error
        }
        if let resolvePathAdditionalEnvClosure = resolvePathAdditionalEnvClosure {
            return try await resolvePathAdditionalEnvClosure(path, additionalEnv)
        } else {
            return resolvePathAdditionalEnvReturnValue
        }
    }
}

// swiftlint:enable all

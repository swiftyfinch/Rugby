// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IBuildRulesHasherMock: IBuildRulesHasher {

    // MARK: - hashContext

    var hashContextThrowableError: Error?
    var hashContextCallsCount = 0
    var hashContextCalled: Bool { hashContextCallsCount > 0 }
    var hashContextReceivedBuildRules: [BuildRule]?
    let hashContextReceivedInvocationsLock = NSRecursiveLock()
    var hashContextReceivedInvocations: [[BuildRule]] = []
    var hashContextReturnValue: [Any]!
    var hashContextClosure: (([BuildRule]) async throws -> [Any])?

    func hashContext(_ buildRules: [BuildRule]) async throws -> [Any] {
        if let error = hashContextThrowableError {
            throw error
        }
        hashContextCallsCount += 1
        hashContextReceivedBuildRules = buildRules
        hashContextReceivedInvocationsLock.withLock {
            hashContextReceivedInvocations.append(buildRules)
        }
        if let hashContextClosure = hashContextClosure {
            return try await hashContextClosure(buildRules)
        } else {
            return hashContextReturnValue
        }
    }
}

// swiftlint:enable all

// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IConfigurationsHasherMock: IConfigurationsHasher {

    // MARK: - hashContext

    var hashContextThrowableError: Error?
    var hashContextCallsCount = 0
    var hashContextCalled: Bool { hashContextCallsCount > 0 }
    var hashContextReceivedTarget: IInternalTarget?
    var hashContextReceivedInvocations: [IInternalTarget] = []
    private let hashContextReceivedInvocationsLock = NSRecursiveLock()
    var hashContextReturnValue: [Any]!
    var hashContextClosure: ((IInternalTarget) throws -> [Any])?

    func hashContext(_ target: IInternalTarget) throws -> [Any] {
        hashContextCallsCount += 1
        hashContextReceivedTarget = target
        hashContextReceivedInvocationsLock.withLock {
            hashContextReceivedInvocations.append(target)
        }
        if let error = hashContextThrowableError {
            throw error
        }
        if let hashContextClosure = hashContextClosure {
            return try hashContextClosure(target)
        } else {
            return hashContextReturnValue
        }
    }
}

// swiftlint:enable all

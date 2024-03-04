// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IBuildPhaseHasherMock: IBuildPhaseHasher {

    // MARK: - hashContext

    var hashContextTargetThrowableError: Error?
    var hashContextTargetCallsCount = 0
    var hashContextTargetCalled: Bool { hashContextTargetCallsCount > 0 }
    var hashContextTargetReceivedTarget: IInternalTarget?
    var hashContextTargetReceivedInvocations: [IInternalTarget] = []
    private let hashContextTargetReceivedInvocationsLock = NSRecursiveLock()
    var hashContextTargetReturnValue: Any!
    var hashContextTargetClosure: ((IInternalTarget) async throws -> Any)?

    func hashContext(target: IInternalTarget) async throws -> Any {
        hashContextTargetCallsCount += 1
        hashContextTargetReceivedTarget = target
        hashContextTargetReceivedInvocationsLock.withLock {
            hashContextTargetReceivedInvocations.append(target)
        }
        if let error = hashContextTargetThrowableError {
            throw error
        }
        if let hashContextTargetClosure = hashContextTargetClosure {
            return try await hashContextTargetClosure(target)
        } else {
            return hashContextTargetReturnValue!
        }
    }
}

// swiftlint:enable all

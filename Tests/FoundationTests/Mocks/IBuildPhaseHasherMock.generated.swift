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
    var hashContextTargetReturnValue: Any!
    var hashContextTargetClosure: ((IInternalTarget) async throws -> Any)?

    func hashContext(target: IInternalTarget) async throws -> Any {
        if let error = hashContextTargetThrowableError {
            throw error
        }
        hashContextTargetCallsCount += 1
        hashContextTargetReceivedTarget = target
        hashContextTargetReceivedInvocations.append(target)
        if let hashContextTargetClosure = hashContextTargetClosure {
            return try await hashContextTargetClosure(target)
        } else {
            return hashContextTargetReturnValue
        }
    }
}

// swiftlint:enable all

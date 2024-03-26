// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IXCFrameworksPatcherMock: IXCFrameworksPatcher {

    // MARK: - detachXCFrameworkBuildPhase

    var detachXCFrameworkBuildPhaseFromThrowableError: Error?
    var detachXCFrameworkBuildPhaseFromCallsCount = 0
    var detachXCFrameworkBuildPhaseFromCalled: Bool { detachXCFrameworkBuildPhaseFromCallsCount > 0 }
    var detachXCFrameworkBuildPhaseFromReceivedTargets: TargetsMap?
    var detachXCFrameworkBuildPhaseFromReceivedInvocations: [TargetsMap] = []
    private let detachXCFrameworkBuildPhaseFromReceivedInvocationsLock = NSRecursiveLock()
    var detachXCFrameworkBuildPhaseFromClosure: ((TargetsMap) async throws -> Void)?

    func detachXCFrameworkBuildPhase(from targets: TargetsMap) async throws {
        detachXCFrameworkBuildPhaseFromCallsCount += 1
        detachXCFrameworkBuildPhaseFromReceivedTargets = targets
        detachXCFrameworkBuildPhaseFromReceivedInvocationsLock.withLock {
            detachXCFrameworkBuildPhaseFromReceivedInvocations.append(targets)
        }
        if let error = detachXCFrameworkBuildPhaseFromThrowableError {
            throw error
        }
        try await detachXCFrameworkBuildPhaseFromClosure?(targets)
    }
}

// swiftlint:enable all

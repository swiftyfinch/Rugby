// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ILibrariesPatcherMock: ILibrariesPatcher {

    // MARK: - patch

    var patchThrowableError: Error?
    var patchCallsCount = 0
    var patchCalled: Bool { patchCallsCount > 0 }
    var patchReceivedTargets: TargetsMap?
    var patchReceivedInvocations: [TargetsMap] = []
    private let patchReceivedInvocationsLock = NSRecursiveLock()
    var patchClosure: ((TargetsMap) async throws -> Void)?

    func patch(_ targets: TargetsMap) async throws {
        patchCallsCount += 1
        patchReceivedTargets = targets
        patchReceivedInvocationsLock.withLock {
            patchReceivedInvocations.append(targets)
        }
        if let error = patchThrowableError {
            throw error
        }
        try await patchClosure?(targets)
    }
}

// swiftlint:enable all

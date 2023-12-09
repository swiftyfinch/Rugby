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
    var patchClosure: ((TargetsMap) async throws -> Void)?

    func patch(_ targets: TargetsMap) async throws {
        if let error = patchThrowableError {
            throw error
        }
        patchCallsCount += 1
        patchReceivedTargets = targets
        patchReceivedInvocations.append(targets)
        try await patchClosure?(targets)
    }
}

// swiftlint:enable all

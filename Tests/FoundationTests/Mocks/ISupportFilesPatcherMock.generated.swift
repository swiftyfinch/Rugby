// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ISupportFilesPatcherMock: ISupportFilesPatcher {

    // MARK: - prepareReplacements

    var prepareReplacementsForTargetThrowableError: Error?
    var prepareReplacementsForTargetCallsCount = 0
    var prepareReplacementsForTargetCalled: Bool { prepareReplacementsForTargetCallsCount > 0 }
    var prepareReplacementsForTargetReceivedTarget: IInternalTarget?
    var prepareReplacementsForTargetReceivedInvocations: [IInternalTarget] = []
    private let prepareReplacementsForTargetReceivedInvocationsLock = NSRecursiveLock()
    var prepareReplacementsForTargetReturnValue: [FileReplacement]!
    var prepareReplacementsForTargetClosure: ((IInternalTarget) throws -> [FileReplacement])?

    func prepareReplacements(forTarget target: IInternalTarget) throws -> [FileReplacement] {
        prepareReplacementsForTargetCallsCount += 1
        prepareReplacementsForTargetReceivedTarget = target
        prepareReplacementsForTargetReceivedInvocationsLock.withLock {
            prepareReplacementsForTargetReceivedInvocations.append(target)
        }
        if let error = prepareReplacementsForTargetThrowableError {
            throw error
        }
        if let prepareReplacementsForTargetClosure = prepareReplacementsForTargetClosure {
            return try prepareReplacementsForTargetClosure(target)
        } else {
            return prepareReplacementsForTargetReturnValue
        }
    }
}

// swiftlint:enable all

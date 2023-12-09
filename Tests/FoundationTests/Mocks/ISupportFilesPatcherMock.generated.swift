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
    var prepareReplacementsForTargetReturnValue: [FileReplacement]!
    var prepareReplacementsForTargetClosure: ((IInternalTarget) throws -> [FileReplacement])?

    func prepareReplacements(forTarget target: IInternalTarget) throws -> [FileReplacement] {
        if let error = prepareReplacementsForTargetThrowableError {
            throw error
        }
        prepareReplacementsForTargetCallsCount += 1
        prepareReplacementsForTargetReceivedTarget = target
        prepareReplacementsForTargetReceivedInvocations.append(target)
        if let prepareReplacementsForTargetClosure = prepareReplacementsForTargetClosure {
            return try prepareReplacementsForTargetClosure(target)
        } else {
            return prepareReplacementsForTargetReturnValue
        }
    }
}

// swiftlint:enable all

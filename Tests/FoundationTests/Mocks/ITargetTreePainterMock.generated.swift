// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ITargetTreePainterMock: ITargetTreePainter {

    // MARK: - paint

    var paintTargetsCallsCount = 0
    var paintTargetsCalled: Bool { paintTargetsCallsCount > 0 }
    var paintTargetsReceivedTargets: TargetsMap?
    var paintTargetsReceivedInvocations: [TargetsMap] = []
    private let paintTargetsReceivedInvocationsLock = NSRecursiveLock()
    var paintTargetsReturnValue: String!
    var paintTargetsClosure: ((TargetsMap) -> String)?

    func paint(targets: TargetsMap) -> String {
        paintTargetsCallsCount += 1
        paintTargetsReceivedTargets = targets
        paintTargetsReceivedInvocationsLock.withLock {
            paintTargetsReceivedInvocations.append(targets)
        }
        if let paintTargetsClosure = paintTargetsClosure {
            return paintTargetsClosure(targets)
        } else {
            return paintTargetsReturnValue
        }
    }
}

// swiftlint:enable all

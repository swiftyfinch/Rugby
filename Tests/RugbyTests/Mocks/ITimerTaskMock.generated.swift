// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import Rugby

final class ITimerTaskMock: ITimerTask {

    // MARK: - cancel

    var cancelCallsCount = 0
    var cancelCalled: Bool { cancelCallsCount > 0 }
    var cancelClosure: (() -> Void)?

    func cancel() {
        cancelCallsCount += 1
        cancelClosure?()
    }
}

// swiftlint:enable all

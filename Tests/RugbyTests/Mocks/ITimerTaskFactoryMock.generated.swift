// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import Rugby

final class ITimerTaskFactoryMock: ITimerTaskFactory {

    // MARK: - makeTask

    var makeTaskIntervalTaskCallsCount = 0
    var makeTaskIntervalTaskCalled: Bool { makeTaskIntervalTaskCallsCount > 0 }
    var makeTaskIntervalTaskReceivedArguments: (interval: TimeInterval, task: () -> Void)?
    var makeTaskIntervalTaskReceivedInvocations: [(interval: TimeInterval, task: () -> Void)] = []
    var makeTaskIntervalTaskReturnValue: ITimerTask!
    var makeTaskIntervalTaskClosure: ((TimeInterval, @escaping () -> Void) -> ITimerTask)?

    func makeTask(interval: TimeInterval, task: @escaping () -> Void) -> ITimerTask {
        makeTaskIntervalTaskCallsCount += 1
        makeTaskIntervalTaskReceivedArguments = (interval: interval, task: task)
        makeTaskIntervalTaskReceivedInvocations.append((interval: interval, task: task))
        if let makeTaskIntervalTaskClosure = makeTaskIntervalTaskClosure {
            return makeTaskIntervalTaskClosure(interval, task)
        } else {
            return makeTaskIntervalTaskReturnValue
        }
    }
}

// swiftlint:enable all

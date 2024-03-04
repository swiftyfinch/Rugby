// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import SwiftShell
@testable import RugbyFoundation

public final class IProcessMonitorMock: IProcessMonitor {

    public init() {}

    // MARK: - monitor

    public var monitorCallsCount = 0
    public var monitorCalled: Bool { monitorCallsCount > 0 }
    public var monitorClosure: (() -> Void)?

    public func monitor() {
        monitorCallsCount += 1
        monitorClosure?()
    }

    // MARK: - addProcess

    public var addProcessCallsCount = 0
    public var addProcessCalled: Bool { addProcessCallsCount > 0 }
    public var addProcessReceivedProcess: PrintedAsyncCommand?
    public var addProcessReceivedInvocations: [PrintedAsyncCommand] = []
    public var addProcessClosure: ((PrintedAsyncCommand) -> Void)?

    public func addProcess(_ process: PrintedAsyncCommand) {
        addProcessCallsCount += 1
        addProcessReceivedProcess = process
        addProcessReceivedInvocations.append(process)
        addProcessClosure?(process)
    }

    // MARK: - runOnInterruption

    public var runOnInterruptionCallsCount = 0
    public var runOnInterruptionCalled: Bool { runOnInterruptionCallsCount > 0 }
    public var runOnInterruptionReceivedJob: (() -> Void)?
    public var runOnInterruptionReceivedInvocations: [(() -> Void)] = []
    public var runOnInterruptionReturnValue: ProcessInterruptionTask!
    public var runOnInterruptionClosure: ((@escaping () -> Void) -> ProcessInterruptionTask)?

    @discardableResult
    public func runOnInterruption(_ job: @escaping () -> Void) -> ProcessInterruptionTask {
        runOnInterruptionCallsCount += 1
        runOnInterruptionReceivedJob = job
        runOnInterruptionReceivedInvocations.append(job)
        if let runOnInterruptionClosure = runOnInterruptionClosure {
            return runOnInterruptionClosure(job)
        } else {
            return runOnInterruptionReturnValue
        }
    }
}

// swiftlint:enable all

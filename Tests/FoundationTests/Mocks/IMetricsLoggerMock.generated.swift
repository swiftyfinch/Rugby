// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final class IMetricsLoggerMock: IMetricsLogger {

    public init() {}

    // MARK: - log

    public var logNameCallsCount = 0
    public var logNameCalled: Bool { logNameCallsCount > 0 }
    public var logNameReceivedArguments: (metric: Double, name: String)?
    public var logNameReceivedInvocations: [(metric: Double, name: String)] = []
    private let logNameReceivedInvocationsLock = NSRecursiveLock()
    public var logNameClosure: ((Double, String) -> Void)?

    public func log(_ metric: Double, name: String) {
        logNameCallsCount += 1
        logNameReceivedArguments = (metric: metric, name: name)
        logNameReceivedInvocationsLock.withLock {
            logNameReceivedInvocations.append((metric: metric, name: name))
        }
        logNameClosure?(metric, name)
    }

    // MARK: - add

    public var addNameCallsCount = 0
    public var addNameCalled: Bool { addNameCallsCount > 0 }
    public var addNameReceivedArguments: (metric: Double, name: String)?
    public var addNameReceivedInvocations: [(metric: Double, name: String)] = []
    private let addNameReceivedInvocationsLock = NSRecursiveLock()
    public var addNameClosure: ((Double, String) -> Void)?

    public func add(_ metric: Double, name: String) {
        addNameCallsCount += 1
        addNameReceivedArguments = (metric: metric, name: name)
        addNameReceivedInvocationsLock.withLock {
            addNameReceivedInvocations.append((metric: metric, name: name))
        }
        addNameClosure?(metric, name)
    }

    // MARK: - save

    public var saveThrowableError: Error?
    public var saveCallsCount = 0
    public var saveCalled: Bool { saveCallsCount > 0 }
    public var saveClosure: (() throws -> Void)?

    public func save() throws {
        saveCallsCount += 1
        if let error = saveThrowableError {
            throw error
        }
        try saveClosure?()
    }
}

// swiftlint:enable all

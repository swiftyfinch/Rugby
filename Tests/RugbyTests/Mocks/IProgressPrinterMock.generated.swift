// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final actor IProgressPrinterMock: IProgressPrinter {

    public init() {}

    // MARK: - show<Result>

    public var showTextLevelJobCallsCount = 0
    public var showTextLevelJobCalled: Bool { showTextLevelJobCallsCount > 0 }
    public var showTextLevelJobReturnValue: Any!
    func setShowTextLevelJobReturnValue(_ value: Any) {
        showTextLevelJobReturnValue = value
    }
    public var showTextLevelJobClosure: ((String, LogLevel, () async throws -> Any) async throws -> Any)?
    func setShowTextLevelJobClosure(_ closure: ((String, LogLevel, () async throws -> Any) async throws -> Any)?) {
        showTextLevelJobClosure = closure
    }

    public func show<Result>(text: String, level: LogLevel, job: () async throws -> Result) async rethrows -> Result {
        showTextLevelJobCallsCount += 1
        if let showTextLevelJobClosure = showTextLevelJobClosure {
            // It's a workaround
            // https://forums.swift.org/t/run-a-throwable-function-without-try-is-this-expected/32282/2
            // https://github.com/apple/swift/issues/43295
            func sync<T>(handler: () async throws -> (T)) async rethrows -> T {
                try await handler()
            }
            return try await sync {
                try await showTextLevelJobClosure(text, level, job) as! Result
            }
        } else {
            return showTextLevelJobReturnValue as! Result
        }
    }

    // MARK: - cancel

    public var cancelCallsCount = 0
    public var cancelCalled: Bool { cancelCallsCount > 0 }
    public var cancelClosure: (() -> Void)?

    public func cancel() {
        cancelCallsCount += 1
        cancelClosure?()
    }
}

// swiftlint:enable all

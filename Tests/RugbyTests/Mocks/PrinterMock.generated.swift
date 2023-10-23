// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
import RugbyFoundation

public final class PrinterMock: Printer {

    public init() {}

    // MARK: - canPrint

    public var canPrintLevelCallsCount = 0
    public var canPrintLevelCalled: Bool { canPrintLevelCallsCount > 0 }
    public var canPrintLevelReceivedLevel: LogLevel?
    public var canPrintLevelReceivedInvocations: [LogLevel] = []
    public var canPrintLevelReturnValue: Bool!
    public var canPrintLevelClosure: ((LogLevel) -> Bool)?

    public func canPrint(level: LogLevel) -> Bool {
        canPrintLevelCallsCount += 1
        canPrintLevelReceivedLevel = level
        canPrintLevelReceivedInvocations.append(level)
        if let canPrintLevelClosure = canPrintLevelClosure {
            return canPrintLevelClosure(level)
        } else {
            return canPrintLevelReturnValue
        }
    }

    // MARK: - print

    public var printIconDurationLevelUpdateLineCallsCount = 0
    public var printIconDurationLevelUpdateLineCalled: Bool { printIconDurationLevelUpdateLineCallsCount > 0 }
    public var printIconDurationLevelUpdateLineReceivedArguments: (text: String, icon: String?, duration: Double?, level: LogLevel, updateLine: Bool)?
    public var printIconDurationLevelUpdateLineReceivedInvocations: [(text: String, icon: String?, duration: Double?, level: LogLevel, updateLine: Bool)] = []
    public var printIconDurationLevelUpdateLineClosure: ((String, String?, Double?, LogLevel, Bool) -> Void)?

    public func print(_ text: String, icon: String?, duration: Double?, level: LogLevel, updateLine: Bool) {
        printIconDurationLevelUpdateLineCallsCount += 1
        printIconDurationLevelUpdateLineReceivedArguments = (text: text, icon: icon, duration: duration, level: level, updateLine: updateLine)
        printIconDurationLevelUpdateLineReceivedInvocations.append((text: text, icon: icon, duration: duration, level: level, updateLine: updateLine))
        printIconDurationLevelUpdateLineClosure?(text, icon, duration, level, updateLine)
    }

    // MARK: - shift

    public var shiftCallsCount = 0
    public var shiftCalled: Bool { shiftCallsCount > 0 }
    public var shiftClosure: (() -> Void)?

    public func shift() {
        shiftCallsCount += 1
        shiftClosure?()
    }

    // MARK: - unshift

    public var unshiftCallsCount = 0
    public var unshiftCalled: Bool { unshiftCallsCount > 0 }
    public var unshiftClosure: (() -> Void)?

    public func unshift() {
        unshiftCallsCount += 1
        unshiftClosure?()
    }
}

// swiftlint:enable all

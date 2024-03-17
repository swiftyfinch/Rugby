// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ITargetsPrinterMock: ITargetsPrinter {

    // MARK: - print

    var printCallsCount = 0
    var printCalled: Bool { printCallsCount > 0 }
    var printReceivedTargets: TargetsMap?
    var printReceivedInvocations: [TargetsMap] = []
    private let printReceivedInvocationsLock = NSRecursiveLock()
    var printClosure: ((TargetsMap) async -> Void)?

    func print(_ targets: TargetsMap) async {
        printCallsCount += 1
        printReceivedTargets = targets
        printReceivedInvocationsLock.withLock {
            printReceivedInvocations.append(targets)
        }
        await printClosure?(targets)
    }
}

// swiftlint:enable all

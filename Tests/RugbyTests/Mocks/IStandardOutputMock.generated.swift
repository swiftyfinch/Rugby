// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import Rugby

final class IStandardOutputMock: IStandardOutput {

    // MARK: - print

    var printCallsCount = 0
    var printCalled: Bool { printCallsCount > 0 }
    var printReceivedText: String?
    var printReceivedInvocations: [String] = []
    var printClosure: ((String) -> Void)?

    func print(_ text: String) {
        printCallsCount += 1
        printReceivedText = text
        printReceivedInvocations.append(text)
        printClosure?(text)
    }
}

// swiftlint:enable all

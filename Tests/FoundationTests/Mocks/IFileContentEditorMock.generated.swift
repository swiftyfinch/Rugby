// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IFileContentEditorMock: IFileContentEditor {

    // MARK: - replace

    var replaceRegexFilePathThrowableError: Error?
    var replaceRegexFilePathCallsCount = 0
    var replaceRegexFilePathCalled: Bool { replaceRegexFilePathCallsCount > 0 }
    var replaceRegexFilePathReceivedArguments: (replacements: [String: String], regex: NSRegularExpression, filePath: String)?
    var replaceRegexFilePathReceivedInvocations: [(replacements: [String: String], regex: NSRegularExpression, filePath: String)] = []
    private let replaceRegexFilePathReceivedInvocationsLock = NSRecursiveLock()
    var replaceRegexFilePathClosure: (([String: String], NSRegularExpression, String) throws -> Void)?

    func replace(_ replacements: [String: String], regex: NSRegularExpression, filePath: String) throws {
        replaceRegexFilePathCallsCount += 1
        replaceRegexFilePathReceivedArguments = (replacements: replacements, regex: regex, filePath: filePath)
        replaceRegexFilePathReceivedInvocationsLock.withLock {
            replaceRegexFilePathReceivedInvocations.append((replacements: replacements, regex: regex, filePath: filePath))
        }
        if let error = replaceRegexFilePathThrowableError {
            throw error
        }
        try replaceRegexFilePathClosure?(replacements, regex, filePath)
    }
}

// swiftlint:enable all

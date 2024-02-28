// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IGitMock: IGit {

    // MARK: - currentBranch

    var currentBranchThrowableError: Error?
    var currentBranchCallsCount = 0
    var currentBranchCalled: Bool { currentBranchCallsCount > 0 }
    var currentBranchReturnValue: String?
    var currentBranchClosure: (() throws -> String?)?

    func currentBranch() throws -> String? {
        if let error = currentBranchThrowableError {
            throw error
        }
        currentBranchCallsCount += 1
        if let currentBranchClosure = currentBranchClosure {
            return try currentBranchClosure()
        } else {
            return currentBranchReturnValue
        }
    }

    // MARK: - hasUncommittedChanges

    var hasUncommittedChangesThrowableError: Error?
    var hasUncommittedChangesCallsCount = 0
    var hasUncommittedChangesCalled: Bool { hasUncommittedChangesCallsCount > 0 }
    var hasUncommittedChangesReturnValue: Bool!
    var hasUncommittedChangesClosure: (() throws -> Bool)?

    func hasUncommittedChanges() throws -> Bool {
        if let error = hasUncommittedChangesThrowableError {
            throw error
        }
        hasUncommittedChangesCallsCount += 1
        if let hasUncommittedChangesClosure = hasUncommittedChangesClosure {
            return try hasUncommittedChangesClosure()
        } else {
            return hasUncommittedChangesReturnValue
        }
    }

    // MARK: - isBehind

    var isBehindBranchThrowableError: Error?
    var isBehindBranchCallsCount = 0
    var isBehindBranchCalled: Bool { isBehindBranchCallsCount > 0 }
    var isBehindBranchReceivedBranch: String?
    var isBehindBranchReceivedInvocations: [String] = []
    var isBehindBranchReturnValue: Bool!
    var isBehindBranchClosure: ((String) throws -> Bool)?

    func isBehind(branch: String) throws -> Bool {
        if let error = isBehindBranchThrowableError {
            throw error
        }
        isBehindBranchCallsCount += 1
        isBehindBranchReceivedBranch = branch
        isBehindBranchReceivedInvocations.append(branch)
        if let isBehindBranchClosure = isBehindBranchClosure {
            return try isBehindBranchClosure(branch)
        } else {
            return isBehindBranchReturnValue
        }
    }
}

// swiftlint:enable all

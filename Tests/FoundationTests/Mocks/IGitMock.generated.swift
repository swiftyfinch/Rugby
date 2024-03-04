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
        currentBranchCallsCount += 1
        if let error = currentBranchThrowableError {
            throw error
        }
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
        hasUncommittedChangesCallsCount += 1
        if let error = hasUncommittedChangesThrowableError {
            throw error
        }
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
    private let isBehindBranchReceivedInvocationsLock = NSRecursiveLock()
    var isBehindBranchReturnValue: Bool!
    var isBehindBranchClosure: ((String) throws -> Bool)?

    func isBehind(branch: String) throws -> Bool {
        isBehindBranchCallsCount += 1
        isBehindBranchReceivedBranch = branch
        isBehindBranchReceivedInvocationsLock.withLock {
            isBehindBranchReceivedInvocations.append(branch)
        }
        if let error = isBehindBranchThrowableError {
            throw error
        }
        if let isBehindBranchClosure = isBehindBranchClosure {
            return try isBehindBranchClosure(branch)
        } else {
            return isBehindBranchReturnValue
        }
    }
}

// swiftlint:enable all

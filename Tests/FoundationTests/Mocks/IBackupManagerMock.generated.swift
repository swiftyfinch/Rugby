// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

public final class IBackupManagerMock: IBackupManager {

    public init() {}

    // MARK: - backup

    public var backupKindThrowableError: Error?
    public var backupKindCallsCount = 0
    public var backupKindCalled: Bool { backupKindCallsCount > 0 }
    public var backupKindReceivedArguments: (xcodeProject: IXcodeProject, kind: BackupKind)?
    public var backupKindReceivedInvocations: [(xcodeProject: IXcodeProject, kind: BackupKind)] = []
    public var backupKindClosure: ((IXcodeProject, BackupKind) async throws -> Void)?

    public func backup(_ xcodeProject: IXcodeProject, kind: BackupKind) async throws {
        backupKindCallsCount += 1
        backupKindReceivedArguments = (xcodeProject: xcodeProject, kind: kind)
        backupKindReceivedInvocations.append((xcodeProject: xcodeProject, kind: kind))
        if let error = backupKindThrowableError {
            throw error
        }
        try await backupKindClosure?(xcodeProject, kind)
    }

    // MARK: - asyncRestore

    public var asyncRestoreThrowableError: Error?
    public var asyncRestoreCallsCount = 0
    public var asyncRestoreCalled: Bool { asyncRestoreCallsCount > 0 }
    public var asyncRestoreReceivedKind: BackupKind?
    public var asyncRestoreReceivedInvocations: [BackupKind] = []
    public var asyncRestoreClosure: ((BackupKind) async throws -> Void)?

    public func asyncRestore(_ kind: BackupKind) async throws {
        asyncRestoreCallsCount += 1
        asyncRestoreReceivedKind = kind
        asyncRestoreReceivedInvocations.append(kind)
        if let error = asyncRestoreThrowableError {
            throw error
        }
        try await asyncRestoreClosure?(kind)
    }

    // MARK: - restore

    public var restoreThrowableError: Error?
    public var restoreCallsCount = 0
    public var restoreCalled: Bool { restoreCallsCount > 0 }
    public var restoreReceivedKind: BackupKind?
    public var restoreReceivedInvocations: [BackupKind] = []
    public var restoreClosure: ((BackupKind) throws -> Void)?

    public func restore(_ kind: BackupKind) throws {
        restoreCallsCount += 1
        restoreReceivedKind = kind
        restoreReceivedInvocations.append(kind)
        if let error = restoreThrowableError {
            throw error
        }
        try restoreClosure?(kind)
    }
}

// swiftlint:enable all

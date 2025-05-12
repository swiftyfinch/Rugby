// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation
@testable import XcodeProj

public final class IXcodeProjectMock: IXcodeProject {

    public init() {}

    // MARK: - folderPaths

    public var folderPathsThrowableError: Error?
    public var folderPathsCallsCount = 0
    public var folderPathsCalled: Bool { folderPathsCallsCount > 0 }
    public var folderPathsReturnValue: [String]!
    public var folderPathsClosure: (() async throws -> [String])?

    public func folderPaths() async throws -> [String] {
        folderPathsCallsCount += 1
        if let error = folderPathsThrowableError {
            throw error
        }
        if let folderPathsClosure = folderPathsClosure {
            return try await folderPathsClosure()
        } else {
            return folderPathsReturnValue
        }
    }

    // MARK: - contains

    public var containsBuildSettingsKeyThrowableError: Error?
    public var containsBuildSettingsKeyCallsCount = 0
    public var containsBuildSettingsKeyCalled: Bool { containsBuildSettingsKeyCallsCount > 0 }
    public var containsBuildSettingsKeyReceivedBuildSettingsKey: String?
    public var containsBuildSettingsKeyReceivedInvocations: [String] = []
    private let containsBuildSettingsKeyReceivedInvocationsLock = NSRecursiveLock()
    public var containsBuildSettingsKeyReturnValue: Bool!
    public var containsBuildSettingsKeyClosure: ((String) async throws -> Bool)?

    public func contains(buildSettingsKey: String) async throws -> Bool {
        containsBuildSettingsKeyCallsCount += 1
        containsBuildSettingsKeyReceivedBuildSettingsKey = buildSettingsKey
        containsBuildSettingsKeyReceivedInvocationsLock.withLock {
            containsBuildSettingsKeyReceivedInvocations.append(buildSettingsKey)
        }
        if let error = containsBuildSettingsKeyThrowableError {
            throw error
        }
        if let containsBuildSettingsKeyClosure = containsBuildSettingsKeyClosure {
            return try await containsBuildSettingsKeyClosure(buildSettingsKey)
        } else {
            return containsBuildSettingsKeyReturnValue
        }
    }

    // MARK: - set

    public var setBuildSettingsKeyValueThrowableError: Error?
    public var setBuildSettingsKeyValueCallsCount = 0
    public var setBuildSettingsKeyValueCalled: Bool { setBuildSettingsKeyValueCallsCount > 0 }
    public var setBuildSettingsKeyValueReceivedArguments: (buildSettingsKey: String, value: BuildSetting)?
    public var setBuildSettingsKeyValueReceivedInvocations: [(buildSettingsKey: String, value: BuildSetting)] = []
    private let setBuildSettingsKeyValueReceivedInvocationsLock = NSRecursiveLock()
    public var setBuildSettingsKeyValueClosure: ((String, BuildSetting) async throws -> Void)?

    public func set(buildSettingsKey: String, value: BuildSetting) async throws {
        setBuildSettingsKeyValueCallsCount += 1
        setBuildSettingsKeyValueReceivedArguments = (buildSettingsKey: buildSettingsKey, value: value)
        setBuildSettingsKeyValueReceivedInvocationsLock.withLock {
            setBuildSettingsKeyValueReceivedInvocations.append((buildSettingsKey: buildSettingsKey, value: value))
        }
        if let error = setBuildSettingsKeyValueThrowableError {
            throw error
        }
        try await setBuildSettingsKeyValueClosure?(buildSettingsKey, value)
    }
}

// swiftlint:enable all

// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

public final class IXcodeProjectMock: IXcodeProject {

    public init() {}

    // MARK: - folderPaths

    public var folderPathsThrowableError: Error?
    public var folderPathsCallsCount = 0
    public var folderPathsCalled: Bool { folderPathsCallsCount > 0 }
    public var folderPathsReturnValue: [String]!
    public var folderPathsClosure: (() async throws -> [String])?

    public func folderPaths() async throws -> [String] {
        if let error = folderPathsThrowableError {
            throw error
        }
        folderPathsCallsCount += 1
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
    public var containsBuildSettingsKeyReturnValue: Bool!
    public var containsBuildSettingsKeyClosure: ((String) async throws -> Bool)?

    public func contains(buildSettingsKey: String) async throws -> Bool {
        if let error = containsBuildSettingsKeyThrowableError {
            throw error
        }
        containsBuildSettingsKeyCallsCount += 1
        containsBuildSettingsKeyReceivedBuildSettingsKey = buildSettingsKey
        containsBuildSettingsKeyReceivedInvocations.append(buildSettingsKey)
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
    public var setBuildSettingsKeyValueReceivedArguments: (buildSettingsKey: String, value: Any)?
    public var setBuildSettingsKeyValueReceivedInvocations: [(buildSettingsKey: String, value: Any)] = []
    public var setBuildSettingsKeyValueClosure: ((String, Any) async throws -> Void)?

    public func set(buildSettingsKey: String, value: Any) async throws {
        if let error = setBuildSettingsKeyValueThrowableError {
            throw error
        }
        setBuildSettingsKeyValueCallsCount += 1
        setBuildSettingsKeyValueReceivedArguments = (buildSettingsKey: buildSettingsKey, value: value)
        setBuildSettingsKeyValueReceivedInvocations.append((buildSettingsKey: buildSettingsKey, value: value))
        try await setBuildSettingsKeyValueClosure?(buildSettingsKey, value)
    }
}

// swiftlint:enable all

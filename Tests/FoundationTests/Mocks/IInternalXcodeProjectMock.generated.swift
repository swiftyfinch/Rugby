// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IInternalXcodeProjectMock: IInternalXcodeProject {

    // MARK: - resetCache

    var resetCacheCallsCount = 0
    var resetCacheCalled: Bool { resetCacheCallsCount > 0 }
    var resetCacheClosure: (() -> Void)?

    func resetCache() {
        resetCacheCallsCount += 1
        resetCacheClosure?()
    }

    // MARK: - save

    var saveThrowableError: Error?
    var saveCallsCount = 0
    var saveCalled: Bool { saveCallsCount > 0 }
    var saveClosure: (() async throws -> Void)?

    func save() async throws {
        if let error = saveThrowableError {
            throw error
        }
        saveCallsCount += 1
        try await saveClosure?()
    }

    // MARK: - findTargets

    var findTargetsByExceptIncludingDependenciesThrowableError: Error?
    var findTargetsByExceptIncludingDependenciesCallsCount = 0
    var findTargetsByExceptIncludingDependenciesCalled: Bool { findTargetsByExceptIncludingDependenciesCallsCount > 0 }
    var findTargetsByExceptIncludingDependenciesReceivedArguments: (regex: NSRegularExpression?, exceptRegex: NSRegularExpression?, includingDependencies: Bool)?
    var findTargetsByExceptIncludingDependenciesReceivedInvocations: [(regex: NSRegularExpression?, exceptRegex: NSRegularExpression?, includingDependencies: Bool)] = []
    var findTargetsByExceptIncludingDependenciesReturnValue: TargetsMap!
    var findTargetsByExceptIncludingDependenciesClosure: ((NSRegularExpression?, NSRegularExpression?, Bool) async throws -> TargetsMap)?

    func findTargets(by regex: NSRegularExpression?, except exceptRegex: NSRegularExpression?, includingDependencies: Bool) async throws -> TargetsMap {
        if let error = findTargetsByExceptIncludingDependenciesThrowableError {
            throw error
        }
        findTargetsByExceptIncludingDependenciesCallsCount += 1
        findTargetsByExceptIncludingDependenciesReceivedArguments = (regex: regex, exceptRegex: exceptRegex, includingDependencies: includingDependencies)
        findTargetsByExceptIncludingDependenciesReceivedInvocations.append((regex: regex, exceptRegex: exceptRegex, includingDependencies: includingDependencies))
        if let findTargetsByExceptIncludingDependenciesClosure = findTargetsByExceptIncludingDependenciesClosure {
            return try await findTargetsByExceptIncludingDependenciesClosure(regex, exceptRegex, includingDependencies)
        } else {
            return findTargetsByExceptIncludingDependenciesReturnValue
        }
    }

    // MARK: - createAggregatedTarget

    var createAggregatedTargetNameDependenciesThrowableError: Error?
    var createAggregatedTargetNameDependenciesCallsCount = 0
    var createAggregatedTargetNameDependenciesCalled: Bool { createAggregatedTargetNameDependenciesCallsCount > 0 }
    var createAggregatedTargetNameDependenciesReceivedArguments: (name: String, dependencies: TargetsMap)?
    var createAggregatedTargetNameDependenciesReceivedInvocations: [(name: String, dependencies: TargetsMap)] = []
    var createAggregatedTargetNameDependenciesReturnValue: IInternalTarget!
    var createAggregatedTargetNameDependenciesClosure: ((String, TargetsMap) async throws -> IInternalTarget)?

    func createAggregatedTarget(name: String, dependencies: TargetsMap) async throws -> IInternalTarget {
        if let error = createAggregatedTargetNameDependenciesThrowableError {
            throw error
        }
        createAggregatedTargetNameDependenciesCallsCount += 1
        createAggregatedTargetNameDependenciesReceivedArguments = (name: name, dependencies: dependencies)
        createAggregatedTargetNameDependenciesReceivedInvocations.append((name: name, dependencies: dependencies))
        if let createAggregatedTargetNameDependenciesClosure = createAggregatedTargetNameDependenciesClosure {
            return try await createAggregatedTargetNameDependenciesClosure(name, dependencies)
        } else {
            return createAggregatedTargetNameDependenciesReturnValue
        }
    }

    // MARK: - deleteTargets

    var deleteTargetsKeepGroupsThrowableError: Error?
    var deleteTargetsKeepGroupsCallsCount = 0
    var deleteTargetsKeepGroupsCalled: Bool { deleteTargetsKeepGroupsCallsCount > 0 }
    var deleteTargetsKeepGroupsReceivedArguments: (targetsForRemove: TargetsMap, keepGroups: Bool)?
    var deleteTargetsKeepGroupsReceivedInvocations: [(targetsForRemove: TargetsMap, keepGroups: Bool)] = []
    var deleteTargetsKeepGroupsClosure: ((TargetsMap, Bool) async throws -> Void)?

    func deleteTargets(_ targetsForRemove: TargetsMap, keepGroups: Bool) async throws {
        if let error = deleteTargetsKeepGroupsThrowableError {
            throw error
        }
        deleteTargetsKeepGroupsCallsCount += 1
        deleteTargetsKeepGroupsReceivedArguments = (targetsForRemove: targetsForRemove, keepGroups: keepGroups)
        deleteTargetsKeepGroupsReceivedInvocations.append((targetsForRemove: targetsForRemove, keepGroups: keepGroups))
        try await deleteTargetsKeepGroupsClosure?(targetsForRemove, keepGroups)
    }

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

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
        saveCallsCount += 1
        if let error = saveThrowableError {
            throw error
        }
        try await saveClosure?()
    }

    // MARK: - findTargets

    var findTargetsByExceptIncludingDependenciesThrowableError: Error?
    var findTargetsByExceptIncludingDependenciesCallsCount = 0
    var findTargetsByExceptIncludingDependenciesCalled: Bool { findTargetsByExceptIncludingDependenciesCallsCount > 0 }
    var findTargetsByExceptIncludingDependenciesReceivedArguments: (regex: NSRegularExpression?, exceptRegex: NSRegularExpression?, includingDependencies: Bool)?
    var findTargetsByExceptIncludingDependenciesReceivedInvocations: [(regex: NSRegularExpression?, exceptRegex: NSRegularExpression?, includingDependencies: Bool)] = []
    private let findTargetsByExceptIncludingDependenciesReceivedInvocationsLock = NSRecursiveLock()
    var findTargetsByExceptIncludingDependenciesReturnValue: TargetsMap!
    var findTargetsByExceptIncludingDependenciesClosure: ((NSRegularExpression?, NSRegularExpression?, Bool) async throws -> TargetsMap)?

    func findTargets(by regex: NSRegularExpression?, except exceptRegex: NSRegularExpression?, includingDependencies: Bool) async throws -> TargetsMap {
        findTargetsByExceptIncludingDependenciesCallsCount += 1
        findTargetsByExceptIncludingDependenciesReceivedArguments = (regex: regex, exceptRegex: exceptRegex, includingDependencies: includingDependencies)
        findTargetsByExceptIncludingDependenciesReceivedInvocationsLock.withLock {
            findTargetsByExceptIncludingDependenciesReceivedInvocations.append((regex: regex, exceptRegex: exceptRegex, includingDependencies: includingDependencies))
        }
        if let error = findTargetsByExceptIncludingDependenciesThrowableError {
            throw error
        }
        if let findTargetsByExceptIncludingDependenciesClosure = findTargetsByExceptIncludingDependenciesClosure {
            return try await findTargetsByExceptIncludingDependenciesClosure(regex, exceptRegex, includingDependencies)
        } else {
            return findTargetsByExceptIncludingDependenciesReturnValue
        }
    }

    // MARK: - createAggregatedTarget

    var createAggregatedTargetNameInDependenciesThrowableError: Error?
    var createAggregatedTargetNameInDependenciesCallsCount = 0
    var createAggregatedTargetNameInDependenciesCalled: Bool { createAggregatedTargetNameInDependenciesCallsCount > 0 }
    var createAggregatedTargetNameInDependenciesReceivedArguments: (name: String, project: IProject, dependencies: TargetsMap)?
    var createAggregatedTargetNameInDependenciesReceivedInvocations: [(name: String, project: IProject, dependencies: TargetsMap)] = []
    private let createAggregatedTargetNameInDependenciesReceivedInvocationsLock = NSRecursiveLock()
    var createAggregatedTargetNameInDependenciesReturnValue: IInternalTarget!
    var createAggregatedTargetNameInDependenciesClosure: ((String, IProject, TargetsMap) async throws -> IInternalTarget)?

    func createAggregatedTarget(name: String, in project: IProject, dependencies: TargetsMap) async throws -> IInternalTarget {
        createAggregatedTargetNameInDependenciesCallsCount += 1
        createAggregatedTargetNameInDependenciesReceivedArguments = (name: name, project: project, dependencies: dependencies)
        createAggregatedTargetNameInDependenciesReceivedInvocationsLock.withLock {
            createAggregatedTargetNameInDependenciesReceivedInvocations.append((name: name, project: project, dependencies: dependencies))
        }
        if let error = createAggregatedTargetNameInDependenciesThrowableError {
            throw error
        }
        if let createAggregatedTargetNameInDependenciesClosure = createAggregatedTargetNameInDependenciesClosure {
            return try await createAggregatedTargetNameInDependenciesClosure(name, project, dependencies)
        } else {
            return createAggregatedTargetNameInDependenciesReturnValue
        }
    }

    // MARK: - createAggregatedTargetInRootProject

    var createAggregatedTargetInRootProjectNameDependenciesThrowableError: Error?
    var createAggregatedTargetInRootProjectNameDependenciesCallsCount = 0
    var createAggregatedTargetInRootProjectNameDependenciesCalled: Bool { createAggregatedTargetInRootProjectNameDependenciesCallsCount > 0 }
    var createAggregatedTargetInRootProjectNameDependenciesReceivedArguments: (name: String, dependencies: TargetsMap)?
    var createAggregatedTargetInRootProjectNameDependenciesReceivedInvocations: [(name: String, dependencies: TargetsMap)] = []
    private let createAggregatedTargetInRootProjectNameDependenciesReceivedInvocationsLock = NSRecursiveLock()
    var createAggregatedTargetInRootProjectNameDependenciesReturnValue: IInternalTarget!
    var createAggregatedTargetInRootProjectNameDependenciesClosure: ((String, TargetsMap) async throws -> IInternalTarget)?

    func createAggregatedTargetInRootProject(name: String, dependencies: TargetsMap) async throws -> IInternalTarget {
        createAggregatedTargetInRootProjectNameDependenciesCallsCount += 1
        createAggregatedTargetInRootProjectNameDependenciesReceivedArguments = (name: name, dependencies: dependencies)
        createAggregatedTargetInRootProjectNameDependenciesReceivedInvocationsLock.withLock {
            createAggregatedTargetInRootProjectNameDependenciesReceivedInvocations.append((name: name, dependencies: dependencies))
        }
        if let error = createAggregatedTargetInRootProjectNameDependenciesThrowableError {
            throw error
        }
        if let createAggregatedTargetInRootProjectNameDependenciesClosure = createAggregatedTargetInRootProjectNameDependenciesClosure {
            return try await createAggregatedTargetInRootProjectNameDependenciesClosure(name, dependencies)
        } else {
            return createAggregatedTargetInRootProjectNameDependenciesReturnValue
        }
    }

    // MARK: - deleteTargets

    var deleteTargetsKeepGroupsThrowableError: Error?
    var deleteTargetsKeepGroupsCallsCount = 0
    var deleteTargetsKeepGroupsCalled: Bool { deleteTargetsKeepGroupsCallsCount > 0 }
    var deleteTargetsKeepGroupsReceivedArguments: (targetsForRemove: TargetsMap, keepGroups: Bool)?
    var deleteTargetsKeepGroupsReceivedInvocations: [(targetsForRemove: TargetsMap, keepGroups: Bool)] = []
    private let deleteTargetsKeepGroupsReceivedInvocationsLock = NSRecursiveLock()
    var deleteTargetsKeepGroupsClosure: ((TargetsMap, Bool) async throws -> Void)?

    func deleteTargets(_ targetsForRemove: TargetsMap, keepGroups: Bool) async throws {
        deleteTargetsKeepGroupsCallsCount += 1
        deleteTargetsKeepGroupsReceivedArguments = (targetsForRemove: targetsForRemove, keepGroups: keepGroups)
        deleteTargetsKeepGroupsReceivedInvocationsLock.withLock {
            deleteTargetsKeepGroupsReceivedInvocations.append((targetsForRemove: targetsForRemove, keepGroups: keepGroups))
        }
        if let error = deleteTargetsKeepGroupsThrowableError {
            throw error
        }
        try await deleteTargetsKeepGroupsClosure?(targetsForRemove, keepGroups)
    }

    // MARK: - addDependencies

    var addDependenciesToThrowableError: Error?
    var addDependenciesToCallsCount = 0
    var addDependenciesToCalled: Bool { addDependenciesToCallsCount > 0 }
    var addDependenciesToReceivedArguments: (dependencies: TargetsMap, target: IInternalTarget)?
    var addDependenciesToReceivedInvocations: [(dependencies: TargetsMap, target: IInternalTarget)] = []
    private let addDependenciesToReceivedInvocationsLock = NSRecursiveLock()
    var addDependenciesToClosure: ((TargetsMap, IInternalTarget) throws -> Void)?

    func addDependencies(_ dependencies: TargetsMap, to target: IInternalTarget) throws {
        addDependenciesToCallsCount += 1
        addDependenciesToReceivedArguments = (dependencies: dependencies, target: target)
        addDependenciesToReceivedInvocationsLock.withLock {
            addDependenciesToReceivedInvocations.append((dependencies: dependencies, target: target))
        }
        if let error = addDependenciesToThrowableError {
            throw error
        }
        try addDependenciesToClosure?(dependencies, target)
    }

    // MARK: - createTestingScheme

    var createTestingSchemeBuildConfigurationTestplanPathCallsCount = 0
    var createTestingSchemeBuildConfigurationTestplanPathCalled: Bool { createTestingSchemeBuildConfigurationTestplanPathCallsCount > 0 }
    var createTestingSchemeBuildConfigurationTestplanPathReceivedArguments: (target: IInternalTarget, buildConfiguration: String, testplanPath: String)?
    var createTestingSchemeBuildConfigurationTestplanPathReceivedInvocations: [(target: IInternalTarget, buildConfiguration: String, testplanPath: String)] = []
    private let createTestingSchemeBuildConfigurationTestplanPathReceivedInvocationsLock = NSRecursiveLock()
    var createTestingSchemeBuildConfigurationTestplanPathClosure: ((IInternalTarget, String, String) -> Void)?

    func createTestingScheme(_ target: IInternalTarget, buildConfiguration: String, testplanPath: String) {
        createTestingSchemeBuildConfigurationTestplanPathCallsCount += 1
        createTestingSchemeBuildConfigurationTestplanPathReceivedArguments = (target: target, buildConfiguration: buildConfiguration, testplanPath: testplanPath)
        createTestingSchemeBuildConfigurationTestplanPathReceivedInvocationsLock.withLock {
            createTestingSchemeBuildConfigurationTestplanPathReceivedInvocations.append((target: target, buildConfiguration: buildConfiguration, testplanPath: testplanPath))
        }
        createTestingSchemeBuildConfigurationTestplanPathClosure?(target, buildConfiguration, testplanPath)
    }

    // MARK: - readWorkspaceProjectPaths

    var readWorkspaceProjectPathsThrowableError: Error?
    var readWorkspaceProjectPathsCallsCount = 0
    var readWorkspaceProjectPathsCalled: Bool { readWorkspaceProjectPathsCallsCount > 0 }
    var readWorkspaceProjectPathsReturnValue: [String]!
    var readWorkspaceProjectPathsClosure: (() throws -> [String])?

    func readWorkspaceProjectPaths() throws -> [String] {
        readWorkspaceProjectPathsCallsCount += 1
        if let error = readWorkspaceProjectPathsThrowableError {
            throw error
        }
        if let readWorkspaceProjectPathsClosure = readWorkspaceProjectPathsClosure {
            return try readWorkspaceProjectPathsClosure()
        } else {
            return readWorkspaceProjectPathsReturnValue
        }
    }

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
    public var setBuildSettingsKeyValueReceivedArguments: (buildSettingsKey: String, value: Any)?
    public var setBuildSettingsKeyValueReceivedInvocations: [(buildSettingsKey: String, value: Any)] = []
    private let setBuildSettingsKeyValueReceivedInvocationsLock = NSRecursiveLock()
    public var setBuildSettingsKeyValueClosure: ((String, Any) async throws -> Void)?

    public func set(buildSettingsKey: String, value: Any) async throws {
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

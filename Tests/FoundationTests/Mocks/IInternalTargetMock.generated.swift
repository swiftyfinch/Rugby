// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation
import XcodeProj

final class IInternalTargetMock: IInternalTarget {
    var name: String {
        get { return underlyingName }
        set(value) { underlyingName = value }
    }
    var underlyingName: String!
    var uuid: TargetId {
        get { return underlyingUuid }
        set(value) { underlyingUuid = value }
    }
    var underlyingUuid: TargetId!
    var context: [AnyHashable: Any] = [:]
    var explicitDependencies: TargetsMap = [:]
    var pbxTarget: PBXTarget {
        get { return underlyingPbxTarget }
        set(value) { underlyingPbxTarget = value }
    }
    var underlyingPbxTarget: PBXTarget!
    var project: Project {
        get { return underlyingProject }
        set(value) { underlyingProject = value }
    }
    var underlyingProject: Project!
    var isPodsUmbrella: Bool {
        get { return underlyingIsPodsUmbrella }
        set(value) { underlyingIsPodsUmbrella = value }
    }
    var underlyingIsPodsUmbrella: Bool!
    var isNative: Bool {
        get { return underlyingIsNative }
        set(value) { underlyingIsNative = value }
    }
    var underlyingIsNative: Bool!
    var isTests: Bool {
        get { return underlyingIsTests }
        set(value) { underlyingIsTests = value }
    }
    var underlyingIsTests: Bool!
    var dependencies: TargetsMap = [:]
    var product: Product?
    var buildRules: [BuildRule] = []
    var buildPhases: [RugbyFoundation.BuildPhase] = []
    var xcconfigPaths: [String] = []
    var configurations: [String: Configuration]?
    var frameworksScriptPath: String?
    var resourcesScriptPath: String?

    // MARK: - updateConfigurations

    var updateConfigurationsCallsCount = 0
    var updateConfigurationsCalled: Bool { updateConfigurationsCallsCount > 0 }
    var updateConfigurationsClosure: (() -> Void)?

    func updateConfigurations() {
        updateConfigurationsCallsCount += 1
        updateConfigurationsClosure?()
    }

    // MARK: - resourceBundleNames

    var resourceBundleNamesThrowableError: Error?
    var resourceBundleNamesCallsCount = 0
    var resourceBundleNamesCalled: Bool { resourceBundleNamesCallsCount > 0 }
    var resourceBundleNamesReturnValue: [String]!
    var resourceBundleNamesClosure: (() throws -> [String])?

    func resourceBundleNames() throws -> [String] {
        if let error = resourceBundleNamesThrowableError {
            throw error
        }
        resourceBundleNamesCallsCount += 1
        if let resourceBundleNamesClosure = resourceBundleNamesClosure {
            return try resourceBundleNamesClosure()
        } else {
            return resourceBundleNamesReturnValue
        }
    }

    // MARK: - addDependencies

    var addDependenciesCallsCount = 0
    var addDependenciesCalled: Bool { addDependenciesCallsCount > 0 }
    var addDependenciesReceivedOther: TargetsMap?
    var addDependenciesReceivedInvocations: [TargetsMap] = []
    var addDependenciesClosure: ((TargetsMap) -> Void)?

    func addDependencies(_ other: TargetsMap) {
        addDependenciesCallsCount += 1
        addDependenciesReceivedOther = other
        addDependenciesReceivedInvocations.append(other)
        addDependenciesClosure?(other)
    }

    // MARK: - deleteDependencies

    var deleteDependenciesCallsCount = 0
    var deleteDependenciesCalled: Bool { deleteDependenciesCallsCount > 0 }
    var deleteDependenciesReceivedOther: TargetsMap?
    var deleteDependenciesReceivedInvocations: [TargetsMap] = []
    var deleteDependenciesClosure: ((TargetsMap) -> Void)?

    func deleteDependencies(_ other: TargetsMap) {
        deleteDependenciesCallsCount += 1
        deleteDependenciesReceivedOther = other
        deleteDependenciesReceivedInvocations.append(other)
        deleteDependenciesClosure?(other)
    }

    // MARK: - resetDependencies

    var resetDependenciesCallsCount = 0
    var resetDependenciesCalled: Bool { resetDependenciesCallsCount > 0 }
    var resetDependenciesClosure: (() -> Void)?

    func resetDependencies() {
        resetDependenciesCallsCount += 1
        resetDependenciesClosure?()
    }
}

// swiftlint:enable all

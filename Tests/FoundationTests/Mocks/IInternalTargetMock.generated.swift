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
    var uuid: String {
        get { return underlyingUuid }
        set(value) { underlyingUuid = value }
    }
    var underlyingUuid: String!
    var context: [AnyHashable: Any] = [:]
    var explicitDependencies: [String: IInternalTarget] = [:]
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
    var dependencies: [String: IInternalTarget] = [:]
    var product: Product?
    var configurations: [String: Configuration]?
    var buildRules: [BuildRule] = []
    var buildPhases: [RugbyFoundation.BuildPhase] = []
    var xcconfigPaths: Set<String> {
        get { return underlyingXcconfigPaths }
        set(value) { underlyingXcconfigPaths = value }
    }
    var underlyingXcconfigPaths: Set<String>!
    var frameworksScriptPath: String?
    var resourcesScriptPath: String?

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
    var addDependenciesReceivedOther: [String: IInternalTarget]?
    var addDependenciesReceivedInvocations: [[String: IInternalTarget]] = []
    var addDependenciesClosure: (([String: IInternalTarget]) -> Void)?

    func addDependencies(_ other: [String: IInternalTarget]) {
        addDependenciesCallsCount += 1
        addDependenciesReceivedOther = other
        addDependenciesReceivedInvocations.append(other)
        addDependenciesClosure?(other)
    }

    // MARK: - deleteDependencies

    var deleteDependenciesCallsCount = 0
    var deleteDependenciesCalled: Bool { deleteDependenciesCallsCount > 0 }
    var deleteDependenciesReceivedOther: [String: IInternalTarget]?
    var deleteDependenciesReceivedInvocations: [[String: IInternalTarget]] = []
    var deleteDependenciesClosure: (([String: IInternalTarget]) -> Void)?

    func deleteDependencies(_ other: [String: IInternalTarget]) {
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

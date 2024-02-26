// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IBuildTargetsManagerMock: IBuildTargetsManager {

    // MARK: - findTargets

    var findTargetsExceptTargetsIncludingTestsThrowableError: Error?
    var findTargetsExceptTargetsIncludingTestsCallsCount = 0
    var findTargetsExceptTargetsIncludingTestsCalled: Bool { findTargetsExceptTargetsIncludingTestsCallsCount > 0 }
    var findTargetsExceptTargetsIncludingTestsReceivedArguments: (targets: NSRegularExpression?, exceptTargets: NSRegularExpression?, includingTests: Bool)?
    var findTargetsExceptTargetsIncludingTestsReceivedInvocations: [(targets: NSRegularExpression?, exceptTargets: NSRegularExpression?, includingTests: Bool)] = []
    var findTargetsExceptTargetsIncludingTestsReturnValue: TargetsMap!
    var findTargetsExceptTargetsIncludingTestsClosure: ((NSRegularExpression?, NSRegularExpression?, Bool) async throws -> TargetsMap)?

    func findTargets(_ targets: NSRegularExpression?, exceptTargets: NSRegularExpression?, includingTests: Bool) async throws -> TargetsMap {
        if let error = findTargetsExceptTargetsIncludingTestsThrowableError {
            throw error
        }
        findTargetsExceptTargetsIncludingTestsCallsCount += 1
        findTargetsExceptTargetsIncludingTestsReceivedArguments = (targets: targets, exceptTargets: exceptTargets, includingTests: includingTests)
        findTargetsExceptTargetsIncludingTestsReceivedInvocations.append((targets: targets, exceptTargets: exceptTargets, includingTests: includingTests))
        if let findTargetsExceptTargetsIncludingTestsClosure = findTargetsExceptTargetsIncludingTestsClosure {
            return try await findTargetsExceptTargetsIncludingTestsClosure(targets, exceptTargets, includingTests)
        } else {
            return findTargetsExceptTargetsIncludingTestsReturnValue
        }
    }

    // MARK: - filterTargets

    var filterTargetsIncludingTestsCallsCount = 0
    var filterTargetsIncludingTestsCalled: Bool { filterTargetsIncludingTestsCallsCount > 0 }
    var filterTargetsIncludingTestsReceivedArguments: (targets: TargetsMap, includingTests: Bool)?
    var filterTargetsIncludingTestsReceivedInvocations: [(targets: TargetsMap, includingTests: Bool)] = []
    var filterTargetsIncludingTestsReturnValue: TargetsMap!
    var filterTargetsIncludingTestsClosure: ((TargetsMap, Bool) -> TargetsMap)?

    func filterTargets(_ targets: TargetsMap, includingTests: Bool) -> TargetsMap {
        filterTargetsIncludingTestsCallsCount += 1
        filterTargetsIncludingTestsReceivedArguments = (targets: targets, includingTests: includingTests)
        filterTargetsIncludingTestsReceivedInvocations.append((targets: targets, includingTests: includingTests))
        if let filterTargetsIncludingTestsClosure = filterTargetsIncludingTestsClosure {
            return filterTargetsIncludingTestsClosure(targets, includingTests)
        } else {
            return filterTargetsIncludingTestsReturnValue
        }
    }

    // MARK: - createTarget

    var createTargetDependenciesThrowableError: Error?
    var createTargetDependenciesCallsCount = 0
    var createTargetDependenciesCalled: Bool { createTargetDependenciesCallsCount > 0 }
    var createTargetDependenciesReceivedDependencies: TargetsMap?
    var createTargetDependenciesReceivedInvocations: [TargetsMap] = []
    var createTargetDependenciesReturnValue: IInternalTarget!
    var createTargetDependenciesClosure: ((TargetsMap) async throws -> IInternalTarget)?

    func createTarget(dependencies: TargetsMap) async throws -> IInternalTarget {
        createTargetDependenciesCallsCount += 1
        createTargetDependenciesReceivedDependencies = dependencies
        createTargetDependenciesReceivedInvocations.append(dependencies)
        if let error = createTargetDependenciesThrowableError {
            throw error
        }
        if let createTargetDependenciesClosure = createTargetDependenciesClosure {
            return try await createTargetDependenciesClosure(dependencies)
        } else {
            return createTargetDependenciesReturnValue
        }
    }
}

// swiftlint:enable all

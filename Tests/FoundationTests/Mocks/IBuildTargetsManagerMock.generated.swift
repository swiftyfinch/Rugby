// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IBuildTargetsManagerMock: IBuildTargetsManager {

    // MARK: - findTargets

    var findTargetsExceptTargetsThrowableError: Error?
    var findTargetsExceptTargetsCallsCount = 0
    var findTargetsExceptTargetsCalled: Bool { findTargetsExceptTargetsCallsCount > 0 }
    var findTargetsExceptTargetsReceivedArguments: (targets: NSRegularExpression?, exceptTargets: NSRegularExpression?)?
    var findTargetsExceptTargetsReceivedInvocations: [(targets: NSRegularExpression?, exceptTargets: NSRegularExpression?)] = []
    var findTargetsExceptTargetsReturnValue: TargetsMap!
    var findTargetsExceptTargetsClosure: ((NSRegularExpression?, NSRegularExpression?) async throws -> TargetsMap)?

    func findTargets(_ targets: NSRegularExpression?, exceptTargets: NSRegularExpression?) async throws -> TargetsMap {
        if let error = findTargetsExceptTargetsThrowableError {
            throw error
        }
        findTargetsExceptTargetsCallsCount += 1
        findTargetsExceptTargetsReceivedArguments = (targets: targets, exceptTargets: exceptTargets)
        findTargetsExceptTargetsReceivedInvocations.append((targets: targets, exceptTargets: exceptTargets))
        if let findTargetsExceptTargetsClosure = findTargetsExceptTargetsClosure {
            return try await findTargetsExceptTargetsClosure(targets, exceptTargets)
        } else {
            return findTargetsExceptTargetsReturnValue
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

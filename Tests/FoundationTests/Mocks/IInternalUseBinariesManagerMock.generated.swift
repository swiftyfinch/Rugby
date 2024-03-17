// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IInternalUseBinariesManagerMock: IInternalUseBinariesManager {

    // MARK: - use

    var useTargetsTargetsTryModeXcargsDeleteSourcesThrowableError: Error?
    var useTargetsTargetsTryModeXcargsDeleteSourcesCallsCount = 0
    var useTargetsTargetsTryModeXcargsDeleteSourcesCalled: Bool { useTargetsTargetsTryModeXcargsDeleteSourcesCallsCount > 0 }
    var useTargetsTargetsTryModeXcargsDeleteSourcesReceivedArguments: (targets: TargetsScope, targetsTryMode: Bool, xcargs: [String], deleteSources: Bool)?
    var useTargetsTargetsTryModeXcargsDeleteSourcesReceivedInvocations: [(targets: TargetsScope, targetsTryMode: Bool, xcargs: [String], deleteSources: Bool)] = []
    private let useTargetsTargetsTryModeXcargsDeleteSourcesReceivedInvocationsLock = NSRecursiveLock()
    var useTargetsTargetsTryModeXcargsDeleteSourcesClosure: ((TargetsScope, Bool, [String], Bool) async throws -> Void)?

    func use(targets: TargetsScope, targetsTryMode: Bool, xcargs: [String], deleteSources: Bool) async throws {
        useTargetsTargetsTryModeXcargsDeleteSourcesCallsCount += 1
        useTargetsTargetsTryModeXcargsDeleteSourcesReceivedArguments = (targets: targets, targetsTryMode: targetsTryMode, xcargs: xcargs, deleteSources: deleteSources)
        useTargetsTargetsTryModeXcargsDeleteSourcesReceivedInvocationsLock.withLock {
            useTargetsTargetsTryModeXcargsDeleteSourcesReceivedInvocations.append((targets: targets, targetsTryMode: targetsTryMode, xcargs: xcargs, deleteSources: deleteSources))
        }
        if let error = useTargetsTargetsTryModeXcargsDeleteSourcesThrowableError {
            throw error
        }
        try await useTargetsTargetsTryModeXcargsDeleteSourcesClosure?(targets, targetsTryMode, xcargs, deleteSources)
    }

    // MARK: - use

    public var useTargetsOptionsXcargsDeleteSourcesThrowableError: Error?
    public var useTargetsOptionsXcargsDeleteSourcesCallsCount = 0
    public var useTargetsOptionsXcargsDeleteSourcesCalled: Bool { useTargetsOptionsXcargsDeleteSourcesCallsCount > 0 }
    public var useTargetsOptionsXcargsDeleteSourcesReceivedArguments: (targetsOptions: TargetsOptions, xcargs: [String], deleteSources: Bool)?
    public var useTargetsOptionsXcargsDeleteSourcesReceivedInvocations: [(targetsOptions: TargetsOptions, xcargs: [String], deleteSources: Bool)] = []
    private let useTargetsOptionsXcargsDeleteSourcesReceivedInvocationsLock = NSRecursiveLock()
    public var useTargetsOptionsXcargsDeleteSourcesClosure: ((TargetsOptions, [String], Bool) async throws -> Void)?

    public func use(targetsOptions: TargetsOptions, xcargs: [String], deleteSources: Bool) async throws {
        useTargetsOptionsXcargsDeleteSourcesCallsCount += 1
        useTargetsOptionsXcargsDeleteSourcesReceivedArguments = (targetsOptions: targetsOptions, xcargs: xcargs, deleteSources: deleteSources)
        useTargetsOptionsXcargsDeleteSourcesReceivedInvocationsLock.withLock {
            useTargetsOptionsXcargsDeleteSourcesReceivedInvocations.append((targetsOptions: targetsOptions, xcargs: xcargs, deleteSources: deleteSources))
        }
        if let error = useTargetsOptionsXcargsDeleteSourcesThrowableError {
            throw error
        }
        try await useTargetsOptionsXcargsDeleteSourcesClosure?(targetsOptions, xcargs, deleteSources)
    }

    // MARK: - use

    public var useTargetsKeepGroupsThrowableError: Error?
    public var useTargetsKeepGroupsCallsCount = 0
    public var useTargetsKeepGroupsCalled: Bool { useTargetsKeepGroupsCallsCount > 0 }
    public var useTargetsKeepGroupsReceivedArguments: (targets: [String: ITarget], keepGroups: Bool)?
    public var useTargetsKeepGroupsReceivedInvocations: [(targets: [String: ITarget], keepGroups: Bool)] = []
    private let useTargetsKeepGroupsReceivedInvocationsLock = NSRecursiveLock()
    public var useTargetsKeepGroupsClosure: (([String: ITarget], Bool) async throws -> Void)?

    public func use(targets: [String: ITarget], keepGroups: Bool) async throws {
        useTargetsKeepGroupsCallsCount += 1
        useTargetsKeepGroupsReceivedArguments = (targets: targets, keepGroups: keepGroups)
        useTargetsKeepGroupsReceivedInvocationsLock.withLock {
            useTargetsKeepGroupsReceivedInvocations.append((targets: targets, keepGroups: keepGroups))
        }
        if let error = useTargetsKeepGroupsThrowableError {
            throw error
        }
        try await useTargetsKeepGroupsClosure?(targets, keepGroups)
    }
}

// swiftlint:enable all

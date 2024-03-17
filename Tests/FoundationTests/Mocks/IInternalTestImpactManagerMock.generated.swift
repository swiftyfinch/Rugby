// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IInternalTestImpactManagerMock: IInternalTestImpactManager {

    // MARK: - fetchTestTargets

    var fetchTestTargetsTargetsOptionsBuildOptionsQuietThrowableError: Error?
    var fetchTestTargetsTargetsOptionsBuildOptionsQuietCallsCount = 0
    var fetchTestTargetsTargetsOptionsBuildOptionsQuietCalled: Bool { fetchTestTargetsTargetsOptionsBuildOptionsQuietCallsCount > 0 }
    var fetchTestTargetsTargetsOptionsBuildOptionsQuietReceivedArguments: (targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, quiet: Bool)?
    var fetchTestTargetsTargetsOptionsBuildOptionsQuietReceivedInvocations: [(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, quiet: Bool)] = []
    private let fetchTestTargetsTargetsOptionsBuildOptionsQuietReceivedInvocationsLock = NSRecursiveLock()
    var fetchTestTargetsTargetsOptionsBuildOptionsQuietReturnValue: TargetsMap!
    var fetchTestTargetsTargetsOptionsBuildOptionsQuietClosure: ((TargetsOptions, XcodeBuildOptions, Bool) async throws -> TargetsMap)?

    func fetchTestTargets(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, quiet: Bool) async throws -> TargetsMap {
        fetchTestTargetsTargetsOptionsBuildOptionsQuietCallsCount += 1
        fetchTestTargetsTargetsOptionsBuildOptionsQuietReceivedArguments = (targetsOptions: targetsOptions, buildOptions: buildOptions, quiet: quiet)
        fetchTestTargetsTargetsOptionsBuildOptionsQuietReceivedInvocationsLock.withLock {
            fetchTestTargetsTargetsOptionsBuildOptionsQuietReceivedInvocations.append((targetsOptions: targetsOptions, buildOptions: buildOptions, quiet: quiet))
        }
        if let error = fetchTestTargetsTargetsOptionsBuildOptionsQuietThrowableError {
            throw error
        }
        if let fetchTestTargetsTargetsOptionsBuildOptionsQuietClosure = fetchTestTargetsTargetsOptionsBuildOptionsQuietClosure {
            return try await fetchTestTargetsTargetsOptionsBuildOptionsQuietClosure(targetsOptions, buildOptions, quiet)
        } else {
            return fetchTestTargetsTargetsOptionsBuildOptionsQuietReturnValue
        }
    }

    // MARK: - missingTargets

    var missingTargetsTargetsOptionsBuildOptionsQuietThrowableError: Error?
    var missingTargetsTargetsOptionsBuildOptionsQuietCallsCount = 0
    var missingTargetsTargetsOptionsBuildOptionsQuietCalled: Bool { missingTargetsTargetsOptionsBuildOptionsQuietCallsCount > 0 }
    var missingTargetsTargetsOptionsBuildOptionsQuietReceivedArguments: (targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, quiet: Bool)?
    var missingTargetsTargetsOptionsBuildOptionsQuietReceivedInvocations: [(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, quiet: Bool)] = []
    private let missingTargetsTargetsOptionsBuildOptionsQuietReceivedInvocationsLock = NSRecursiveLock()
    var missingTargetsTargetsOptionsBuildOptionsQuietReturnValue: TargetsMap!
    var missingTargetsTargetsOptionsBuildOptionsQuietClosure: ((TargetsOptions, XcodeBuildOptions, Bool) async throws -> TargetsMap)?

    func missingTargets(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, quiet: Bool) async throws -> TargetsMap {
        missingTargetsTargetsOptionsBuildOptionsQuietCallsCount += 1
        missingTargetsTargetsOptionsBuildOptionsQuietReceivedArguments = (targetsOptions: targetsOptions, buildOptions: buildOptions, quiet: quiet)
        missingTargetsTargetsOptionsBuildOptionsQuietReceivedInvocationsLock.withLock {
            missingTargetsTargetsOptionsBuildOptionsQuietReceivedInvocations.append((targetsOptions: targetsOptions, buildOptions: buildOptions, quiet: quiet))
        }
        if let error = missingTargetsTargetsOptionsBuildOptionsQuietThrowableError {
            throw error
        }
        if let missingTargetsTargetsOptionsBuildOptionsQuietClosure = missingTargetsTargetsOptionsBuildOptionsQuietClosure {
            return try await missingTargetsTargetsOptionsBuildOptionsQuietClosure(targetsOptions, buildOptions, quiet)
        } else {
            return missingTargetsTargetsOptionsBuildOptionsQuietReturnValue
        }
    }

    // MARK: - impact

    public var impactTargetsOptionsBuildOptionsThrowableError: Error?
    public var impactTargetsOptionsBuildOptionsCallsCount = 0
    public var impactTargetsOptionsBuildOptionsCalled: Bool { impactTargetsOptionsBuildOptionsCallsCount > 0 }
    public var impactTargetsOptionsBuildOptionsReceivedArguments: (targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions)?
    public var impactTargetsOptionsBuildOptionsReceivedInvocations: [(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions)] = []
    private let impactTargetsOptionsBuildOptionsReceivedInvocationsLock = NSRecursiveLock()
    public var impactTargetsOptionsBuildOptionsClosure: ((TargetsOptions, XcodeBuildOptions) async throws -> Void)?

    public func impact(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions) async throws {
        impactTargetsOptionsBuildOptionsCallsCount += 1
        impactTargetsOptionsBuildOptionsReceivedArguments = (targetsOptions: targetsOptions, buildOptions: buildOptions)
        impactTargetsOptionsBuildOptionsReceivedInvocationsLock.withLock {
            impactTargetsOptionsBuildOptionsReceivedInvocations.append((targetsOptions: targetsOptions, buildOptions: buildOptions))
        }
        if let error = impactTargetsOptionsBuildOptionsThrowableError {
            throw error
        }
        try await impactTargetsOptionsBuildOptionsClosure?(targetsOptions, buildOptions)
    }

    // MARK: - markAsPassed

    public var markAsPassedTargetsOptionsBuildOptionsUpToDateBranchThrowableError: Error?
    public var markAsPassedTargetsOptionsBuildOptionsUpToDateBranchCallsCount = 0
    public var markAsPassedTargetsOptionsBuildOptionsUpToDateBranchCalled: Bool { markAsPassedTargetsOptionsBuildOptionsUpToDateBranchCallsCount > 0 }
    public var markAsPassedTargetsOptionsBuildOptionsUpToDateBranchReceivedArguments: (targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, upToDateBranch: String?)?
    public var markAsPassedTargetsOptionsBuildOptionsUpToDateBranchReceivedInvocations: [(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, upToDateBranch: String?)] = []
    private let markAsPassedTargetsOptionsBuildOptionsUpToDateBranchReceivedInvocationsLock = NSRecursiveLock()
    public var markAsPassedTargetsOptionsBuildOptionsUpToDateBranchClosure: ((TargetsOptions, XcodeBuildOptions, String?) async throws -> Void)?

    public func markAsPassed(targetsOptions: TargetsOptions, buildOptions: XcodeBuildOptions, upToDateBranch: String?) async throws {
        markAsPassedTargetsOptionsBuildOptionsUpToDateBranchCallsCount += 1
        markAsPassedTargetsOptionsBuildOptionsUpToDateBranchReceivedArguments = (targetsOptions: targetsOptions, buildOptions: buildOptions, upToDateBranch: upToDateBranch)
        markAsPassedTargetsOptionsBuildOptionsUpToDateBranchReceivedInvocationsLock.withLock {
            markAsPassedTargetsOptionsBuildOptionsUpToDateBranchReceivedInvocations.append((targetsOptions: targetsOptions, buildOptions: buildOptions, upToDateBranch: upToDateBranch))
        }
        if let error = markAsPassedTargetsOptionsBuildOptionsUpToDateBranchThrowableError {
            throw error
        }
        try await markAsPassedTargetsOptionsBuildOptionsUpToDateBranchClosure?(targetsOptions, buildOptions, upToDateBranch)
    }
}

// swiftlint:enable all

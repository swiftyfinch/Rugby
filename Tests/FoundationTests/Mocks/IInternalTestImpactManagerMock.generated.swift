// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IInternalTestImpactManagerMock: IInternalTestImpactManager {

    // MARK: - fetchTestTargets

    var fetchTestTargetsExceptTargetsRegexBuildOptionsQuietThrowableError: Error?
    var fetchTestTargetsExceptTargetsRegexBuildOptionsQuietCallsCount = 0
    var fetchTestTargetsExceptTargetsRegexBuildOptionsQuietCalled: Bool { fetchTestTargetsExceptTargetsRegexBuildOptionsQuietCallsCount > 0 }
    var fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedArguments: (targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, quiet: Bool)?
    var fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocations: [(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, quiet: Bool)] = []
    private let fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocationsLock = NSRecursiveLock()
    var fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReturnValue: TargetsMap!
    var fetchTestTargetsExceptTargetsRegexBuildOptionsQuietClosure: ((NSRegularExpression?, NSRegularExpression?, XcodeBuildOptions, Bool) async throws -> TargetsMap)?

    func fetchTestTargets(_ targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, quiet: Bool) async throws -> TargetsMap {
        fetchTestTargetsExceptTargetsRegexBuildOptionsQuietCallsCount += 1
        fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedArguments = (targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions, quiet: quiet)
        fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocationsLock.withLock {
            fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocations.append((targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions, quiet: quiet))
        }
        if let error = fetchTestTargetsExceptTargetsRegexBuildOptionsQuietThrowableError {
            throw error
        }
        if let fetchTestTargetsExceptTargetsRegexBuildOptionsQuietClosure = fetchTestTargetsExceptTargetsRegexBuildOptionsQuietClosure {
            return try await fetchTestTargetsExceptTargetsRegexBuildOptionsQuietClosure(targetsRegex, exceptTargetsRegex, buildOptions, quiet)
        } else {
            return fetchTestTargetsExceptTargetsRegexBuildOptionsQuietReturnValue
        }
    }

    // MARK: - missingTargets

    var missingTargetsExceptTargetsRegexBuildOptionsQuietThrowableError: Error?
    var missingTargetsExceptTargetsRegexBuildOptionsQuietCallsCount = 0
    var missingTargetsExceptTargetsRegexBuildOptionsQuietCalled: Bool { missingTargetsExceptTargetsRegexBuildOptionsQuietCallsCount > 0 }
    var missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedArguments: (targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, quiet: Bool)?
    var missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocations: [(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, quiet: Bool)] = []
    private let missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocationsLock = NSRecursiveLock()
    var missingTargetsExceptTargetsRegexBuildOptionsQuietReturnValue: TargetsMap!
    var missingTargetsExceptTargetsRegexBuildOptionsQuietClosure: ((NSRegularExpression?, NSRegularExpression?, XcodeBuildOptions, Bool) async throws -> TargetsMap)?

    func missingTargets(_ targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, quiet: Bool) async throws -> TargetsMap {
        missingTargetsExceptTargetsRegexBuildOptionsQuietCallsCount += 1
        missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedArguments = (targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions, quiet: quiet)
        missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocationsLock.withLock {
            missingTargetsExceptTargetsRegexBuildOptionsQuietReceivedInvocations.append((targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions, quiet: quiet))
        }
        if let error = missingTargetsExceptTargetsRegexBuildOptionsQuietThrowableError {
            throw error
        }
        if let missingTargetsExceptTargetsRegexBuildOptionsQuietClosure = missingTargetsExceptTargetsRegexBuildOptionsQuietClosure {
            return try await missingTargetsExceptTargetsRegexBuildOptionsQuietClosure(targetsRegex, exceptTargetsRegex, buildOptions, quiet)
        } else {
            return missingTargetsExceptTargetsRegexBuildOptionsQuietReturnValue
        }
    }

    // MARK: - impact

    public var impactTargetsRegexExceptTargetsRegexBuildOptionsThrowableError: Error?
    public var impactTargetsRegexExceptTargetsRegexBuildOptionsCallsCount = 0
    public var impactTargetsRegexExceptTargetsRegexBuildOptionsCalled: Bool { impactTargetsRegexExceptTargetsRegexBuildOptionsCallsCount > 0 }
    public var impactTargetsRegexExceptTargetsRegexBuildOptionsReceivedArguments: (targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions)?
    public var impactTargetsRegexExceptTargetsRegexBuildOptionsReceivedInvocations: [(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions)] = []
    private let impactTargetsRegexExceptTargetsRegexBuildOptionsReceivedInvocationsLock = NSRecursiveLock()
    public var impactTargetsRegexExceptTargetsRegexBuildOptionsClosure: ((NSRegularExpression?, NSRegularExpression?, XcodeBuildOptions) async throws -> Void)?

    public func impact(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions) async throws {
        impactTargetsRegexExceptTargetsRegexBuildOptionsCallsCount += 1
        impactTargetsRegexExceptTargetsRegexBuildOptionsReceivedArguments = (targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions)
        impactTargetsRegexExceptTargetsRegexBuildOptionsReceivedInvocationsLock.withLock {
            impactTargetsRegexExceptTargetsRegexBuildOptionsReceivedInvocations.append((targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions))
        }
        if let error = impactTargetsRegexExceptTargetsRegexBuildOptionsThrowableError {
            throw error
        }
        try await impactTargetsRegexExceptTargetsRegexBuildOptionsClosure?(targetsRegex, exceptTargetsRegex, buildOptions)
    }

    // MARK: - markAsPassed

    public var markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchThrowableError: Error?
    public var markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchCallsCount = 0
    public var markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchCalled: Bool { markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchCallsCount > 0 }
    public var markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchReceivedArguments: (targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, upToDateBranch: String?)?
    public var markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchReceivedInvocations: [(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, upToDateBranch: String?)] = []
    private let markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchReceivedInvocationsLock = NSRecursiveLock()
    public var markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchClosure: ((NSRegularExpression?, NSRegularExpression?, XcodeBuildOptions, String?) async throws -> Void)?

    public func markAsPassed(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, buildOptions: XcodeBuildOptions, upToDateBranch: String?) async throws {
        markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchCallsCount += 1
        markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchReceivedArguments = (targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions, upToDateBranch: upToDateBranch)
        markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchReceivedInvocationsLock.withLock {
            markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchReceivedInvocations.append((targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, buildOptions: buildOptions, upToDateBranch: upToDateBranch))
        }
        if let error = markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchThrowableError {
            throw error
        }
        try await markAsPassedTargetsRegexExceptTargetsRegexBuildOptionsUpToDateBranchClosure?(targetsRegex, exceptTargetsRegex, buildOptions, upToDateBranch)
    }
}

// swiftlint:enable all

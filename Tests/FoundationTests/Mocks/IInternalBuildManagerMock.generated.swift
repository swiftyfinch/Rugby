// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IInternalBuildManagerMock: IInternalBuildManager {

    // MARK: - prepare

    var prepareTargetsFreeSpaceIfNeededPatchLibrariesThrowableError: Error?
    var prepareTargetsFreeSpaceIfNeededPatchLibrariesCallsCount = 0
    var prepareTargetsFreeSpaceIfNeededPatchLibrariesCalled: Bool { prepareTargetsFreeSpaceIfNeededPatchLibrariesCallsCount > 0 }
    var prepareTargetsFreeSpaceIfNeededPatchLibrariesReceivedArguments: (targets: TargetsScope, freeSpaceIfNeeded: Bool, patchLibraries: Bool)?
    var prepareTargetsFreeSpaceIfNeededPatchLibrariesReceivedInvocations: [(targets: TargetsScope, freeSpaceIfNeeded: Bool, patchLibraries: Bool)] = []
    private let prepareTargetsFreeSpaceIfNeededPatchLibrariesReceivedInvocationsLock = NSRecursiveLock()
    var prepareTargetsFreeSpaceIfNeededPatchLibrariesReturnValue: TargetsMap!
    var prepareTargetsFreeSpaceIfNeededPatchLibrariesClosure: ((TargetsScope, Bool, Bool) async throws -> TargetsMap)?

    func prepare(targets: TargetsScope, freeSpaceIfNeeded: Bool, patchLibraries: Bool) async throws -> TargetsMap {
        prepareTargetsFreeSpaceIfNeededPatchLibrariesCallsCount += 1
        prepareTargetsFreeSpaceIfNeededPatchLibrariesReceivedArguments = (targets: targets, freeSpaceIfNeeded: freeSpaceIfNeeded, patchLibraries: patchLibraries)
        prepareTargetsFreeSpaceIfNeededPatchLibrariesReceivedInvocationsLock.withLock {
            prepareTargetsFreeSpaceIfNeededPatchLibrariesReceivedInvocations.append((targets: targets, freeSpaceIfNeeded: freeSpaceIfNeeded, patchLibraries: patchLibraries))
        }
        if let error = prepareTargetsFreeSpaceIfNeededPatchLibrariesThrowableError {
            throw error
        }
        if let prepareTargetsFreeSpaceIfNeededPatchLibrariesClosure = prepareTargetsFreeSpaceIfNeededPatchLibrariesClosure {
            return try await prepareTargetsFreeSpaceIfNeededPatchLibrariesClosure(targets, freeSpaceIfNeeded, patchLibraries)
        } else {
            return prepareTargetsFreeSpaceIfNeededPatchLibrariesReturnValue
        }
    }

    // MARK: - makeBuildTarget

    var makeBuildTargetThrowableError: Error?
    var makeBuildTargetCallsCount = 0
    var makeBuildTargetCalled: Bool { makeBuildTargetCallsCount > 0 }
    var makeBuildTargetReceivedTargets: TargetsMap?
    var makeBuildTargetReceivedInvocations: [TargetsMap] = []
    private let makeBuildTargetReceivedInvocationsLock = NSRecursiveLock()
    var makeBuildTargetReturnValue: IInternalTarget!
    var makeBuildTargetClosure: ((TargetsMap) async throws -> IInternalTarget)?

    func makeBuildTarget(_ targets: TargetsMap) async throws -> IInternalTarget {
        makeBuildTargetCallsCount += 1
        makeBuildTargetReceivedTargets = targets
        makeBuildTargetReceivedInvocationsLock.withLock {
            makeBuildTargetReceivedInvocations.append(targets)
        }
        if let error = makeBuildTargetThrowableError {
            throw error
        }
        if let makeBuildTargetClosure = makeBuildTargetClosure {
            return try await makeBuildTargetClosure(targets)
        } else {
            return makeBuildTargetReturnValue
        }
    }

    // MARK: - build

    var buildOptionsPathsThrowableError: Error?
    var buildOptionsPathsCallsCount = 0
    var buildOptionsPathsCalled: Bool { buildOptionsPathsCallsCount > 0 }
    var buildOptionsPathsReceivedArguments: (target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths)?
    var buildOptionsPathsReceivedInvocations: [(target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths)] = []
    private let buildOptionsPathsReceivedInvocationsLock = NSRecursiveLock()
    var buildOptionsPathsClosure: ((IInternalTarget, XcodeBuildOptions, XcodeBuildPaths) async throws -> Void)?

    func build(_ target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws {
        buildOptionsPathsCallsCount += 1
        buildOptionsPathsReceivedArguments = (target: target, options: options, paths: paths)
        buildOptionsPathsReceivedInvocationsLock.withLock {
            buildOptionsPathsReceivedInvocations.append((target: target, options: options, paths: paths))
        }
        if let error = buildOptionsPathsThrowableError {
            throw error
        }
        try await buildOptionsPathsClosure?(target, options, paths)
    }

    // MARK: - build

    var buildTargetsOptionsPathsIgnoreCacheThrowableError: Error?
    var buildTargetsOptionsPathsIgnoreCacheCallsCount = 0
    var buildTargetsOptionsPathsIgnoreCacheCalled: Bool { buildTargetsOptionsPathsIgnoreCacheCallsCount > 0 }
    var buildTargetsOptionsPathsIgnoreCacheReceivedArguments: (targets: TargetsScope, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)?
    var buildTargetsOptionsPathsIgnoreCacheReceivedInvocations: [(targets: TargetsScope, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)] = []
    private let buildTargetsOptionsPathsIgnoreCacheReceivedInvocationsLock = NSRecursiveLock()
    var buildTargetsOptionsPathsIgnoreCacheClosure: ((TargetsScope, XcodeBuildOptions, XcodeBuildPaths, Bool) async throws -> Void)?

    func build(targets: TargetsScope, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool) async throws {
        buildTargetsOptionsPathsIgnoreCacheCallsCount += 1
        buildTargetsOptionsPathsIgnoreCacheReceivedArguments = (targets: targets, options: options, paths: paths, ignoreCache: ignoreCache)
        buildTargetsOptionsPathsIgnoreCacheReceivedInvocationsLock.withLock {
            buildTargetsOptionsPathsIgnoreCacheReceivedInvocations.append((targets: targets, options: options, paths: paths, ignoreCache: ignoreCache))
        }
        if let error = buildTargetsOptionsPathsIgnoreCacheThrowableError {
            throw error
        }
        try await buildTargetsOptionsPathsIgnoreCacheClosure?(targets, options, paths, ignoreCache)
    }

    // MARK: - build

    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheThrowableError: Error?
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCallsCount = 0
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCalled: Bool { buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCallsCount > 0 }
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedArguments: (targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)?
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedInvocations: [(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)] = []
    private let buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedInvocationsLock = NSRecursiveLock()
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheClosure: ((NSRegularExpression?, NSRegularExpression?, XcodeBuildOptions, XcodeBuildPaths, Bool) async throws -> Void)?

    public func build(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool) async throws {
        buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCallsCount += 1
        buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedArguments = (targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, options: options, paths: paths, ignoreCache: ignoreCache)
        buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedInvocationsLock.withLock {
            buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedInvocations.append((targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, options: options, paths: paths, ignoreCache: ignoreCache))
        }
        if let error = buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheThrowableError {
            throw error
        }
        try await buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheClosure?(targetsRegex, exceptTargetsRegex, options, paths, ignoreCache)
    }
}

// swiftlint:enable all

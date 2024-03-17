// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IInternalBuildManagerMock: IInternalBuildManager {

    // MARK: - prepare

    var prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesThrowableError: Error?
    var prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesCallsCount = 0
    var prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesCalled: Bool { prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesCallsCount > 0 }
    var prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReceivedArguments: (targets: TargetsScope, targetsTryMode: Bool, freeSpaceIfNeeded: Bool, patchLibraries: Bool)?
    var prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReceivedInvocations: [(targets: TargetsScope, targetsTryMode: Bool, freeSpaceIfNeeded: Bool, patchLibraries: Bool)] = []
    private let prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReceivedInvocationsLock = NSRecursiveLock()
    var prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReturnValue: TargetsMap!
    var prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesClosure: ((TargetsScope, Bool, Bool, Bool) async throws -> TargetsMap)?

    func prepare(targets: TargetsScope, targetsTryMode: Bool, freeSpaceIfNeeded: Bool, patchLibraries: Bool) async throws -> TargetsMap {
        prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesCallsCount += 1
        prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReceivedArguments = (targets: targets, targetsTryMode: targetsTryMode, freeSpaceIfNeeded: freeSpaceIfNeeded, patchLibraries: patchLibraries)
        prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReceivedInvocationsLock.withLock {
            prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReceivedInvocations.append((targets: targets, targetsTryMode: targetsTryMode, freeSpaceIfNeeded: freeSpaceIfNeeded, patchLibraries: patchLibraries))
        }
        if let error = prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesThrowableError {
            throw error
        }
        if let prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesClosure = prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesClosure {
            return try await prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesClosure(targets, targetsTryMode, freeSpaceIfNeeded, patchLibraries)
        } else {
            return prepareTargetsTargetsTryModeFreeSpaceIfNeededPatchLibrariesReturnValue
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

    var buildTargetsTargetsTryModeOptionsPathsIgnoreCacheThrowableError: Error?
    var buildTargetsTargetsTryModeOptionsPathsIgnoreCacheCallsCount = 0
    var buildTargetsTargetsTryModeOptionsPathsIgnoreCacheCalled: Bool { buildTargetsTargetsTryModeOptionsPathsIgnoreCacheCallsCount > 0 }
    var buildTargetsTargetsTryModeOptionsPathsIgnoreCacheReceivedArguments: (targets: TargetsScope, targetsTryMode: Bool, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)?
    var buildTargetsTargetsTryModeOptionsPathsIgnoreCacheReceivedInvocations: [(targets: TargetsScope, targetsTryMode: Bool, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)] = []
    private let buildTargetsTargetsTryModeOptionsPathsIgnoreCacheReceivedInvocationsLock = NSRecursiveLock()
    var buildTargetsTargetsTryModeOptionsPathsIgnoreCacheClosure: ((TargetsScope, Bool, XcodeBuildOptions, XcodeBuildPaths, Bool) async throws -> Void)?

    func build(targets: TargetsScope, targetsTryMode: Bool, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool) async throws {
        buildTargetsTargetsTryModeOptionsPathsIgnoreCacheCallsCount += 1
        buildTargetsTargetsTryModeOptionsPathsIgnoreCacheReceivedArguments = (targets: targets, targetsTryMode: targetsTryMode, options: options, paths: paths, ignoreCache: ignoreCache)
        buildTargetsTargetsTryModeOptionsPathsIgnoreCacheReceivedInvocationsLock.withLock {
            buildTargetsTargetsTryModeOptionsPathsIgnoreCacheReceivedInvocations.append((targets: targets, targetsTryMode: targetsTryMode, options: options, paths: paths, ignoreCache: ignoreCache))
        }
        if let error = buildTargetsTargetsTryModeOptionsPathsIgnoreCacheThrowableError {
            throw error
        }
        try await buildTargetsTargetsTryModeOptionsPathsIgnoreCacheClosure?(targets, targetsTryMode, options, paths, ignoreCache)
    }

    // MARK: - build

    public var buildTargetsOptionsOptionsPathsIgnoreCacheThrowableError: Error?
    public var buildTargetsOptionsOptionsPathsIgnoreCacheCallsCount = 0
    public var buildTargetsOptionsOptionsPathsIgnoreCacheCalled: Bool { buildTargetsOptionsOptionsPathsIgnoreCacheCallsCount > 0 }
    public var buildTargetsOptionsOptionsPathsIgnoreCacheReceivedArguments: (targetsOptions: TargetsOptions, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)?
    public var buildTargetsOptionsOptionsPathsIgnoreCacheReceivedInvocations: [(targetsOptions: TargetsOptions, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)] = []
    private let buildTargetsOptionsOptionsPathsIgnoreCacheReceivedInvocationsLock = NSRecursiveLock()
    public var buildTargetsOptionsOptionsPathsIgnoreCacheClosure: ((TargetsOptions, XcodeBuildOptions, XcodeBuildPaths, Bool) async throws -> Void)?

    public func build(targetsOptions: TargetsOptions, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool) async throws {
        buildTargetsOptionsOptionsPathsIgnoreCacheCallsCount += 1
        buildTargetsOptionsOptionsPathsIgnoreCacheReceivedArguments = (targetsOptions: targetsOptions, options: options, paths: paths, ignoreCache: ignoreCache)
        buildTargetsOptionsOptionsPathsIgnoreCacheReceivedInvocationsLock.withLock {
            buildTargetsOptionsOptionsPathsIgnoreCacheReceivedInvocations.append((targetsOptions: targetsOptions, options: options, paths: paths, ignoreCache: ignoreCache))
        }
        if let error = buildTargetsOptionsOptionsPathsIgnoreCacheThrowableError {
            throw error
        }
        try await buildTargetsOptionsOptionsPathsIgnoreCacheClosure?(targetsOptions, options, paths, ignoreCache)
    }
}

// swiftlint:enable all

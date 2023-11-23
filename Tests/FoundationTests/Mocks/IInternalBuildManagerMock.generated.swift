// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IInternalBuildManagerMock: IInternalBuildManager {

    // MARK: - prepare

    var prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesThrowableError: Error?
    var prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesCallsCount = 0
    var prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesCalled: Bool { prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesCallsCount > 0 }
    var prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReceivedArguments: (targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, freeSpaceIfNeeded: Bool, patchLibraries: Bool)?
    var prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReceivedInvocations: [(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, freeSpaceIfNeeded: Bool, patchLibraries: Bool)] = []
    var prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReturnValue: TargetsMap!
    var prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesClosure: ((NSRegularExpression?, NSRegularExpression?, Bool, Bool) async throws -> TargetsMap)?

    func prepare(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, freeSpaceIfNeeded: Bool, patchLibraries: Bool) async throws -> TargetsMap {
        if let error = prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesThrowableError {
            throw error
        }
        prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesCallsCount += 1
        prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReceivedArguments = (targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, freeSpaceIfNeeded: freeSpaceIfNeeded, patchLibraries: patchLibraries)
        prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReceivedInvocations.append((targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, freeSpaceIfNeeded: freeSpaceIfNeeded, patchLibraries: patchLibraries))
        if let prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesClosure = prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesClosure {
            return try await prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesClosure(targetsRegex, exceptTargetsRegex, freeSpaceIfNeeded, patchLibraries)
        } else {
            return prepareTargetsRegexExceptTargetsRegexFreeSpaceIfNeededPatchLibrariesReturnValue
        }
    }

    // MARK: - makeBuildTarget

    var makeBuildTargetThrowableError: Error?
    var makeBuildTargetCallsCount = 0
    var makeBuildTargetCalled: Bool { makeBuildTargetCallsCount > 0 }
    var makeBuildTargetReceivedTargets: TargetsMap?
    var makeBuildTargetReceivedInvocations: [TargetsMap] = []
    var makeBuildTargetReturnValue: IInternalTarget!
    var makeBuildTargetClosure: ((TargetsMap) async throws -> IInternalTarget)?

    func makeBuildTarget(_ targets: TargetsMap) async throws -> IInternalTarget {
        if let error = makeBuildTargetThrowableError {
            throw error
        }
        makeBuildTargetCallsCount += 1
        makeBuildTargetReceivedTargets = targets
        makeBuildTargetReceivedInvocations.append(targets)
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
    var buildOptionsPathsClosure: ((IInternalTarget, XcodeBuildOptions, XcodeBuildPaths) async throws -> Void)?

    func build(_ target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws {
        if let error = buildOptionsPathsThrowableError {
            throw error
        }
        buildOptionsPathsCallsCount += 1
        buildOptionsPathsReceivedArguments = (target: target, options: options, paths: paths)
        buildOptionsPathsReceivedInvocations.append((target: target, options: options, paths: paths))
        try await buildOptionsPathsClosure?(target, options, paths)
    }

    // MARK: - build

    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheThrowableError: Error?
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCallsCount = 0
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCalled: Bool { buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCallsCount > 0 }
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedArguments: (targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)?
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedInvocations: [(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool)] = []
    public var buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheClosure: ((NSRegularExpression?, NSRegularExpression?, XcodeBuildOptions, XcodeBuildPaths, Bool) async throws -> Void)?

    public func build(targetsRegex: NSRegularExpression?, exceptTargetsRegex: NSRegularExpression?, options: XcodeBuildOptions, paths: XcodeBuildPaths, ignoreCache: Bool) async throws {
        if let error = buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheThrowableError {
            throw error
        }
        buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheCallsCount += 1
        buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedArguments = (targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, options: options, paths: paths, ignoreCache: ignoreCache)
        buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheReceivedInvocations.append((targetsRegex: targetsRegex, exceptTargetsRegex: exceptTargetsRegex, options: options, paths: paths, ignoreCache: ignoreCache))
        try await buildTargetsRegexExceptTargetsRegexOptionsPathsIgnoreCacheClosure?(targetsRegex, exceptTargetsRegex, options, paths, ignoreCache)
    }
}

// swiftlint:enable all

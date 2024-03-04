// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IBinariesStorageMock: IBinariesStorage {
    var sharedPath: String {
        get { return underlyingSharedPath }
        set(value) { underlyingSharedPath = value }
    }
    var underlyingSharedPath: String!

    // MARK: - binaryRelativePath

    var binaryRelativePathBuildOptionsThrowableError: Error?
    var binaryRelativePathBuildOptionsCallsCount = 0
    var binaryRelativePathBuildOptionsCalled: Bool { binaryRelativePathBuildOptionsCallsCount > 0 }
    var binaryRelativePathBuildOptionsReceivedArguments: (target: IInternalTarget, buildOptions: XcodeBuildOptions)?
    var binaryRelativePathBuildOptionsReceivedInvocations: [(target: IInternalTarget, buildOptions: XcodeBuildOptions)] = []
    private let binaryRelativePathBuildOptionsReceivedInvocationsLock = NSRecursiveLock()
    var binaryRelativePathBuildOptionsReturnValue: String!
    var binaryRelativePathBuildOptionsClosure: ((IInternalTarget, XcodeBuildOptions) throws -> String)?

    func binaryRelativePath(_ target: IInternalTarget, buildOptions: XcodeBuildOptions) throws -> String {
        binaryRelativePathBuildOptionsCallsCount += 1
        binaryRelativePathBuildOptionsReceivedArguments = (target: target, buildOptions: buildOptions)
        binaryRelativePathBuildOptionsReceivedInvocationsLock.withLock {
            binaryRelativePathBuildOptionsReceivedInvocations.append((target: target, buildOptions: buildOptions))
        }
        if let error = binaryRelativePathBuildOptionsThrowableError {
            throw error
        }
        if let binaryRelativePathBuildOptionsClosure = binaryRelativePathBuildOptionsClosure {
            return try binaryRelativePathBuildOptionsClosure(target, buildOptions)
        } else {
            return binaryRelativePathBuildOptionsReturnValue
        }
    }

    // MARK: - finderBinaryFolderPath

    var finderBinaryFolderPathBuildOptionsThrowableError: Error?
    var finderBinaryFolderPathBuildOptionsCallsCount = 0
    var finderBinaryFolderPathBuildOptionsCalled: Bool { finderBinaryFolderPathBuildOptionsCallsCount > 0 }
    var finderBinaryFolderPathBuildOptionsReceivedArguments: (target: IInternalTarget, buildOptions: XcodeBuildOptions)?
    var finderBinaryFolderPathBuildOptionsReceivedInvocations: [(target: IInternalTarget, buildOptions: XcodeBuildOptions)] = []
    private let finderBinaryFolderPathBuildOptionsReceivedInvocationsLock = NSRecursiveLock()
    var finderBinaryFolderPathBuildOptionsReturnValue: String!
    var finderBinaryFolderPathBuildOptionsClosure: ((IInternalTarget, XcodeBuildOptions) throws -> String)?

    func finderBinaryFolderPath(_ target: IInternalTarget, buildOptions: XcodeBuildOptions) throws -> String {
        finderBinaryFolderPathBuildOptionsCallsCount += 1
        finderBinaryFolderPathBuildOptionsReceivedArguments = (target: target, buildOptions: buildOptions)
        finderBinaryFolderPathBuildOptionsReceivedInvocationsLock.withLock {
            finderBinaryFolderPathBuildOptionsReceivedInvocations.append((target: target, buildOptions: buildOptions))
        }
        if let error = finderBinaryFolderPathBuildOptionsThrowableError {
            throw error
        }
        if let finderBinaryFolderPathBuildOptionsClosure = finderBinaryFolderPathBuildOptionsClosure {
            return try finderBinaryFolderPathBuildOptionsClosure(target, buildOptions)
        } else {
            return finderBinaryFolderPathBuildOptionsReturnValue
        }
    }

    // MARK: - xcodeBinaryFolderPath

    var xcodeBinaryFolderPathThrowableError: Error?
    var xcodeBinaryFolderPathCallsCount = 0
    var xcodeBinaryFolderPathCalled: Bool { xcodeBinaryFolderPathCallsCount > 0 }
    var xcodeBinaryFolderPathReceivedTarget: IInternalTarget?
    var xcodeBinaryFolderPathReceivedInvocations: [IInternalTarget] = []
    private let xcodeBinaryFolderPathReceivedInvocationsLock = NSRecursiveLock()
    var xcodeBinaryFolderPathReturnValue: String!
    var xcodeBinaryFolderPathClosure: ((IInternalTarget) throws -> String)?

    func xcodeBinaryFolderPath(_ target: IInternalTarget) throws -> String {
        xcodeBinaryFolderPathCallsCount += 1
        xcodeBinaryFolderPathReceivedTarget = target
        xcodeBinaryFolderPathReceivedInvocationsLock.withLock {
            xcodeBinaryFolderPathReceivedInvocations.append(target)
        }
        if let error = xcodeBinaryFolderPathThrowableError {
            throw error
        }
        if let xcodeBinaryFolderPathClosure = xcodeBinaryFolderPathClosure {
            return try xcodeBinaryFolderPathClosure(target)
        } else {
            return xcodeBinaryFolderPathReturnValue
        }
    }

    // MARK: - productFolderPath

    var productFolderPathTargetOptionsPathsCallsCount = 0
    var productFolderPathTargetOptionsPathsCalled: Bool { productFolderPathTargetOptionsPathsCallsCount > 0 }
    var productFolderPathTargetOptionsPathsReceivedArguments: (target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths)?
    var productFolderPathTargetOptionsPathsReceivedInvocations: [(target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths)] = []
    private let productFolderPathTargetOptionsPathsReceivedInvocationsLock = NSRecursiveLock()
    var productFolderPathTargetOptionsPathsReturnValue: String?
    var productFolderPathTargetOptionsPathsClosure: ((IInternalTarget, XcodeBuildOptions, XcodeBuildPaths) -> String?)?

    func productFolderPath(target: IInternalTarget, options: XcodeBuildOptions, paths: XcodeBuildPaths) -> String? {
        productFolderPathTargetOptionsPathsCallsCount += 1
        productFolderPathTargetOptionsPathsReceivedArguments = (target: target, options: options, paths: paths)
        productFolderPathTargetOptionsPathsReceivedInvocationsLock.withLock {
            productFolderPathTargetOptionsPathsReceivedInvocations.append((target: target, options: options, paths: paths))
        }
        if let productFolderPathTargetOptionsPathsClosure = productFolderPathTargetOptionsPathsClosure {
            return productFolderPathTargetOptionsPathsClosure(target, options, paths)
        } else {
            return productFolderPathTargetOptionsPathsReturnValue
        }
    }

    // MARK: - saveBinaries

    var saveBinariesOfTargetsBuildOptionsBuildPathsThrowableError: Error?
    var saveBinariesOfTargetsBuildOptionsBuildPathsCallsCount = 0
    var saveBinariesOfTargetsBuildOptionsBuildPathsCalled: Bool { saveBinariesOfTargetsBuildOptionsBuildPathsCallsCount > 0 }
    var saveBinariesOfTargetsBuildOptionsBuildPathsReceivedArguments: (targets: TargetsMap, buildOptions: XcodeBuildOptions, buildPaths: XcodeBuildPaths)?
    var saveBinariesOfTargetsBuildOptionsBuildPathsReceivedInvocations: [(targets: TargetsMap, buildOptions: XcodeBuildOptions, buildPaths: XcodeBuildPaths)] = []
    private let saveBinariesOfTargetsBuildOptionsBuildPathsReceivedInvocationsLock = NSRecursiveLock()
    var saveBinariesOfTargetsBuildOptionsBuildPathsClosure: ((TargetsMap, XcodeBuildOptions, XcodeBuildPaths) async throws -> Void)?

    func saveBinaries(ofTargets targets: TargetsMap, buildOptions: XcodeBuildOptions, buildPaths: XcodeBuildPaths) async throws {
        saveBinariesOfTargetsBuildOptionsBuildPathsCallsCount += 1
        saveBinariesOfTargetsBuildOptionsBuildPathsReceivedArguments = (targets: targets, buildOptions: buildOptions, buildPaths: buildPaths)
        saveBinariesOfTargetsBuildOptionsBuildPathsReceivedInvocationsLock.withLock {
            saveBinariesOfTargetsBuildOptionsBuildPathsReceivedInvocations.append((targets: targets, buildOptions: buildOptions, buildPaths: buildPaths))
        }
        if let error = saveBinariesOfTargetsBuildOptionsBuildPathsThrowableError {
            throw error
        }
        try await saveBinariesOfTargetsBuildOptionsBuildPathsClosure?(targets, buildOptions, buildPaths)
    }

    // MARK: - findBinaries

    var findBinariesOfTargetsBuildOptionsThrowableError: Error?
    var findBinariesOfTargetsBuildOptionsCallsCount = 0
    var findBinariesOfTargetsBuildOptionsCalled: Bool { findBinariesOfTargetsBuildOptionsCallsCount > 0 }
    var findBinariesOfTargetsBuildOptionsReceivedArguments: (targets: TargetsMap, buildOptions: XcodeBuildOptions)?
    var findBinariesOfTargetsBuildOptionsReceivedInvocations: [(targets: TargetsMap, buildOptions: XcodeBuildOptions)] = []
    private let findBinariesOfTargetsBuildOptionsReceivedInvocationsLock = NSRecursiveLock()
    var findBinariesOfTargetsBuildOptionsReturnValue: (found: TargetsMap, notFound: TargetsMap)!
    var findBinariesOfTargetsBuildOptionsClosure: ((TargetsMap, XcodeBuildOptions) throws -> (found: TargetsMap, notFound: TargetsMap))?

    func findBinaries(ofTargets targets: TargetsMap, buildOptions: XcodeBuildOptions) throws -> (found: TargetsMap, notFound: TargetsMap) {
        findBinariesOfTargetsBuildOptionsCallsCount += 1
        findBinariesOfTargetsBuildOptionsReceivedArguments = (targets: targets, buildOptions: buildOptions)
        findBinariesOfTargetsBuildOptionsReceivedInvocationsLock.withLock {
            findBinariesOfTargetsBuildOptionsReceivedInvocations.append((targets: targets, buildOptions: buildOptions))
        }
        if let error = findBinariesOfTargetsBuildOptionsThrowableError {
            throw error
        }
        if let findBinariesOfTargetsBuildOptionsClosure = findBinariesOfTargetsBuildOptionsClosure {
            return try findBinariesOfTargetsBuildOptionsClosure(targets, buildOptions)
        } else {
            return findBinariesOfTargetsBuildOptionsReturnValue
        }
    }
}

// swiftlint:enable all

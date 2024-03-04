// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class ITestsStorageMock: ITestsStorage {

    // MARK: - saveTests

    var saveTestsOfBuildOptionsThrowableError: Error?
    var saveTestsOfBuildOptionsCallsCount = 0
    var saveTestsOfBuildOptionsCalled: Bool { saveTestsOfBuildOptionsCallsCount > 0 }
    var saveTestsOfBuildOptionsReceivedArguments: (targets: TargetsMap, buildOptions: XcodeBuildOptions)?
    var saveTestsOfBuildOptionsReceivedInvocations: [(targets: TargetsMap, buildOptions: XcodeBuildOptions)] = []
    private let saveTestsOfBuildOptionsReceivedInvocationsLock = NSRecursiveLock()
    var saveTestsOfBuildOptionsClosure: ((TargetsMap, XcodeBuildOptions) async throws -> Void)?

    func saveTests(of targets: TargetsMap, buildOptions: XcodeBuildOptions) async throws {
        saveTestsOfBuildOptionsCallsCount += 1
        saveTestsOfBuildOptionsReceivedArguments = (targets: targets, buildOptions: buildOptions)
        saveTestsOfBuildOptionsReceivedInvocationsLock.withLock {
            saveTestsOfBuildOptionsReceivedInvocations.append((targets: targets, buildOptions: buildOptions))
        }
        if let error = saveTestsOfBuildOptionsThrowableError {
            throw error
        }
        try await saveTestsOfBuildOptionsClosure?(targets, buildOptions)
    }

    // MARK: - findMissingTests

    var findMissingTestsOfBuildOptionsThrowableError: Error?
    var findMissingTestsOfBuildOptionsCallsCount = 0
    var findMissingTestsOfBuildOptionsCalled: Bool { findMissingTestsOfBuildOptionsCallsCount > 0 }
    var findMissingTestsOfBuildOptionsReceivedArguments: (targets: TargetsMap, buildOptions: XcodeBuildOptions)?
    var findMissingTestsOfBuildOptionsReceivedInvocations: [(targets: TargetsMap, buildOptions: XcodeBuildOptions)] = []
    private let findMissingTestsOfBuildOptionsReceivedInvocationsLock = NSRecursiveLock()
    var findMissingTestsOfBuildOptionsReturnValue: TargetsMap!
    var findMissingTestsOfBuildOptionsClosure: ((TargetsMap, XcodeBuildOptions) async throws -> TargetsMap)?

    func findMissingTests(of targets: TargetsMap, buildOptions: XcodeBuildOptions) async throws -> TargetsMap {
        findMissingTestsOfBuildOptionsCallsCount += 1
        findMissingTestsOfBuildOptionsReceivedArguments = (targets: targets, buildOptions: buildOptions)
        findMissingTestsOfBuildOptionsReceivedInvocationsLock.withLock {
            findMissingTestsOfBuildOptionsReceivedInvocations.append((targets: targets, buildOptions: buildOptions))
        }
        if let error = findMissingTestsOfBuildOptionsThrowableError {
            throw error
        }
        if let findMissingTestsOfBuildOptionsClosure = findMissingTestsOfBuildOptionsClosure {
            return try await findMissingTestsOfBuildOptionsClosure(targets, buildOptions)
        } else {
            return findMissingTestsOfBuildOptionsReturnValue
        }
    }
}

// swiftlint:enable all

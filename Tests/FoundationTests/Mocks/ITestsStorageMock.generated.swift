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
    var saveTestsOfBuildOptionsClosure: ((TargetsMap, XcodeBuildOptions) async throws -> Void)?

    func saveTests(of targets: TargetsMap, buildOptions: XcodeBuildOptions) async throws {
        if let error = saveTestsOfBuildOptionsThrowableError {
            throw error
        }
        saveTestsOfBuildOptionsCallsCount += 1
        saveTestsOfBuildOptionsReceivedArguments = (targets: targets, buildOptions: buildOptions)
        saveTestsOfBuildOptionsReceivedInvocations.append((targets: targets, buildOptions: buildOptions))
        try await saveTestsOfBuildOptionsClosure?(targets, buildOptions)
    }

    // MARK: - findMissingTests

    var findMissingTestsOfBuildOptionsThrowableError: Error?
    var findMissingTestsOfBuildOptionsCallsCount = 0
    var findMissingTestsOfBuildOptionsCalled: Bool { findMissingTestsOfBuildOptionsCallsCount > 0 }
    var findMissingTestsOfBuildOptionsReceivedArguments: (targets: TargetsMap, buildOptions: XcodeBuildOptions)?
    var findMissingTestsOfBuildOptionsReceivedInvocations: [(targets: TargetsMap, buildOptions: XcodeBuildOptions)] = []
    var findMissingTestsOfBuildOptionsReturnValue: [IInternalTarget]!
    var findMissingTestsOfBuildOptionsClosure: ((TargetsMap, XcodeBuildOptions) async throws -> [IInternalTarget])?

    func findMissingTests(of targets: TargetsMap, buildOptions: XcodeBuildOptions) async throws -> [IInternalTarget] {
        if let error = findMissingTestsOfBuildOptionsThrowableError {
            throw error
        }
        findMissingTestsOfBuildOptionsCallsCount += 1
        findMissingTestsOfBuildOptionsReceivedArguments = (targets: targets, buildOptions: buildOptions)
        findMissingTestsOfBuildOptionsReceivedInvocations.append((targets: targets, buildOptions: buildOptions))
        if let findMissingTestsOfBuildOptionsClosure = findMissingTestsOfBuildOptionsClosure {
            return try await findMissingTestsOfBuildOptionsClosure(targets, buildOptions)
        } else {
            return findMissingTestsOfBuildOptionsReturnValue
        }
    }
}

// swiftlint:enable all

// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IXcodeBuildMock: IXcodeBuild {

    // MARK: - build

    var buildTargetOptionsPathsThrowableError: Error?
    var buildTargetOptionsPathsCallsCount = 0
    var buildTargetOptionsPathsCalled: Bool { buildTargetOptionsPathsCallsCount > 0 }
    var buildTargetOptionsPathsReceivedArguments: (target: String, options: XcodeBuildOptions, paths: XcodeBuildPaths)?
    var buildTargetOptionsPathsReceivedInvocations: [(target: String, options: XcodeBuildOptions, paths: XcodeBuildPaths)] = []
    private let buildTargetOptionsPathsReceivedInvocationsLock = NSRecursiveLock()
    var buildTargetOptionsPathsClosure: ((String, XcodeBuildOptions, XcodeBuildPaths) async throws -> Void)?

    func build(target: String, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws {
        buildTargetOptionsPathsCallsCount += 1
        buildTargetOptionsPathsReceivedArguments = (target: target, options: options, paths: paths)
        buildTargetOptionsPathsReceivedInvocationsLock.withLock {
            buildTargetOptionsPathsReceivedInvocations.append((target: target, options: options, paths: paths))
        }
        if let error = buildTargetOptionsPathsThrowableError {
            throw error
        }
        try await buildTargetOptionsPathsClosure?(target, options, paths)
    }

    // MARK: - test

    var testSchemeTestPlanSimulatorNameOptionsPathsThrowableError: Error?
    var testSchemeTestPlanSimulatorNameOptionsPathsCallsCount = 0
    var testSchemeTestPlanSimulatorNameOptionsPathsCalled: Bool { testSchemeTestPlanSimulatorNameOptionsPathsCallsCount > 0 }
    var testSchemeTestPlanSimulatorNameOptionsPathsReceivedArguments: (scheme: String, testPlan: String, simulatorName: String, options: XcodeBuildOptions, paths: XcodeBuildPaths)?
    var testSchemeTestPlanSimulatorNameOptionsPathsReceivedInvocations: [(scheme: String, testPlan: String, simulatorName: String, options: XcodeBuildOptions, paths: XcodeBuildPaths)] = []
    private let testSchemeTestPlanSimulatorNameOptionsPathsReceivedInvocationsLock = NSRecursiveLock()
    var testSchemeTestPlanSimulatorNameOptionsPathsClosure: ((String, String, String, XcodeBuildOptions, XcodeBuildPaths) async throws -> Void)?

    func test(scheme: String, testPlan: String, simulatorName: String, options: XcodeBuildOptions, paths: XcodeBuildPaths) async throws {
        testSchemeTestPlanSimulatorNameOptionsPathsCallsCount += 1
        testSchemeTestPlanSimulatorNameOptionsPathsReceivedArguments = (scheme: scheme, testPlan: testPlan, simulatorName: simulatorName, options: options, paths: paths)
        testSchemeTestPlanSimulatorNameOptionsPathsReceivedInvocationsLock.withLock {
            testSchemeTestPlanSimulatorNameOptionsPathsReceivedInvocations.append((scheme: scheme, testPlan: testPlan, simulatorName: simulatorName, options: options, paths: paths))
        }
        if let error = testSchemeTestPlanSimulatorNameOptionsPathsThrowableError {
            throw error
        }
        try await testSchemeTestPlanSimulatorNameOptionsPathsClosure?(scheme, testPlan, simulatorName, options, paths)
    }
}

// swiftlint:enable all

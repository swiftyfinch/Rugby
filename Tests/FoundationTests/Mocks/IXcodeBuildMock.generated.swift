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
    var buildTargetOptionsPathsClosure: ((String, XcodeBuildOptions, XcodeBuildPaths) throws -> Void)?

    func build(target: String, options: XcodeBuildOptions, paths: XcodeBuildPaths) throws {
        buildTargetOptionsPathsCallsCount += 1
        buildTargetOptionsPathsReceivedArguments = (target: target, options: options, paths: paths)
        buildTargetOptionsPathsReceivedInvocations.append((target: target, options: options, paths: paths))
        if let error = buildTargetOptionsPathsThrowableError {
            throw error
        }
        try buildTargetOptionsPathsClosure?(target, options, paths)
    }
}

// swiftlint:enable all

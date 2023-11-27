// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
@testable import RugbyFoundation

final class IFileContentHasherMock: IFileContentHasher {

    // MARK: - hashContext

    var hashContextPathsThrowableError: Error?
    var hashContextPathsCallsCount = 0
    var hashContextPathsCalled: Bool { hashContextPathsCallsCount > 0 }
    var hashContextPathsReceivedPaths: [String]?
    var hashContextPathsReceivedInvocations: [[String]] = []
    var hashContextPathsReturnValue: [String]!
    var hashContextPathsClosure: (([String]) async throws -> [String])?

    func hashContext(paths: [String]) async throws -> [String] {
        if let error = hashContextPathsThrowableError {
            throw error
        }
        hashContextPathsCallsCount += 1
        hashContextPathsReceivedPaths = paths
        hashContextPathsReceivedInvocations.append(paths)
        if let hashContextPathsClosure = hashContextPathsClosure {
            return try await hashContextPathsClosure(paths)
        } else {
            return hashContextPathsReturnValue
        }
    }
}

// swiftlint:enable all
